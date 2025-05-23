import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lights_out_website/blocs/theme/theme_state.dart';
import '../blocs/theme/theme_bloc.dart';
import 'footer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => currentRoute == '/' ? null : Navigator.pushNamed(context, '/'),
          child: Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32),
              const SizedBox(width: 10),
              const Text('Lights Out'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
              );
            },
          ),
          TextButton(
            onPressed: () => currentRoute == '/' ? null : Navigator.pushNamed(context, '/'),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => currentRoute == '/calendar' ? null : Navigator.pushNamed(context, '/calendar'),
            child: const Text('Calendar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
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
         Footer(currentRoute: currentRoute),
        ],
      ),
    );
  }
}
