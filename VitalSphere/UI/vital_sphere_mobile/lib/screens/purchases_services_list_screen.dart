import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/appointment.dart';
import 'package:vital_sphere_mobile/providers/appointment_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/utils/base_pagination.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:vital_sphere_mobile/screens/purchases_services_details_screen.dart';
import 'package:intl/intl.dart';

class PurchasesServicesListScreen extends StatefulWidget {
  const PurchasesServicesListScreen({super.key});

  @override
  State<PurchasesServicesListScreen> createState() =>
      _PurchasesServicesListScreenState();
}

class _PurchasesServicesListScreenState
    extends State<PurchasesServicesListScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _appointments = [];
          });
        }
        return;
      }

      // Load all appointments and filter client-side by userId
      final result = await appointmentProvider.get(
        filter: {
          'page': _currentPage,
          'pageSize': 10000, // Get all to filter client-side
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        final allAppointments = result.items ?? [];
        final userAppointments = allAppointments
            .where((appointment) => appointment.userId == userId)
            .toList();

        // Apply pagination client-side
        final startIndex = _currentPage * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, userAppointments.length);
        final paginatedAppointments = userAppointments.sublist(
          startIndex.clamp(0, userAppointments.length),
          endIndex,
        );

        final totalCount = userAppointments.length;
        final totalPages = (totalCount / _pageSize).ceil();
        if (totalPages == 0) {
          setState(() {
            _totalPages = 1;
            _appointments = [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _appointments = paginatedAppointments;
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
        _showErrorSnackbar('Failed to load appointments: ${e.toString()}');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadAppointments();
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
      onRefresh: _loadAppointments,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
              ),
            )
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your service appointments will appear here',
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
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          return _buildAppointmentCard(appointment);
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

  Widget _buildAppointmentCard(Appointment appointment) {
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
              builder: (context) =>
                  PurchasesServicesDetailsScreen(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BasePictureCover(
                  base64: appointment.wellnessServiceImage,
                  size: 80,
                  fallbackIcon: Icons.spa_rounded,
                ),
              ),
              const SizedBox(width: 16),
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.wellnessServiceName,
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
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(appointment.scheduledAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        appointment.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
}

