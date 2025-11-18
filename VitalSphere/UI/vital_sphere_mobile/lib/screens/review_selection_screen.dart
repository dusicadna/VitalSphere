import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/appointment.dart';
import 'package:vital_sphere_mobile/model/review.dart';
import 'package:vital_sphere_mobile/providers/appointment_provider.dart';
import 'package:vital_sphere_mobile/providers/review_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:vital_sphere_mobile/utils/base_pagination.dart';
import 'package:vital_sphere_mobile/screens/review_details_screen.dart';
import 'package:intl/intl.dart';

class ReviewSelectionScreen extends StatefulWidget {
  const ReviewSelectionScreen({super.key});

  @override
  State<ReviewSelectionScreen> createState() => _ReviewSelectionScreenState();
}

class _ReviewSelectionScreenState extends State<ReviewSelectionScreen> {
  List<Appointment> _appointments = [];
  List<Appointment> _unreviewedAppointments = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

      // Load user's appointments
      final appointmentsResult = await appointmentProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
          'userId': UserProvider.currentUser!.id,
        },
      );

      // Load ALL reviews to check which appointments have reviews
      // Since it's one-to-one relationship, we need to check all reviews for appointments
      final allReviewsResult = await reviewProvider.get(
        filter: {
          'page': 0,
          'pageSize': 10000, // Get all reviews to check appointments
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _appointments = appointmentsResult.items ?? [];
          
          // Filter appointments that don't have ANY reviews (one-to-one relationship)
          final allReviewedAppointmentIds = (allReviewsResult.items ?? [])
              .map((r) => r.appointmentId)
              .toSet();
          
          _unreviewedAppointments = _appointments
              .where((appointment) => !allReviewedAppointmentIds.contains(appointment.id))
              .toList();

          final totalCount = _unreviewedAppointments.length;
          _totalPages = (totalCount / _pageSize).ceil();
          if (_totalPages == 0) _totalPages = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }


  Future<void> _createReviewForAppointment(Appointment appointment) async {
    // Double-check that this appointment doesn't already have a review
    // Check by querying reviews for this specific appointment
    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final existingReviews = await reviewProvider.get(
        filter: {
          'appointmentId': appointment.id,
          'page': 0,
          'pageSize': 1,
          'includeTotalCount': false,
        },
      );
      
      if (existingReviews.items != null && existingReviews.items!.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("This appointment already has a review. Please edit the existing review instead."),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          // Reload data to refresh the list
          await _loadData();
        }
        return;
      }
    } catch (e) {
      // If check fails, proceed anyway - backend will validate
    }

    // Create a new review object for this appointment
    final newReview = Review(
      id: 0,
      rating: 0,
      comment: null,
      createdAt: DateTime.now(),
      wellnessServiceId: appointment.wellnessServiceId,
      wellnessServiceName: appointment.wellnessServiceName,
      userId: UserProvider.currentUser!.id,
      userFullName: UserProvider.currentUser!.firstName + ' ' + UserProvider.currentUser!.lastName,
      appointmentId: appointment.id,
      wellnessServiceImage: appointment.wellnessServiceImage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsScreen(review: newReview),
      ),
    ).then((_) => _loadData());
  }

  List<Appointment> get _paginatedAppointments {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _unreviewedAppointments.length);
    return _unreviewedAppointments.sublist(start.clamp(0, _unreviewedAppointments.length), end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Select Service to Review",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2F855A),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2F855A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
                    ),
                  )
                : _unreviewedAppointments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: const Color(0xFF2F855A),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _paginatedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _paginatedAppointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        ),
                      ),
          ),
          if (!_isLoading && _unreviewedAppointments.isNotEmpty)
            BasePagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onNext: () {
                if (_currentPage < _totalPages - 1) {
                  _onPageChanged(_currentPage + 1);
                }
              },
              onPrevious: () {
                if (_currentPage > 0) {
                  _onPageChanged(_currentPage - 1);
                }
              },
            ),
          if (!_isLoading && _unreviewedAppointments.isNotEmpty)
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Color(0xFF2F855A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "All Services Reviewed",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "You've reviewed all your wellness service appointments!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _createReviewForAppointment(appointment),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                BasePictureCover(
                  base64: appointment.wellnessServiceImage,
                  size: 80,
                  fallbackIcon: Icons.spa_rounded,
                  borderColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2F855A),
                  backgroundColor: const Color(0xFFE8F5E9),
                  shape: BoxShape.rectangle,
                ),
                const SizedBox(width: 16),
                // Service Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.wellnessServiceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(appointment.scheduledAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rate_review_rounded,
                              size: 16,
                              color: Color(0xFF2F855A),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F855A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

