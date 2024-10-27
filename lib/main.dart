import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'providers/race_provider.dart';
import 'pages/home_page.dart';
import 'pages/privacy_page.dart';
import 'pages/terms_page.dart';
import 'pages/calendar_page.dart';
import 'pages/support_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RaceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Lights Out Away We Go',
      theme: ThemeData(
        primaryColor: Colors.red[600],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(
          themeProvider.isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/calendar': (context) => const CalendarPage(),
        '/support': (context) => const SupportPage(),
        '/privacy': (context) => const PrivacyPage(),
        '/terms': (context) => const TermsPage(),
      },
      // Custom navigation logic
      onGenerateRoute: (settings) {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute == settings.name) {
          return null; // Prevent navigation to the same page
        }
        final Widget page = _getPageForRoute(settings.name ?? '/');
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
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
