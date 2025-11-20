// presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/pages/profile/profile_page.dart';
import 'package:gamer_grove/presentation/pages/social/social_page.dart';
import '../grove/grove_page.dart';
import '../search/search_page.dart';
import 'home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ Index 2 = Home Screen (soll beim Start angezeigt werden)
  int _selectedIndex = 2; // Home als Landing Page

  // ✅ Home Screen ist initial geladen, da er beim Start angezeigt wird
  final Set<int> _visitedPages = {2}; // Nur Home ist initial besucht

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Index 0 - Grove
          _visitedPages.contains(0)
              ? const GrovePage()
              : _buildPlaceholder('Grove', Icons.gamepad_rounded),

          // Index 1 - Social
          _visitedPages.contains(1)
              ? const SocialPage()
              : _buildPlaceholder('Social', Icons.people),

          // Index 2 - Home (Landing Page)
          const HomeContent(), // Immer geladen da Landing Page

          // Index 3 - Search
          _visitedPages.contains(3)
              ? const SearchPage()
              : _buildPlaceholder('Search', Icons.search),

          // Index 4 - Profile
          _visitedPages.contains(4)
              ? const ProfilePage()
              : _buildPlaceholder('Profile', Icons.person),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;

            // ✅ Markiere Page als besucht und logge beim ersten Besuch
            if (!_visitedPages.contains(index)) {
              _visitedPages.add(index);
            }
          });
        },
        destinations: const [
          // Index 0 - Grove
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad_rounded),
            label: 'Grove',
          ),
          // Index 1 - Social
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Social',
          ),
          // Index 2 - Home
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          // Index 3 - Search
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          // Index 4 - Profile
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ✅ Placeholder für noch nicht besuchte Pages
  Widget _buildPlaceholder(String pageName, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading $pageName...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Helper für Debug-Logs
}
