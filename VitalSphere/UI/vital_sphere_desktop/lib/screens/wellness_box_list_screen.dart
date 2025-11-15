import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_box.dart';
import 'package:vital_sphere_desktop/model/search_result.dart';
import 'package:vital_sphere_desktop/providers/wellness_box_provider.dart';
import 'package:vital_sphere_desktop/screens/wellness_box_details_screen.dart';
import 'package:vital_sphere_desktop/screens/wellness_box_edit_screen.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';
import 'package:vital_sphere_desktop/utils/base_pagination.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class WellnessBoxListScreen extends StatefulWidget {
  const WellnessBoxListScreen({super.key});

  @override
  State<WellnessBoxListScreen> createState() => _WellnessBoxListScreenState();
}

class _WellnessBoxListScreenState extends State<WellnessBoxListScreen> {
  late WellnessBoxProvider wellnessBoxProvider;
  TextEditingController nameController = TextEditingController();
  bool? selectedIsActive;

  SearchResult<WellnessBox>? wellnessBoxes;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      if (nameController.text.isNotEmpty) 'name': nameController.text,
      if (selectedIsActive != null) 'isActive': selectedIsActive,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    debugPrint(filter.toString());
    var boxesResult = await wellnessBoxProvider.get(filter: filter);
    debugPrint(boxesResult.items?.firstOrNull?.name);
    setState(() {
      this.wellnessBoxes = boxesResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      wellnessBoxProvider = context.read<WellnessBoxProvider>();

      await _performSearch(page: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Wellness Boxes Management",
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<bool?>(
              decoration: customTextFieldDecoration(
                'Status',
                prefixIcon: Icons.toggle_on,
              ),
              value: selectedIsActive,
              items: const [
                DropdownMenuItem<bool?>(value: null, child: Text('All')),
                DropdownMenuItem<bool>(value: true, child: Text('Active')),
                DropdownMenuItem<bool>(value: false, child: Text('Inactive')),
              ],
              onChanged: (bool? newValue) {
                setState(() {
                  selectedIsActive = newValue;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text("Search"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WellnessBoxEditScreen(),
                  settings: const RouteSettings(name: 'WellnessBoxEditScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F855A),
              foregroundColor: Colors.white,
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add Box')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = wellnessBoxes == null ||
        wellnessBoxes!.items == null ||
        wellnessBoxes!.items!.isEmpty;
    final int totalCount = wellnessBoxes?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.inventory_2_outlined,
            title: "Wellness Boxes",
            width: 1400,
            height: 423,
            columnWidths: [
              120,  // Image
              250,  // Name
              510,  // Description
     
              90,  // Status
              150,  // Actions
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
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
       
              DataColumn(
                label: Text(
                  "Active",
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
                : wellnessBoxes!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            e.image != null && e.image!.isNotEmpty
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
                                        base64Decode(e.image!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.inventory_2,
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
                                      Icons.inventory_2,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
                                  ),
                          ),
                          DataCell(
                            Text(e.name, style: const TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              e.description ?? '-',
                              style: const TextStyle(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
             
                          DataCell(
                            Icon(
                              e.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: e.isActive ? Colors.green : Colors.red,
                              size: 20,
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
                                              WellnessBoxDetailsScreen(box: e),
                                          settings: const RouteSettings(
                                            name: 'WellnessBoxDetailsScreen',
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
                                const SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WellnessBoxEditScreen(box: e),
                                          settings: const RouteSettings(
                                            name: 'WellnessBoxEditScreen',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFFDD6B20), // Amber/Orange for Edit
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
            emptyIcon: Icons.inventory_2,
            emptyText: "No wellness boxes found.",
            emptySubtext: "Try adjusting your search or add a new box.",
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
}

