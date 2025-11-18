import 'package:flutter/material.dart';
import 'package:vital_sphere_mobile/model/appointment.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:intl/intl.dart';

class PurchasesServicesDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const PurchasesServicesDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Service Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2F855A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF163A2A),
                    const Color(0xFF20523A),
                    const Color(0xFF2F855A),
                  ],
                ),
              ),
              child: Center(
                child: BasePictureCover(
                  base64: appointment.wellnessServiceImage,
                  size: 200,
                  fallbackIcon: Icons.spa_rounded,
                ),
              ),
            ),

            // Service Information Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F855A).withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Text(
                    appointment.wellnessServiceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scheduled Date & Time
                  _buildInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Scheduled Date',
                    value: DateFormat('EEEE, MMMM dd, yyyy')
                        .format(appointment.scheduledAt),
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Scheduled Time',
                    value: DateFormat('hh:mm a').format(appointment.scheduledAt),
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.person_rounded,
                    label: 'User',
                    value: appointment.userName,
                    iconColor: const Color(0xFF2F855A),
                  ),
                  if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.note_rounded,
                      label: 'Notes',
                      value: appointment.notes!,
                      iconColor: const Color(0xFF2F855A),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.event_available_rounded,
                    label: 'Created At',
                    value: DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(appointment.createdAt),
                    iconColor: Colors.grey[600]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

