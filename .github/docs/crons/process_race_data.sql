                v_operation_start := NOW();
                BEGIN
                    -- Call qualifying-api and capture response
                    v_api_response := net.http_post(
                        url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/qualifying-api',
                        headers := jsonb_build_object(
                            'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                            'Content-Type', 'application/json'
                        ),
                        body := jsonb_build_object(
                            'year', v_race.season,
                            'round', v_race.round,
                            'schema', 'staging'
                        )
                    );

                    -- Only update processed status if qualifyingResults array is populated
                    IF v_api_response->'data'->'qualifyingResults' IS NOT NULL AND 
                       jsonb_array_length(v_api_response->'data'->'qualifyingResults') > 0 THEN
                        
                        -- Update processed status
                        UPDATE staging.races
                        SET processed = jsonb_set(
                            processed,
                            '{qualifying_results}',
                            'true'::jsonb
                        )
                        WHERE id = v_race.id;

                        -- Log success
                        INSERT INTO staging.cron_detailed_logs (
                            message, event_type, operation_type, race_round, 
                            race_season, race_name, processing_duration, 
                            api_response_status
                        ) VALUES (
                            format('Successfully processed qualifying results for %s', v_race.race_name),
                            'success',
                            'qualifying',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            (v_api_response->>'status')::INTEGER
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,qualifying,success}',
                            to_jsonb((v_summary->'processing_status'->'qualifying'->>'success')::INTEGER + 1)
                        );
                    ELSE
                        -- Log skipped due to no qualifying results
                        INSERT INTO staging.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            error_category
                        ) VALUES (
                            format('No qualifying results found for %s', v_race.race_name),
                            'skipped',
                            'qualifying',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            'no_results'
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,qualifying,skipped}',
                            to_jsonb((v_summary->'processing_status'->'qualifying'->>'skipped')::INTEGER + 1)
                        );
                    END IF;
                END; 