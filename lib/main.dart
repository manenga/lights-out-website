import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lights_out_website/blocs/circuit/circuit_event.dart';
import 'package:lights_out_website/blocs/race/race_event.dart';
import 'package:lights_out_website/blocs/theme/theme_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/race/race_bloc.dart';
import 'blocs/circuit/circuit_bloc.dart';
import 'pages/home_page.dart';
import 'pages/privacy_page.dart';
import 'pages/terms_page.dart';
import 'pages/calendar_page.dart';
import 'pages/support_page.dart';
import 'package:url_strategy/url_strategy.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => RaceBloc(
            SupabaseService(Supabase.instance.client),
          )..add(LoadRacesEvent()),
        ),
        BlocProvider(
          create: (context) => CircuitBloc(
            SupabaseService(Supabase.instance.client),
          )..add(LoadCircuitsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Lights Out',
            theme: ThemeData(
              primaryColor: Colors.red[600],
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(
                state.isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
              ),
            ),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              final Widget page = _getPageForRoute(settings.name ?? '/');
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var opacityAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: opacityAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/':
        return const HomePage();
      case '/calendar':
        return const CalendarPage();
      case '/support':
        return const SupportPage();
      case '/privacy':
        return const PrivacyPage();
      case '/terms':
        return const TermsPage();
      default:
        return const HomePage();
    }
  }
}
