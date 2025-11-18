import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/wellness_service.dart';
import 'package:vital_sphere_mobile/model/wellness_service_category.dart';
import 'package:vital_sphere_mobile/providers/wellness_service_provider.dart';
import 'package:vital_sphere_mobile/screens/appointment_screen.dart';
import 'dart:convert';

class ServiceListScreen extends StatefulWidget {
  final WellnessServiceCategory category;

  const ServiceListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<WellnessService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final serviceProvider =
          Provider.of<WellnessServiceProvider>(context, listen: false);

      // Load all services and filter by category client-side
      final result = await serviceProvider.get(
        filter: {
          'page': 0,
          'pageSize': 10000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        final allServices = result.items ?? [];
        final categoryServices = allServices
            .where((service) =>
                service.wellnessServiceCategoryId == widget.category.id &&
                service.isActive)
            .toList();

        setState(() {
          _services = categoryServices;
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

  void _handleCreateAppointment(WellnessService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aspect ratio: 800x448 = 1.786:1
    final aspectRatio = 800 / 448;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
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
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
                ),
              )
            : _services.isEmpty
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
                          'No services found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Services for this category will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildCategoryImage(widget.category.image),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (widget.category.description != null &&
                                      widget.category.description!.isNotEmpty)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          widget.category.description!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Available Services',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._services.map((service) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildServiceCard(service, aspectRatio),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildServiceCard(WellnessService service, double aspectRatio) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image - Main Focus
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildServiceImage(service.image),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Text(
                        service.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Service Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (service.description != null &&
                    service.description!.isNotEmpty)
                  Text(
                    service.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (service.description != null &&
                    service.description!.isNotEmpty)
                  const SizedBox(height: 12),
                // Price and Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2F855A), Color(0xFF38A169)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (service.durationMinutes != null) ...[
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.durationMinutes} min',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Create Appointment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleCreateAppointment(service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F855A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Create Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: Icon(
            Icons.spa_rounded,
            size: 80,
            color: Color(0xFF2F855A),
          ),
        ),
      );
    }

    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8F5E9),
            child: const Center(
              child: Icon(
                Icons.spa_rounded,
                size: 80,
                color: Color(0xFF2F855A),
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: Icon(
            Icons.spa_rounded,
            size: 80,
            color: Color(0xFF2F855A),
          ),
        ),
      );
    }
  }

  Widget _buildServiceImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: Icon(
            Icons.spa_rounded,
            size: 80,
            color: Color(0xFF2F855A),
          ),
        ),
      );
    }

    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8F5E9),
            child: const Center(
              child: Icon(
                Icons.spa_rounded,
                size: 80,
                color: Color(0xFF2F855A),
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: Icon(
            Icons.spa_rounded,
            size: 80,
            color: Color(0xFF2F855A),
          ),
        ),
      );
    }
  }
}

