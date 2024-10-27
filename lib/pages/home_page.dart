import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/race_provider.dart';
import '../widgets/app_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);

    return AppLayout(
      title: 'Home',
      currentRoute: '/',
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFFF5252), Color(0xFFB71C1C)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Never Miss a Race',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Track the entire F1 season with our comprehensive schedule',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Image.asset('assets/images/phone_mockups.png', width: 300),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/app_store_badge.png',
                          width: 150,
                        ),
                        onPressed: () async {
                          const appStoreUrl = 'https://apps.apple.com/us/app/lights-out-and-away-we-go/id6575374255';
                          if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                            await launchUrl(Uri.parse(appStoreUrl));
                          } else {
                            throw 'Could not launch $appStoreUrl';
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Image.asset(
                          'assets/images/google_play_badge.png',
                          width: 150,
                        ),
                        onPressed: () async {
                          const appStoreUrl = 'https://play.google.com/store/apps/details?id=za.co.moodytech.lights_out';
                          if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                            await launchUrl(Uri.parse(appStoreUrl));
                          } else {
                            throw 'Could not launch $appStoreUrl';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            )),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Races',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: raceProvider.races.length,
                      itemBuilder: (context, index) {
                        final race = raceProvider.races[index];
                        return Card(
                          child: ListTile(
                            leading: Text(
                              race.flagEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(race.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(race.circuit),
                                Text(
                                  '${race.date.day}/${race.date.month}/${race.date.year}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                race.isFavorite ? Icons.star : Icons.star_border,
                                color: race.isFavorite ? Colors.amber : null,
                              ),
                              onPressed: () => raceProvider.toggleFavorite(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
