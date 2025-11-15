import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/appointment.dart';
import 'package:vital_sphere_desktop/utils/base_picture_cover.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Appointment Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildAppointmentDetails(context),
      ),
    );
  }

  Widget _buildAppointmentDetails(BuildContext context) {
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
                      Icons.calendar_today_outlined,
                      size: 32,
                      color: Color(0xFF2F855A),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Appointment Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F855A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Wellness service image and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wellness service image
                    appointment.wellnessServiceImage != null && appointment.wellnessServiceImage!.isNotEmpty
                        ? BasePictureCover(
                            base64: appointment.wellnessServiceImage,
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

                    // Basic appointment info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.wellnessServiceName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Appointment for ${appointment.userName}',
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
          'Appointment Details',
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
                icon: Icons.person_outline,
                label: 'User',
                value: appointment.userName,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.spa_outlined,
                label: 'Wellness Service',
                value: appointment.wellnessServiceName,
                iconColor: const Color(0xFF2F855A),
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
                label: 'Scheduled At',
                value: _formatDate(appointment.scheduledAt),
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.access_time_outlined,
                label: 'Created At',
                value: _formatDate(appointment.createdAt),
                iconColor: Colors.blue,
              ),
            ),
          ],
        ),
        if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
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
                          const Icon(
                            Icons.note_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notes',
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
                        appointment.notes!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

