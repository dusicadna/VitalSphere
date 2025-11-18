import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/appointment.dart';
import 'package:vital_sphere_mobile/model/wellness_service.dart';
import 'package:vital_sphere_mobile/providers/appointment_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/providers/wellness_service_provider.dart';
import 'package:vital_sphere_mobile/screens/appointment_screen.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Function(int) onTileTap;

  const HomeScreen({
    super.key,
    required this.onTileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Appointment> _upcomingAppointments = [];
  Appointment? _nextAppointment;
  WellnessService? _recommendedService;
  bool _isLoading = true;
  Timer? _countdownTimer;
  int _daysUntil = 0;
  int _hoursUntil = 0;
  int _minutesUntil = 0;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadRecommendation();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted && _nextAppointment != null) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    if (_nextAppointment == null) return;

    final now = DateTime.now();
    final scheduledAt = _nextAppointment!.scheduledAt;
    
    if (scheduledAt.isBefore(now)) {
      // Appointment has passed, reload
      _loadAppointments();
      return;
    }

    final difference = scheduledAt.difference(now);
    setState(() {
      _daysUntil = difference.inDays;
      _hoursUntil = difference.inHours % 24;
      _minutesUntil = difference.inMinutes % 60;
    });
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
            _upcomingAppointments = [];
            _nextAppointment = null;
          });
        }
        return;
      }

      // Load all appointments and filter client-side
      final result = await appointmentProvider.get(
        filter: {
          'page': 0,
          'pageSize': 10000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        final now = DateTime.now();
        final allAppointments = result.items ?? [];
        
        // Filter: user's appointments that are upcoming
        final upcoming = allAppointments
            .where((appointment) =>
                appointment.userId == userId &&
                appointment.scheduledAt.isAfter(now))
            .toList();

        // Sort by scheduledAt ascending (closest first)
        upcoming.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        // Take first 3
        final nextThree = upcoming.take(3).toList();
        final next = nextThree.isNotEmpty ? nextThree.first : null;

        setState(() {
          _upcomingAppointments = nextThree;
          _nextAppointment = next;
        });

        _updateCountdown();
        _isLoading = false;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecommendation() async {
    if (!mounted) return;

    final userId = UserProvider.currentUser?.id;
    if (userId == null) return;

    try {
      final wellnessServiceProvider =
          Provider.of<WellnessServiceProvider>(context, listen: false);
      
      final recommendation = await wellnessServiceProvider.getRecommendationForUser(userId);

      if (mounted) {
        setState(() {
          _recommendedService = recommendation;
        });
      }
    } catch (e) {
      // Silently fail - recommendation is optional
    }
  }

  void _handleRecommendedServiceTap() {
    if (_recommendedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentScreen(service: _recommendedService!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadAppointments();
            await _loadRecommendation();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Countdown Section
                if (_nextAppointment != null) ...[
                  _buildCountdownCard(),
                  const SizedBox(height: 24),
                ],

                // Upcoming Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_upcomingAppointments.isNotEmpty)
                      TextButton(
                        onPressed: () => widget.onTileTap(1), // Navigate to Purchases
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF2F855A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Services List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
                      ),
                    ),
                  )
                else if (_upcomingAppointments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
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
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No upcoming services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your upcoming appointments will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ..._upcomingAppointments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final appointment = entry.value;
                    final isNext = appointment.id == _nextAppointment?.id;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < _upcomingAppointments.length - 1 ? 12 : 0),
                      child: _buildServiceCard(appointment, isNext),
                    );
                  }),

                // Recommended Service Section
                if (_recommendedService != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendedServiceCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2F855A),
            const Color(0xFF38A169),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Service In',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nextAppointment?.wellnessServiceName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountdownItem(_daysUntil, 'Days'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildCountdownItem(_hoursUntil, 'Hours'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildCountdownItem(_minutesUntil, 'Minutes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownItem(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Appointment appointment, bool isHighlighted) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(
                color: const Color(0xFF2F855A),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFF2F855A).withOpacity(0.2)
                : const Color(0xFF2F855A).withOpacity(0.1),
            spreadRadius: isHighlighted ? 2 : 1,
            blurRadius: isHighlighted ? 16 : 8,
            offset: Offset(0, isHighlighted ? 6 : 2),
          ),
        ],
      ),
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
                  if (isHighlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F855A), Color(0xFF38A169)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isHighlighted) const SizedBox(height: 6),
                  Text(
                    appointment.wellnessServiceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted
                          ? const Color(0xFF2F855A)
                          : const Color(0xFF1A202C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy')
                            .format(appointment.scheduledAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('hh:mm a').format(appointment.scheduledAt),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedServiceCard() {
    if (_recommendedService == null) return const SizedBox.shrink();

    return InkWell(
      onTap: _handleRecommendedServiceTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F855A),
              Color(0xFF38A169),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F855A).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BasePictureCover(
                  base64: _recommendedService!.image,
                  size: 80,
                  fallbackIcon: Icons.spa_rounded,
                  borderColor: Colors.white.withOpacity(0.3),
                  iconColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendedService!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Based on your preferences',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

