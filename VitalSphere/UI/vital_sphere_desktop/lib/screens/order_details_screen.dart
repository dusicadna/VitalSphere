import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/order.dart';
import 'package:vital_sphere_desktop/utils/base_picture_cover.dart';
import 'package:vital_sphere_desktop/utils/base_table.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Order Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildOrderDetails(context),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildOrderInfo(context),
            const SizedBox(height: 24),
            _buildOrderItemsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Go back',
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 32,
                  color: Color(0xFF2F855A),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Order Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F855A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User image
                order.userImage != null && order.userImage!.isNotEmpty
                    ? BasePictureCover(
                        base64: order.userImage!,
                        size: 120,
                        fallbackIcon: Icons.person,
                        borderColor: const Color(0xFF2F855A),
                        iconColor: const Color(0xFF2F855A),
                        backgroundColor: const Color(0xFFE8F5E9),
                        showShadow: true,
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2F855A),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Color(0xFF2F855A),
                        ),
                      ),
                const SizedBox(width: 24),

                // Basic order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order for ${order.userFullName}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: order.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: order.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  order.isActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: order.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  order.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: order.isActive
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F855A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2F855A),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF2F855A),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Detailed information grid
            _buildInfoGrid(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F855A),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.person_outline,
                label: 'User',
                value: order.userFullName,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.attach_money_outlined,
                label: 'Total Amount',
                value: '\$${order.totalAmount.toStringAsFixed(2)}',
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Total Items',
                value: order.totalItems.toString(),
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Created At',
                value: _formatDate(order.createdAt),
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.toggle_on_outlined,
                label: 'Status',
                value: order.isActive ? 'Active' : 'Inactive',
                iconColor: order.isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsTable() {
    if (order.orderItems.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No items in this order',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 24,
                  color: Color(0xFF2F855A),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F855A),
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.orderItems.length} item${order.orderItems.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BaseTable(
              icon: Icons.shopping_bag_outlined,
              title: "Items",
              width: 1200,
              height: 400,
              columnWidths: [
                120,  // Image
                530,  // Product Name
                100,  // Quantity
                120,  // Unit Price
                150,  // Total Price
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
                    "Product Name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Qty",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  tooltip: "Quantity",
                ),
                DataColumn(
                  label: Text(
                    "Unit Price",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Total Price",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
              rows: order.orderItems
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          item.productPicture != null && item.productPicture!.isNotEmpty
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
                                      base64Decode(item.productPicture!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.shopping_bag,
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
                                    Icons.shopping_bag,
                                    color: Colors.grey[400],
                                    size: 30,
                                  ),
                                ),
                        ),
                        DataCell(
                          Text(
                            item.productName,
                            style: const TextStyle(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F855A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              emptyIcon: Icons.shopping_bag,
              emptyText: "No items found.",
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

