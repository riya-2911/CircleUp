import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    _MomentsPage(),
    _MatchesPage(),
    _DiscoverPage(),
    _ConnectionsPage(),
    _YouPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabPressed(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2E5BFF);
    const inactiveColor = Color(0xFF94A3B8);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 118 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 82 + bottomInset,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 22,
              child: Center(
                child: Container(
                  width: 82,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LabeledNavButton(
                    icon: Icons.auto_awesome,
                    label: 'MOMENTS',
                    selected: _selectedIndex == 0,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(0),
                  ),
                  _LabeledNavButton(
                    icon: Icons.favorite,
                    label: 'MATCHES',
                    selected: _selectedIndex == 1,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(1),
                  ),
                  const SizedBox(width: 76),
                  _LabeledNavButton(
                    icon: Icons.groups,
                    label: 'CONNECTIONS',
                    selected: _selectedIndex == 3,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(3),
                  ),
                  _LabeledNavButton(
                    icon: Icons.person,
                    label: 'YOU',
                    selected: _selectedIndex == 4,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CenterNavItem(
                  selected: _selectedIndex == 2,
                  onTap: () => _onTabPressed(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledNavButton extends StatelessWidget {
  const _LabeledNavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 74,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2E5BFF), Color(0xFF5B2EFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E43F5).withOpacity(selected ? 0.5 : 0.32),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 24),
      ),
    );
  }
}

class _MomentsPage extends StatelessWidget {
  const _MomentsPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Moments Page');
  }
}

class _MatchesPage extends StatelessWidget {
  const _MatchesPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Matches Page');
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Discover Page');
  }
}

class _ConnectionsPage extends StatelessWidget {
  const _ConnectionsPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Connections Page');
  }
}

class _YouPage extends StatelessWidget {
  const _YouPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'You Page');
  }
}

class _BlankTabPage extends StatelessWidget {
  const _BlankTabPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}