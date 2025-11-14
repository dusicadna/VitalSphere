import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_service.dart';
import 'package:vital_sphere_desktop/utils/base_picture_cover.dart';

class WellnessServiceDetailsScreen extends StatelessWidget {
  final WellnessService service;

  const WellnessServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Wellness Service Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildServiceDetails(context),
      ),
    );
  }

  Widget _buildServiceDetails(BuildContext context) {
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
                      Icons.spa_outlined,
                      size: 32,
                      color: Color(0xFF2F855A),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Wellness Service Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F855A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Service image/icon and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service image or icon
                    service.image != null && service.image!.isNotEmpty
                        ? BasePictureCover(
                            base64: service.image,
                            size: 120,
                            fallbackIcon: Icons.spa,
                            borderColor: const Color(0xFF2F855A),
                            iconColor: const Color(0xFF2F855A),
                            backgroundColor: const Color(0xFFE8F5E9),
                            showShadow: true,
                          )
                        : Container(
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
                              Icons.spa,
                              size: 64,
                              color: Color(0xFF2F855A),
                            ),
                          ),
                    const SizedBox(width: 24),

                    // Basic service info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F855A),
                            ),
                          ),
                          if (service.durationMinutes != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${service.durationMinutes} minutes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: service.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  service.isActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: service.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  service.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: service.isActive
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
          'Service Details',
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
                icon: Icons.spa_outlined,
                label: 'Service Name',
                value: service.name,
                iconColor: const Color(0xFF2F855A),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.tag_outlined,
                label: 'Service ID',
                value: service.id.toString(),
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.attach_money_outlined,
                label: 'Price',
                value: '\$${service.price.toStringAsFixed(2)}',
                iconColor: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.access_time_outlined,
                label: 'Duration',
                value: service.durationMinutes != null
                    ? '${service.durationMinutes} minutes'
                    : 'Not specified',
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.category_outlined,
                label: 'Category',
                value: service.wellnessServiceCategoryName,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Created At',
                value: _formatDate(service.createdAt),
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (service.description != null && service.description!.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: service.description!,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.toggle_on_outlined,
                label: 'Status',
                value: service.isActive ? 'Active' : 'Inactive',
                iconColor: service.isActive ? Colors.green : Colors.red,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

