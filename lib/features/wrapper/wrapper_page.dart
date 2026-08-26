import 'package:flutter/material.dart' hide Badge;
import 'package:animations/animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/features/cart/presentation/cart_page.dart';
import 'package:mandalar_x/features/explore/presentation/explore_page.dart';
import 'package:mandalar_x/features/home/presentation/home_page.dart';
import 'package:mandalar_x/features/profile/presentation/profile_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = const [
    HomePage(),
    ExplorePage(),
    CartPage(),
    ProfilePage(),
  ];

  final Color backgroundColor = Colors.white;
  final Color selectedNavColor = Colors.blue;
  final Color unselectedNavColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) async {
    await _scaleController.forward();
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    await _scaleController.reverse();
  }

  Widget _buildPageTransition(Widget child, int index) {
    final isForward = index > _previousIndex;

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      reverse: !isForward,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: isForward
                    ? const Offset(1.0, 0.0)
                    : const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(index), child: child),
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.098,
          child: BottomNavigationBar(
            backgroundColor: AppColors.appBackground,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            elevation: 0,
            items: [
              _buildNavItem(icon: LineIcons.home, label: 'Home', index: 0),
              _buildNavItem(icon: LineIcons.fire, label: 'Explore', index: 1),
              _buildNavItem(
                icon: LineIcons.shoppingCart,
                label: 'Cart',
                index: 2,
              ),
              _buildNavItem(icon: LineIcons.user, label: 'Me', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = _currentIndex == index ? _scaleAnimation.value : 1.0;
          return Transform.scale(scale: scale, child: Icon(icon));
        },
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 25, color: Colors.white),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.fastOutSlowIn,
        switchOutCurve: Curves.fastOutSlowIn,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildPageTransition(_pages[_currentIndex], _currentIndex),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
