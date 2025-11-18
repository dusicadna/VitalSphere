import 'package:flutter/material.dart';
import 'package:vital_sphere_mobile/model/gift.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:intl/intl.dart';

class PurchasesGiftsDetailsScreen extends StatefulWidget {
  final Gift gift;

  const PurchasesGiftsDetailsScreen({
    super.key,
    required this.gift,
  });

  @override
  State<PurchasesGiftsDetailsScreen> createState() =>
      _PurchasesGiftsDetailsScreenState();
}

class _PurchasesGiftsDetailsScreenState
    extends State<PurchasesGiftsDetailsScreen> {

  Color _getStatusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'picked up':
      case 'pickedup':
        return const Color(0xFF48BB78);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gift = widget.gift;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Gift Details',
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
            // Gift Image
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
                  base64: gift.wellnessBoxImage,
                  size: 200,
                  fallbackIcon: Icons.card_giftcard_rounded,
                ),
              ),
            ),

            // Gift Information Card
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
                  // Gift Name
                  Text(
                    gift.wellnessBoxName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(gift.giftStatusName)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(gift.giftStatusName),
                          size: 18,
                          color: _getStatusColor(gift.giftStatusName),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          gift.giftStatusName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(gift.giftStatusName),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    icon: Icons.person_rounded,
                    label: 'Recipient',
                    value: gift.userName,
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Gift ID',
                    value: '#${gift.id}',
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.event_available_rounded,
                    label: 'Gifted At',
                    value: DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(gift.giftedAt),
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

  IconData _getStatusIcon(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'pending':
        return Icons.pending_rounded;
      case 'picked up':
      case 'pickedup':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

