import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/appointment.dart';
import 'package:vital_sphere_desktop/model/search_result.dart';
import 'package:vital_sphere_desktop/providers/appointment_provider.dart';
import 'package:vital_sphere_desktop/screens/appointment_details_screen.dart';
import 'package:vital_sphere_desktop/utils/base_pagination.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late AppointmentProvider appointmentProvider;

  final TextEditingController userFullNameController = TextEditingController();
  final TextEditingController wellnessServiceNameController = TextEditingController();

  SearchResult<Appointment>? appointments;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      if (userFullNameController.text.isNotEmpty) 
        'userFullName': userFullNameController.text,
      if (wellnessServiceNameController.text.isNotEmpty) 
        'wellnessServiceName': wellnessServiceNameController.text,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await appointmentProvider.get(filter: filter);
    setState(() {
      appointments = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appointmentProvider = context.read<AppointmentProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Appointments Management',
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'User Full Name',
                    prefixIcon: Icons.person,
                  ),
                  controller: userFullNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Wellness Service Name',
                    prefixIcon: Icons.spa_outlined,
                  ),
                  controller: wellnessServiceNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      userFullNameController.clear();
                      setState(() {
                        wellnessServiceNameController.clear();
                      });
                      _performSearch(page: 0);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = appointments == null || appointments!.items == null || appointments!.items!.isEmpty;
    final int totalCount = appointments?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.calendar_today_outlined,
            title: "Appointments",
            width: 1400,
            height: 423,
            columnWidths: [
              120,  // Image
              180,  // User Name
              250,  // Wellness Service Name
              280,  // Notes
              140,  // Scheduled At
              120,  // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  "Image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "User Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Wellness Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Notes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Scheduled At",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : appointments!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            e.wellnessServiceImage != null && e.wellnessServiceImage!.isNotEmpty
                                ? Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(e.wellnessServiceImage!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.spa,
                                              color: Colors.grey[400],
                                              size: 30,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.spa,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
                                  ),
                          ),
                          DataCell(
                            Text(
                              e.userName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.wellnessServiceName,
                              style: const TextStyle(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              e.notes ?? 'No notes',
                              maxLines: 1,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatDate(e.scheduledAt),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AppointmentDetailsScreen(appointment: e),
                                          settings: const RouteSettings(
                                            name: 'AppointmentDetailsScreen',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF3182CE), // Info Blue
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
            emptyIcon: Icons.calendar_today,
            emptyText: "No appointments found.",
            emptySubtext: "Try adjusting your search criteria.",
          ),
          const SizedBox(height: 30),
          BasePagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: isFirstPage
                ? null
                : () => _performSearch(page: _currentPage - 1),
            onNext: isLastPage
                ? null
                : () => _performSearch(page: _currentPage + 1),
            showPageSizeSelector: true,
            pageSize: _pageSize,
            pageSizeOptions: _pageSizeOptions,
            onPageSizeChanged: (newSize) {
              if (newSize != null && newSize != _pageSize) {
                _performSearch(page: 0, pageSize: newSize);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

