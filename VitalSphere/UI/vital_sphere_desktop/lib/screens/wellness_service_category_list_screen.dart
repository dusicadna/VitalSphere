import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_service_category.dart';
import 'package:vital_sphere_desktop/model/search_result.dart';
import 'package:vital_sphere_desktop/providers/wellness_service_category_provider.dart';
import 'package:vital_sphere_desktop/screens/wellness_service_category_details_screen.dart';
import 'package:vital_sphere_desktop/screens/wellness_service_category_edit_screen.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';
import 'package:vital_sphere_desktop/utils/base_pagination.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class WellnessServiceCategoryListScreen extends StatefulWidget {
  const WellnessServiceCategoryListScreen({super.key});

  @override
  State<WellnessServiceCategoryListScreen> createState() =>
      _WellnessServiceCategoryListScreenState();
}

class _WellnessServiceCategoryListScreenState
    extends State<WellnessServiceCategoryListScreen> {
  late WellnessServiceCategoryProvider wellnessServiceCategoryProvider;
  TextEditingController nameController = TextEditingController();
  bool? selectedIsActive;

  SearchResult<WellnessServiceCategory>? categories;
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
    var categoriesResult =
        await wellnessServiceCategoryProvider.get(filter: filter);
    debugPrint(categoriesResult.items?.firstOrNull?.name);
    setState(() {
      this.categories = categoriesResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      wellnessServiceCategoryProvider =
          context.read<WellnessServiceCategoryProvider>();

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
      title: "Wellness Service Categories Management",
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
                  builder: (context) => const WellnessServiceCategoryEditScreen(),
                  settings: const RouteSettings(
                      name: 'WellnessServiceCategoryEditScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F855A),
              foregroundColor: Colors.white,
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add Category')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        categories == null || categories!.items == null || categories!.items!.isEmpty;
    final int totalCount = categories?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.spa_outlined,
            title: "Wellness Service Categories",
            width: 1200,
            height: 423,
            columnWidths: [
              120,
              200,
              500,
              120,
              150,
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
                  "Status",
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
                : categories!.items!
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
                            Text(e.name, style: const TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              e.description ?? 'No description',
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
                                              WellnessServiceCategoryDetailsScreen(
                                                  category: e),
                                          settings: const RouteSettings(
                                            name: 'WellnessServiceCategoryDetailsScreen',
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
                                              WellnessServiceCategoryEditScreen(
                                                  category: e),
                                          settings: const RouteSettings(
                                            name: 'WellnessServiceCategoryEditScreen',
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
            emptyIcon: Icons.spa,
            emptyText: "No wellness service categories found.",
            emptySubtext:
                "Try adjusting your search or add a new wellness service category.",
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

