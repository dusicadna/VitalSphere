import 'package:flutter/material.dart';

import 'package:vital_sphere_mobile/screens/purchases_services_list_screen.dart';
import 'package:vital_sphere_mobile/screens/purchases_orders_list_screen.dart';
import 'package:vital_sphere_mobile/screens/purchases_gifts_list_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  int _selectedTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // 3-Way Switch
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F855A).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSwitchTab(
                    index: 0,
                    label: 'Services',
                    icon: Icons.spa_rounded,
                  ),
                ),
                Expanded(
                  child: _buildSwitchTab(
                    index: 1,
                    label: 'Orders',
                    icon: Icons.shopping_bag_rounded,
                  ),
                ),
                Expanded(
                  child: _buildSwitchTab(
                    index: 2,
                    label: 'Gifts',
                    icon: Icons.card_giftcard_rounded,
                  ),
                ),
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                PurchasesServicesListScreen(),
                PurchasesOrdersListScreen(),
                PurchasesGiftsListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2F855A),
                    const Color(0xFF38A169),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF718096),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF718096),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

