import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../create_rug/create_rug_wizard_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _navigateToCreateFlow();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToCreateFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateRugWizardScreen(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onNavigateToExplore: () => setState(() => _currentIndex = 1));
      case 1:
        return const ExploreScreen();
      case 2:
        return Container(); // Central button opens wizard as full modal
      case 3:
        return const OrdersScreen();
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(onNavigateToExplore: () => setState(() => _currentIndex = 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: [
          HomeScreen(onNavigateToExplore: () => setState(() => _currentIndex = 1)),
          const ExploreScreen(),
          Container(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateFlow,
        elevation: 6,
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text(
          'Crear',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkCard : AppColors.cardLight,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
              _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explorar'),
              const SizedBox(width: 48), // Gap for middle FAB
              _buildNavItem(3, Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Pedidos'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.terracotta;
    final inactiveColor = AppColors.warmGray;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
