-- Example: enable the "http" extension
create extension if not exists http with schema extensions;

-- Example: disable the "http" extension
-- drop extension if exists http;

-- Create pg_net extension if it doesn't exist
CREATE EXTENSION IF NOT EXISTS "pg_net";

-- Create vault table for sensitive values
CREATE TABLE IF NOT EXISTS vault.settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create detailed logs table
CREATE TABLE IF NOT EXISTS prod.cron_detailed_logs (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    message TEXT NOT NULL,
    event_type TEXT NOT NULL,
    operation_type TEXT NOT NULL,
    race_round INTEGER,
    race_season INTEGER,
    race_name TEXT,
    processing_duration INTERVAL,
    api_response_status INTEGER,
    error_category TEXT
);

-- Create summary logs table
CREATE TABLE IF NOT EXISTS prod.cron_summary_logs (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_processing_time INTERVAL,
    summary_data JSONB NOT NULL
);

-- Create index on timestamp for both tables
CREATE INDEX IF NOT EXISTS idx_cron_detailed_logs_timestamp ON prod.cron_detailed_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_cron_summary_logs_timestamp ON prod.cron_summary_logs(timestamp);

-- Function to clean up old summary logs
CREATE OR REPLACE FUNCTION prod.cleanup_old_summary_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM prod.cron_summary_logs
    WHERE timestamp < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql;


-- Main processing function
CREATE OR REPLACE FUNCTION prod.process_race_data()
RETURNS void AS $$
DECLARE
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_race RECORD;
    v_summary JSONB;
    v_processing_status JSONB;
    v_records_updated JSONB;
    v_errors JSONB;
    v_operation_start TIMESTAMP WITH TIME ZONE;
    v_operation_duration INTERVAL;
    v_api_response JSONB;
BEGIN
    v_start_time := NOW();
    
    -- Initialize summary structure
    v_summary := jsonb_build_object(
        'last_run', v_start_time,
        'total_races_processed', 0,
        'processing_status', jsonb_build_object(
            'qualifying', jsonb_build_object('success', 0, 'failed', 0, 'skipped', 0, 'races', '[]'::jsonb),
            'sprint', jsonb_build_object('success', 0, 'failed', 0, 'skipped', 0, 'races', '[]'::jsonb),
            'race', jsonb_build_object('success', 0, 'failed', 0, 'skipped', 0, 'races', '[]'::jsonb),
            'standings', jsonb_build_object('success', 0, 'failed', 0, 'races', '[]'::jsonb)
        ),
        'records_updated', jsonb_build_object(
            'qualifying', 0,
            'sprint', 0,
            'race', 0,
            'standings', 0
        ),
        'errors', '[]'::jsonb
    );

    -- Add processed column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'prod' 
        AND table_name = 'races' 
        AND column_name = 'processed'
    ) THEN
        ALTER TABLE prod.races
        ADD COLUMN processed JSONB DEFAULT jsonb_build_object(
            'sprint_results', false,
            'qualifying_results', false,
            'race_results', false
        );
    END IF;

    -- Process each unprocessed race
    FOR v_race IN 
        SELECT 
            r.*,
            EXTRACT(YEAR FROM race_date_time)::INTEGER as season,
            CASE 
                WHEN race_date_time::text IS NULL OR race_date_time::text = '' THEN NULL
                ELSE EXTRACT(EPOCH FROM (race_date_time::timestamp with time zone AT TIME ZONE 'UTC'))::INTEGER 
            END as race_timestamp,
            CASE 
                WHEN quali_date_time::text IS NULL OR quali_date_time::text = '' THEN NULL
                ELSE EXTRACT(EPOCH FROM (quali_date_time::timestamp with time zone AT TIME ZONE 'UTC'))::INTEGER 
            END as quali_timestamp,
            CASE 
                WHEN sprint_date_time::text IS NULL OR sprint_date_time::text = '' THEN NULL
                ELSE EXTRACT(EPOCH FROM (sprint_date_time::timestamp with time zone AT TIME ZONE 'UTC'))::INTEGER 
            END as sprint_timestamp
        FROM prod.races r
        WHERE 
            processed->>'qualifying_results' = 'false' OR
            processed->>'sprint_results' = 'false' OR
            processed->>'race_results' = 'false'
        ORDER BY race_date_time ASC
    LOOP
        -- Skip if any event is more than 1 day in the future
        IF (v_race.quali_timestamp IS NOT NULL AND EXTRACT(EPOCH FROM NOW()) < (v_race.quali_timestamp - 86400)) OR
           (v_race.sprint_timestamp IS NOT NULL AND EXTRACT(EPOCH FROM NOW()) < (v_race.sprint_timestamp - 86400)) OR
           (v_race.race_timestamp IS NOT NULL AND EXTRACT(EPOCH FROM NOW()) < (v_race.race_timestamp - 86400)) THEN
            CONTINUE;
        END IF;

        -- Process qualifying if needed
        IF v_race.processed->>'qualifying_results' = 'false' AND v_race.quali_timestamp IS NOT NULL THEN
            IF EXTRACT(EPOCH FROM NOW()) > (v_race.quali_timestamp + 7200) THEN
                v_operation_start := NOW();
                BEGIN
                    -- Call qualifying-api
                    PERFORM net.http_post(
                        url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/qualifying-api',
                        headers := jsonb_build_object(
                            'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                            'Content-Type', 'application/json'
                        ),
                        body := jsonb_build_object(
                            'year', v_race.season,
                            'round', v_race.round,
                            'schema', 'prod'
                        )
                    );

                    -- Only update processed status if qualifyingResults array is populated
                    IF v_api_response->'data'->'qualifyingResults' IS NOT NULL AND 
                       jsonb_array_length(v_api_response->'data'->'qualifyingResults') > 0 THEN
                    
                        -- Update processed status
                        UPDATE prod.races
                        SET processed = jsonb_set(
                            processed,
                            '{qualifying_results}',
                            'true'::jsonb
                        )
                        WHERE id = v_race.id;

                        -- Log success
                        INSERT INTO prod.cron_detailed_logs (
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
                        INSERT INTO prod.cron_detailed_logs (
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
                EXCEPTION WHEN OTHERS THEN
                    -- Log error
                    INSERT INTO prod.cron_detailed_logs (
                        message, event_type, operation_type, race_round,
                        race_season, race_name, processing_duration,
                        error_category
                    ) VALUES (
                        format('Error processing qualifying results: %s', SQLERRM),
                        'failed',
                        'qualifying',
                        v_race.round,
                        v_race.season::INTEGER,
                        v_race.race_name,
                        NOW() - v_operation_start,
                        'api_error'
                    );

                    -- Update summary
                    v_summary := jsonb_set(
                        v_summary,
                        '{processing_status,qualifying,failed}',
                        to_jsonb((v_summary->'processing_status'->'qualifying'->>'failed')::INTEGER + 1)
                    );
                END;
            ELSE
                -- Log skipped
                INSERT INTO prod.cron_detailed_logs (
                    message, event_type, operation_type, race_round,
                    race_season, race_name
                ) VALUES (
                    format('Skipping qualifying results for %s - too early', v_race.race_name),
                    'skipped',
                    'qualifying',
                    v_race.round,
                    v_race.season::INTEGER,
                    v_race.race_name
                );

                -- Update summary
                v_summary := jsonb_set(
                    v_summary,
                    '{processing_status,qualifying,skipped}',
                    to_jsonb((v_summary->'processing_status'->'qualifying'->>'skipped')::INTEGER + 1)
                );
            END IF;
        END IF;

        -- Process sprint if needed
        IF v_race.processed->>'sprint_results' = 'false' 
           AND v_race.sprint_timestamp IS NOT NULL THEN
            IF EXTRACT(EPOCH FROM NOW()) > (v_race.sprint_timestamp + 7200) THEN
                v_operation_start := NOW();
                BEGIN
                    -- Call sprint-api
                    PERFORM net.http_post(
                        url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/sprint-api',
                        headers := jsonb_build_object(
                            'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                            'Content-Type', 'application/json'
                        ),
                        body := jsonb_build_object(
                            'year', v_race.season,
                            'round', v_race.round,
                            'schema', 'prod'
                        )
                    );

                    -- Only update processed status if sprintResults array is populated
                    IF v_api_response->'data'->'sprintResults' IS NOT NULL AND 
                       jsonb_array_length(v_api_response->'data'->'sprintResults') > 0 THEN
                    
                        -- Update processed status
                        UPDATE prod.races
                        SET processed = jsonb_set(
                            processed,
                            '{sprint_results}',
                            'true'::jsonb
                        )
                        WHERE id = v_race.id;

                        -- Log success
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            api_response_status
                        ) VALUES (
                            format('Successfully processed sprint results for %s', v_race.race_name),
                            'success',
                            'sprint',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            (v_api_response->>'status')::INTEGER
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,sprint,success}',
                            to_jsonb((v_summary->'processing_status'->'sprint'->>'success')::INTEGER + 1)
                        );
                    ELSE
                        -- Log skipped due to no sprint results
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            error_category
                        ) VALUES (
                            format('No sprint results found for %s', v_race.race_name),
                            'skipped',
                            'sprint',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            'no_results'
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,sprint,skipped}',
                            to_jsonb((v_summary->'processing_status'->'sprint'->>'skipped')::INTEGER + 1)
                        );
                    END IF;

                    -- Process standings after sprint
                    BEGIN
                        PERFORM net.http_post(
                            url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/standings-api',
                            headers := jsonb_build_object(
                                'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                                'Content-Type', 'application/json'
                            ),
                            body := jsonb_build_object(
                                'year', v_race.season,
                                'round', v_race.round,
                                'schema', 'prod'
                            )
                        );

                        -- Only update processed status if drivers & constructors array are populated
                        IF jsonb_array_length(v_api_response->'data'->'drivers') > 0 AND 
                            jsonb_array_length(v_api_response->'data'->'constructors') > 0 THEN
                    
                            -- Log standings success
                            INSERT INTO prod.cron_detailed_logs (
                                message, event_type, operation_type, race_round,
                                race_season, race_name, processing_duration,
                                api_response_status
                            ) VALUES (
                                format('Successfully processed standings after sprint for %s', v_race.race_name),
                                'success',
                                'standings',
                                v_race.round,
                                v_race.season::INTEGER,
                                v_race.race_name,
                                NOW() - v_operation_start,
                                (v_api_response->>'status')::INTEGER
                            );

                            -- Update summary
                            v_summary := jsonb_set(
                                v_summary,
                                '{processing_status,standings,success}',
                                to_jsonb((v_summary->'processing_status'->'standings'->>'success')::INTEGER + 1)
                            );
                        ELSE
                            -- Log skipped due to no standings update
                            INSERT INTO prod.cron_detailed_logs (
                                message, event_type, operation_type, race_round,
                                race_season, race_name, processing_duration,
                                error_category
                            ) VALUES (
                                format('No standings updates found for %s', v_race.race_name),
                                'skipped',
                                'standings',
                                v_race.round,
                                v_race.season::INTEGER,
                                v_race.race_name,
                                NOW() - v_operation_start,
                                'no_results'
                            );

                            -- Update summary
                            v_summary := jsonb_set(
                                v_summary,
                                '{processing_status,standings,skipped}',
                                to_jsonb((v_summary->'processing_status'->'standings'->>'skipped')::INTEGER + 1)
                            );
                        END IF;
                    EXCEPTION WHEN OTHERS THEN
                        -- Log standings error
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            error_category
                        ) VALUES (
                            format('Error processing standings after sprint: %s', SQLERRM),
                            'failed',
                            'standings',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            'api_error'
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,standings,failed}',
                            to_jsonb((v_summary->'processing_status'->'standings'->>'failed')::INTEGER + 1)
                        );
                    END;
                EXCEPTION WHEN OTHERS THEN
                    -- Log sprint error
                    INSERT INTO prod.cron_detailed_logs (
                        message, event_type, operation_type, race_round,
                        race_season, race_name, processing_duration,
                        error_category
                    ) VALUES (
                        format('Error processing sprint results: %s', SQLERRM),
                        'failed',
                        'sprint',
                        v_race.round,
                        v_race.season::INTEGER,
                        v_race.race_name,
                        NOW() - v_operation_start,
                        'api_error'
                    );

                    -- Update summary
                    v_summary := jsonb_set(
                        v_summary,
                        '{processing_status,sprint,failed}',
                        to_jsonb((v_summary->'processing_status'->'sprint'->>'failed')::INTEGER + 1)
                    );
                END;
            ELSE
                -- Log skipped
                INSERT INTO prod.cron_detailed_logs (
                    message, event_type, operation_type, race_round,
                    race_season, race_name
                ) VALUES (
                    format('Skipping sprint results for %s - too early', v_race.race_name),
                    'skipped',
                    'sprint',
                    v_race.round,
                    v_race.season::INTEGER,
                    v_race.race_name
                );

                -- Update summary
                v_summary := jsonb_set(
                    v_summary,
                    '{processing_status,sprint,skipped}',
                    to_jsonb((v_summary->'processing_status'->'sprint'->>'skipped')::INTEGER + 1)
                );
            END IF;
        END IF;

        -- Process race if needed
        IF v_race.processed->>'race_results' = 'false' THEN
            IF EXTRACT(EPOCH FROM NOW()) > (v_race.race_timestamp + 7200) THEN
                v_operation_start := NOW();
                BEGIN
                    -- Call results-api
                    PERFORM net.http_post(
                        url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/results-api',
                        headers := jsonb_build_object(
                            'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                            'Content-Type', 'application/json'
                        ),
                        body := jsonb_build_object(
                            'year', v_race.season,
                            'round', v_race.round,
                            'schema', 'prod'
                        )
                    );

                    -- Only update processed status if raceResults array is populated
                    IF v_api_response->'data'->'raceResults' IS NOT NULL AND 
                       jsonb_array_length(v_api_response->'data'->'raceResults') > 0 THEN
                        
                        -- Update processed status
                        UPDATE prod.races
                        SET processed = jsonb_set(
                            processed,
                            '{race_results}',
                            'true'::jsonb
                        )
                        WHERE id = v_race.id;

                        -- Log success
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            api_response_status
                        ) VALUES (
                            format('Successfully processed race results for %s', v_race.race_name),
                            'success',
                            'race',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            (v_api_response->>'status')::INTEGER
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,race,success}',
                            to_jsonb((v_summary->'processing_status'->'race'->>'success')::INTEGER + 1)
                        );
                    ELSE
                        -- Log skipped due to no race results
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            error_category
                        ) VALUES (
                            format('No race results found for %s', v_race.race_name),
                            'skipped',
                            'race',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            'no_results'
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,race,skipped}',
                            to_jsonb((v_summary->'processing_status'->'race'->>'skipped')::INTEGER + 1)
                        );
                    END IF;

                    -- Process standings after race
                    BEGIN
                        PERFORM net.http_post(
                            url := (SELECT value FROM vault.settings WHERE key = 'supabase_url') || '/functions/v1/standings-api',
                            headers := jsonb_build_object(
                                'Authorization', 'Bearer ' || (SELECT value FROM vault.settings WHERE key = 'service_role_key'),
                                'Content-Type', 'application/json'
                            ),
                            body := jsonb_build_object(
                                'year', v_race.season,
                                'round', v_race.round,
                                'schema', 'prod'
                            )
                        );
                        -- Only update processed status if drivers & constructors array are populated
                        IF jsonb_array_length(v_api_response->'data'->'drivers') > 0 AND 
                            jsonb_array_length(v_api_response->'data'->'constructors') > 0 THEN
                            
                            -- Log standings success
                            INSERT INTO prod.cron_detailed_logs (
                                message, event_type, operation_type, race_round,
                                race_season, race_name, processing_duration,
                                api_response_status
                            ) VALUES (
                                format('Successfully processed standings after race for %s', v_race.race_name),
                                'success',
                                'standings',
                                v_race.round,
                                v_race.season::INTEGER,
                                v_race.race_name,
                                NOW() - v_operation_start,
                                (v_api_response->>'status')::INTEGER
                            );

                            -- Update summary
                            v_summary := jsonb_set(
                                v_summary,
                                '{processing_status,standings,success}',
                                to_jsonb((v_summary->'processing_status'->'standings'->>'success')::INTEGER + 1)
                            );
                        ELSE
                            -- Log skipped due to no standings update
                            INSERT INTO prod.cron_detailed_logs (
                                message, event_type, operation_type, race_round,
                                race_season, race_name, processing_duration,
                                error_category
                            ) VALUES (
                                format('No standings updates found for %s', v_race.race_name),
                                'skipped',
                                'standings',
                                v_race.round,
                                v_race.season::INTEGER,
                                v_race.race_name,
                                NOW() - v_operation_start,
                                'no_results'
                            );

                            -- Update summary
                            v_summary := jsonb_set(
                                v_summary,
                                '{processing_status,standings,skipped}',
                                to_jsonb((v_summary->'processing_status'->'standings'->>'skipped')::INTEGER + 1)
                            );
                        END IF;
                    EXCEPTION WHEN OTHERS THEN
                        -- Log standings error
                        INSERT INTO prod.cron_detailed_logs (
                            message, event_type, operation_type, race_round,
                            race_season, race_name, processing_duration,
                            error_category
                        ) VALUES (
                            format('Error processing standings after race: %s', SQLERRM),
                            'failed',
                            'standings',
                            v_race.round,
                            v_race.season::INTEGER,
                            v_race.race_name,
                            NOW() - v_operation_start,
                            'api_error'
                        );

                        -- Update summary
                        v_summary := jsonb_set(
                            v_summary,
                            '{processing_status,standings,failed}',
                            to_jsonb((v_summary->'processing_status'->'standings'->>'failed')::INTEGER + 1)
                        );
                    END;
                EXCEPTION WHEN OTHERS THEN
                    -- Log race error
                    INSERT INTO prod.cron_detailed_logs (
                        message, event_type, operation_type, race_round,
                        race_season, race_name, processing_duration,
                        error_category
                    ) VALUES (
                        format('Error processing race results: %s', SQLERRM),
                        'failed',
                        'race',
                        v_race.round,
                        v_race.season::INTEGER,
                        v_race.race_name,
                        NOW() - v_operation_start,
                        'api_error'
                    );

                    -- Update summary
                    v_summary := jsonb_set(
                        v_summary,
                        '{processing_status,race,failed}',
                        to_jsonb((v_summary->'processing_status'->'race'->>'failed')::INTEGER + 1)
                    );
                END;
            ELSE
                -- Log skipped
                INSERT INTO prod.cron_detailed_logs (
                    message, event_type, operation_type, race_round,
                    race_season, race_name
                ) VALUES (
                    format('Skipping race results for %s - too early', v_race.race_name),
                    'skipped',
                    'race',
                    v_race.round,
                    v_race.season::INTEGER,
                    v_race.race_name
                );

                -- Update summary
                v_summary := jsonb_set(
                    v_summary,
                    '{processing_status,race,skipped}',
                    to_jsonb((v_summary->'processing_status'->'race'->>'skipped')::INTEGER + 1)
                );
            END IF;
        END IF;

        -- Increment total races processed
        v_summary := jsonb_set(
            v_summary,
            '{total_races_processed}',
            to_jsonb((v_summary->>'total_races_processed')::INTEGER + 1)
        );
    END LOOP;

    -- Insert final summary
    INSERT INTO prod.cron_summary_logs (
        timestamp,
        total_processing_time,
        summary_data
    ) VALUES (
        NOW(),
        NOW() - v_start_time,
        v_summary
    );

    -- Clean up old summary logs
    PERFORM prod.cleanup_old_summary_logs();
END;
$$ LANGUAGE plpgsql;


-- Create the cron job
-- SELECT cron.schedule(
--   'process_prod_race_data',
--     '0 * * * *',  -- run every hour
--     $$
--     SELECT prod.process_race_data();
--     $$
-- );


-- -- Check the cron job schedule
-- SELECT * FROM cron.job;

-- -- unschedule
-- SELECT cron.unschedule('hourly-house-keeping');

-- -- Run the processor manually
SELECT prod.process_race_data();
-- DELETE FROM prod.cron_detailed_logs;

-- -- View logs 
SELECT * FROM prod.cron_detailed_logs;
-- SELECT * FROM prod.cron_summary_logs;

-- CREATE OR REPLACE FUNCTION vault.get_secret(secret_key TEXT)
-- RETURNS TEXT AS $$
-- DECLARE
--     secret_value TEXT;
-- BEGIN
--     SELECT secret INTO secret_value
--     FROM vault.secrets
--     WHERE name = secret_key;
--     RETURN secret_value;
-- END;
-- $$ LANGUAGE plpgsql;
-- SELECT vault.get_secret('supabase_url');

-- select * 
-- from vault.decrypted_secrets 
-- order by created_at desc 
-- limit 3;