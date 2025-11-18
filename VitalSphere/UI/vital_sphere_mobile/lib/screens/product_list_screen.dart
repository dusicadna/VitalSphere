import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_sphere_mobile/model/product.dart';
import 'package:vital_sphere_mobile/model/product_category.dart';
import 'package:vital_sphere_mobile/providers/product_provider.dart';
import 'package:vital_sphere_mobile/providers/product_category_provider.dart';
import 'package:vital_sphere_mobile/utils/base_textfield.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';
import 'package:vital_sphere_mobile/utils/base_pagination.dart';
import 'package:vital_sphere_mobile/screens/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductCategory? _selectedCategory;
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchController.text) {
        _currentPage = 0;
        _loadProducts();
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categoryProvider =
          Provider.of<ProductCategoryProvider>(context, listen: false);
      final result = await categoryProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _categories = result.items ?? [];
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      final filter = <String, dynamic>{
        'page': _currentPage,
        'pageSize': _pageSize,
        'includeTotalCount': true,
      };

      // Add name filter if search text is not empty
      if (_searchController.text.trim().isNotEmpty) {
        filter['name'] = _searchController.text.trim();
      }

      // Add category filter if selected
      if (_selectedCategory != null) {
        filter['productCategoryId'] = _selectedCategory!.id;
      }

      final result = await productProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _products = result.items ?? [];
          final totalCount = result.totalCount ?? 0;
          _totalPages = (totalCount / _pageSize).ceil();
          if (_totalPages == 0) _totalPages = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load products: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2F855A),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _loadProducts();
    }
  }

  void _onPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadProducts();
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
        child: Column(
          children: [
            // Filters Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: customTextFieldDecoration(
                      "Search Products",
                      prefixIcon: Icons.search_rounded,
                      hintText: "Enter product name...",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<ProductCategory>(
                    value: _selectedCategory,
                    decoration: customTextFieldDecoration(
                      "Category",
                      prefixIcon: Icons.category_rounded,
                      hintText: "All Categories",
                    ),
                    items: [
                      const DropdownMenuItem<ProductCategory>(
                        value: null,
                        child: Text("All Categories"),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<ProductCategory>(
                          value: category,
                          child: Text(category.name),
                        );
                      }),
                    ],
                    onChanged: (ProductCategory? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        _currentPage = 0;
                      });
                      _loadProducts();
                    },
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2F855A),
                        ),
                      ),
                    )
                  : _products.isEmpty
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
                                "No products found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProducts,
                          color: const Color(0xFF2F855A),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
            ),

            // Pagination
            if (!_isLoading && _products.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BasePagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onNext: _onNextPage,
                  onPrevious: _onPreviousPage,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                BasePictureCover(
                  base64: product.picture,
                  size: 100,
                  fallbackIcon: Icons.shopping_bag_rounded,
                  borderColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2F855A),
                  backgroundColor: const Color(0xFFE8F5E9),
                  shape: BoxShape.rectangle,
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.productCategoryName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2F855A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2F855A),
                                  Color(0xFF38A169),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF2F855A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

