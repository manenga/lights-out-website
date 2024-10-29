import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final String currentRoute;

  const Footer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final calculatedFontSize = MediaQuery.of(context).size.width * 0.03;
    var fontSize = calculatedFontSize <= 18.0 ? calculatedFontSize : 18.0;
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lights Out by MoodyTech',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: currentRoute == '/support'
                    ? null
                    : () => Navigator.pushNamed(context, '/support'),
                child: const Text('Support',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: currentRoute == '/privacy'
                    ? null
                    : () => Navigator.pushNamed(context, '/privacy'),
                child: const Text('Privacy Policy',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: currentRoute == '/terms'
                    ? null
                    : () => Navigator.pushNamed(context, '/terms'),
                child: const Text('Terms And Conditions',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
