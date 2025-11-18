import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTileTap;

  const HomeScreen({
    super.key,
    required this.onTileTap,
  });

  final List<Map<String, dynamic>> _homeTiles = const [
    {
      'title': 'Home',
      'icon': Icons.home_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF38A169)],
      'index': 0,
    },
    {
      'title': 'Services',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF48BB78)],
      'index': 1,
    },
    {
      'title': 'Products',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF38A169)],
      'index': 2,
    },
    {
      'title': 'Reviews',
      'icon': Icons.rate_review_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF48BB78)],
      'index': 3,
    },
    {
      'title': 'Purchases',
      'icon': Icons.shopping_cart_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF38A169)],
      'index': 4,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_rounded,
      'color': Color(0xFF2F855A),
      'gradient': [Color(0xFF2F855A), Color(0xFF48BB78)],
      'index': 5,
    },
  ];

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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF163A2A),
                      Color(0xFF20523A),
                      Color(0xFF2F855A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F855A).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to VitalSphere',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your wellness journey starts here',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Access Tiles
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Grid of Tiles
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _homeTiles.length,
                itemBuilder: (context, index) {
                  final tile = _homeTiles[index];
                  return _buildHomeTile(tile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTile(Map<String, dynamic> tile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTileTap(tile['index'] as int),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: (tile['gradient'] as List<Color>),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (tile['color'] as Color).withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  tile['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tile['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

