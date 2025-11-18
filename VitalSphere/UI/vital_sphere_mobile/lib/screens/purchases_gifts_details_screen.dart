import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/gift.dart';
import 'package:vital_sphere_mobile/providers/gift_provider.dart';
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
  bool _isLoading = false;
  Gift? _currentGift;

  @override
  void initState() {
    super.initState();
    _currentGift = widget.gift;
  }

  Future<void> _markAsPickedUp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      final updatedGift = await giftProvider.markAsPickedUp(_currentGift!.id);

      if (mounted) {
        setState(() {
          _currentGift = updatedGift;
          _isLoading = false;
        });
        _showSuccessSnackbar('Gift marked as picked up successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Failed to mark gift as picked up: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF48BB78),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
    final gift = _currentGift ?? widget.gift;
    final canPickUp = gift.giftStatusName.toLowerCase() != 'picked up' &&
        gift.giftStatusName.toLowerCase() != 'pickedup';

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

            // Pick Up Button (if applicable)
            if (canPickUp)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2F855A),
                      const Color(0xFF38A169),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F855A).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _markAsPickedUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mark as Picked Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

