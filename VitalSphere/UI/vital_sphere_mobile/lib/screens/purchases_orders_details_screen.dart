import 'package:flutter/material.dart';
import 'package:vital_sphere_mobile/model/order.dart';
import 'package:vital_sphere_mobile/model/order_item.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:intl/intl.dart';

class PurchasesOrdersDetailsScreen extends StatelessWidget {
  final Order order;

  const PurchasesOrdersDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF163A2A),
                    const Color(0xFF20523A),
                    const Color(0xFF2F855A),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Order Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Order Items (${order.orderItems.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...order.orderItems.map((item) => _buildOrderItemCard(item)),

            // Order Information Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F855A).withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.person_rounded,
                    label: 'User',
                    value: order.userFullName,
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Total Items',
                    value: '${order.totalItems}',
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.attach_money_rounded,
                    label: 'Total Amount',
                    value: '\$${order.totalAmount.toStringAsFixed(2)}',
                    iconColor: const Color(0xFF2F855A),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.event_available_rounded,
                    label: 'Created At',
                    value: DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                    iconColor: Colors.grey[600]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BasePictureCover(
              base64: item.productPicture,
              size: 70,
              fallbackIcon: Icons.shopping_bag_rounded,
            ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '× \$${item.unitPrice.toStringAsFixed(2)}',
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
          // Total Price
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F855A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

