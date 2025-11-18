import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/gift.dart';
import 'package:vital_sphere_mobile/providers/gift_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/utils/base_pagination.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:vital_sphere_mobile/screens/purchases_gifts_details_screen.dart';
import 'package:intl/intl.dart';

class PurchasesGiftsListScreen extends StatefulWidget {
  const PurchasesGiftsListScreen({super.key});

  @override
  State<PurchasesGiftsListScreen> createState() =>
      _PurchasesGiftsListScreenState();
}

class _PurchasesGiftsListScreenState extends State<PurchasesGiftsListScreen> {
  List<Gift> _gifts = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _gifts = [];
          });
        }
        return;
      }

      // Load all gifts and filter client-side by userId
      final result = await giftProvider.get(
        filter: {
          'page': _currentPage,
          'pageSize': 10000, // Get all to filter client-side
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        final allGifts = result.items ?? [];
        final userGifts = allGifts
            .where((gift) => gift.userId == userId)
            .toList();

        // Apply pagination client-side
        final startIndex = _currentPage * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, userGifts.length);
        final paginatedGifts = userGifts.sublist(
          startIndex.clamp(0, userGifts.length),
          endIndex,
        );

        final totalCount = userGifts.length;
        final totalPages = (totalCount / _pageSize).ceil();
        if (totalPages == 0) {
          setState(() {
            _totalPages = 1;
            _gifts = [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _gifts = paginatedGifts;
            _totalPages = totalPages;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Failed to load gifts: ${e.toString()}');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadGifts();
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadGifts,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
              ),
            )
          : _gifts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No gifts found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your gifts will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _gifts.length,
                        itemBuilder: (context, index) {
                          final gift = _gifts[index];
                          return _buildGiftCard(gift);
                        },
                      ),
                    ),
                    BasePagination(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      onPrevious: _currentPage > 0
                          ? () => _onPageChanged(_currentPage - 1)
                          : null,
                      onNext: _currentPage < _totalPages - 1
                          ? () => _onPageChanged(_currentPage + 1)
                          : null,
                    ),
                  ],
                ),
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchasesGiftsDetailsScreen(gift: gift),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gift Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BasePictureCover(
                  base64: gift.wellnessBoxImage,
                  size: 80,
                  fallbackIcon: Icons.card_giftcard_rounded,
                ),
              ),
              const SizedBox(width: 16),
              // Gift Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gift.wellnessBoxName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(gift.giftStatusName)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            gift.giftStatusName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(gift.giftStatusName),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(gift.giftedAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
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
}

