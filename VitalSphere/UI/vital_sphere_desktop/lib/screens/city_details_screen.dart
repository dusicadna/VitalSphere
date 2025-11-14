import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/city.dart';

class CityDetailsScreen extends StatelessWidget {
  final City city;

  const CityDetailsScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'City Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildCityDetails(context),
      ),
    );
  }

  Widget _buildCityDetails(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Go back',
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_city_outlined,
                      size: 32,
                      color: Color(0xFF2F855A),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'City Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F855A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // City icon and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2F855A),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        size: 64,
                        color: Color(0xFF2F855A),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Basic city info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'City ID: ${city.id}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Detailed information grid
                _buildInfoGrid(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'City Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F855A),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_city_outlined,
                label: 'City Name',
                value: city.name,
                iconColor: const Color(0xFF2F855A),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.tag_outlined,
                label: 'City ID',
                value: city.id.toString(),
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
