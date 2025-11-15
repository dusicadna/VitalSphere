import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_box.dart';
import 'package:vital_sphere_desktop/utils/base_picture_cover.dart';

class WellnessBoxDetailsScreen extends StatelessWidget {
  final WellnessBox box;

  const WellnessBoxDetailsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Wellness Box Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildBoxDetails(context),
      ),
    );
  }

  Widget _buildBoxDetails(BuildContext context) {
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
                      Icons.inventory_2_outlined,
                      size: 32,
                      color: Color(0xFF2F855A),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Wellness Box Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F855A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Box image/icon and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Box image or icon
                    box.image != null && box.image!.isNotEmpty
                        ? BasePictureCover(
                            base64: box.image,
                            size: 120,
                            fallbackIcon: Icons.inventory_2,
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
                              Icons.inventory_2,
                              size: 64,
                              color: Color(0xFF2F855A),
                            ),
                          ),
                    const SizedBox(width: 24),

                    // Basic box info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: box.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: box.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  box.isActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: box.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  box.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: box.isActive
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
          'Box Details',
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
                icon: Icons.inventory_2_outlined,
                label: 'Box Name',
                value: box.name,
                iconColor: const Color(0xFF2F855A),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.tag_outlined,
                label: 'Box ID',
                value: box.id.toString(),
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
                icon: Icons.calendar_today_outlined,
                label: 'Created At',
                value: _formatDate(box.createdAt),
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.toggle_on_outlined,
                label: 'Status',
                value: box.isActive ? 'Active' : 'Inactive',
                iconColor: box.isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (box.description != null && box.description!.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: box.description!,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (box.includedItems != null && box.includedItems!.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.list_outlined,
                  label: 'Included Items',
                  value: box.includedItems!,
                  iconColor: Colors.purple,
                ),
              ),
            ],
          ),
        ],
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

