import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/city.dart';
import 'package:vital_sphere_desktop/model/search_result.dart';
import 'package:vital_sphere_desktop/providers/city_provider.dart';
import 'package:vital_sphere_desktop/screens/city_details_screen.dart';
import 'package:vital_sphere_desktop/screens/city_edit_screen.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';
import 'package:vital_sphere_desktop/utils/base_pagination.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;
  TextEditingController nameController = TextEditingController();

  SearchResult<City>? cities;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for cities with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var cities = await cityProvider.get(filter: filter);
    debugPrint(cities.items?.firstOrNull?.name);
    setState(() {
      this.cities = cities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();

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
      title: "Cities Management",
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
      padding: EdgeInsets.all(10),
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
          SizedBox(width: 10),

          ElevatedButton(onPressed: _performSearch, child: Text("Search")),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CityEditScreen(),
                  settings: const RouteSettings(name: 'CityEditScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F855A), // Green
              foregroundColor: Colors.white, // white text & icon
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add City')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        cities == null || cities!.items == null || cities!.items!.isEmpty;
    final int totalCount = cities?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.location_city_outlined,
            title: "Cities",
            width: 400,
            height: 423,
            columns: const [
              DataColumn(
                label: Text(
                  "Name",
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
                : cities!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(e.name, style: const TextStyle(fontSize: 15)),
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
                                                CityDetailsScreen(city: e),
                                            settings: const RouteSettings(
                                              name: 'CityDetailsScreen',
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
                                                CityEditScreen(city: e),
                                            settings: const RouteSettings(
                                              name: 'CityEditScreen',
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
            emptyIcon: Icons.location_city,
            emptyText: "No cities found.",
            emptySubtext: "Try adjusting your search or add a new city.",
          ),
          SizedBox(height: 30),
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
