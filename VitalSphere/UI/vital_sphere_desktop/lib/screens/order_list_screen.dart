import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/order.dart';
import 'package:vital_sphere_desktop/model/search_result.dart';
import 'package:vital_sphere_desktop/providers/order_provider.dart';
import 'package:vital_sphere_desktop/screens/order_details_screen.dart';
import 'package:vital_sphere_desktop/utils/base_pagination.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late OrderProvider orderProvider;

  final TextEditingController userFullNameController = TextEditingController();
  bool? selectedIsActive;

  SearchResult<Order>? orders;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      if (userFullNameController.text.isNotEmpty) 
        'userFullName': userFullNameController.text,
      if (selectedIsActive != null) 'isActive': selectedIsActive,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await orderProvider.get(filter: filter);
    setState(() {
      orders = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderProvider = context.read<OrderProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Orders Management',
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
                'User Full Name',
                prefixIcon: Icons.person,
              ),
              controller: userFullNameController,
              onSubmitted: (_) => _performSearch(page: 0),
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
            child: const Text('Search'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              userFullNameController.clear();
              setState(() {
                selectedIsActive = null;
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
    );
  }

  Widget _buildResultView() {
    final isEmpty = orders == null || orders!.items == null || orders!.items!.isEmpty;
    final int totalCount = orders?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.shopping_cart_outlined,
            title: "Orders",
            width: 1400,
            height: 423,
            columnWidths: [
              200,  // Order ID

              200,  // User Name
              140,  // Total Amount
              100,  // Total Items
              200,  // Created At
              100,  // Status
              120,  // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  "Order Number",
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
                  "Total Amount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Items",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Created At",
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
                : orders!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'NUM-00${e.id}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F855A),
                              ),
                            ),
                          ),
                      
                          DataCell(
                            Text(
                              e.userFullName,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              '\$${e.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.totalItems.toString(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatDate(e.createdAt),
                              style: const TextStyle(fontSize: 15),
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
                                              OrderDetailsScreen(order: e),
                                          settings: const RouteSettings(
                                            name: 'OrderDetailsScreen',
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
            emptyIcon: Icons.shopping_cart,
            emptyText: "No orders found.",
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

