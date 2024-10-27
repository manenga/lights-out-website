import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final String currentRoute;

  const Footer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lights Out by MoodyTech',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ultimate F1 race schedule companion',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
            TextButton(
              onPressed: currentRoute == '/support' ? null : () => Navigator.pushNamed(context, '/support'),
              child: const Text('Support', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: currentRoute == '/privacy' ? null : () => Navigator.pushNamed(context, '/privacy'),
              child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: currentRoute == '/terms' ? null : () => Navigator.pushNamed(context, '/terms'),
              child: const Text('Terms And Conditions', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
