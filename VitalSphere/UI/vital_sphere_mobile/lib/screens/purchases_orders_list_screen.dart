import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/order.dart';
import 'package:vital_sphere_mobile/providers/order_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/utils/base_pagination.dart';
import 'package:vital_sphere_mobile/screens/purchases_orders_details_screen.dart';
import 'package:intl/intl.dart';

class PurchasesOrdersListScreen extends StatefulWidget {
  const PurchasesOrdersListScreen({super.key});

  @override
  State<PurchasesOrdersListScreen> createState() =>
      _PurchasesOrdersListScreenState();
}

class _PurchasesOrdersListScreenState extends State<PurchasesOrdersListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _orders = [];
          });
        }
        return;
      }

      final result = await orderProvider.get(
        filter: {
          'page': _currentPage,
          'pageSize': _pageSize,
          'includeTotalCount': true,
          'userId': userId,
        },
      );

      if (mounted) {
        final orders = result.items ?? [];
        final totalCount = result.totalCount ?? 0;
        final totalPages = (totalCount / _pageSize).ceil();
        if (totalPages == 0) {
          setState(() {
            _totalPages = 1;
            _orders = [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _orders = orders;
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
        _showErrorSnackbar('Failed to load orders: ${e.toString()}');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadOrders();
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
      onRefresh: _loadOrders,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
              ),
            )
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your orders will appear here',
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
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order);
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

  Widget _buildOrderCard(Order order) {
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
                  PurchasesOrdersDetailsScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Order ID
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2F855A),
                              const Color(0xFF38A169),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: order.isActive
                              ? const Color(0xFF48BB78).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: order.isActive
                                ? const Color(0xFF48BB78)
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Arrow Icon
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Order Details
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${order.totalItems} item${order.totalItems != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attach_money_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F855A),
                    ),
                  ),
                ],
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
                    DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

