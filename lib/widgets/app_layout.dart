import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'footer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lights Out Away We Go'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
            child: const Text('Calendar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween to push footer down
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded( // Use Expanded to allow the content to take available space
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: child,
                ),
              ),
            ),
          ),
          const Footer(), // Footer will be pushed to the bottom
        ],
      ),
    );
  }
}
