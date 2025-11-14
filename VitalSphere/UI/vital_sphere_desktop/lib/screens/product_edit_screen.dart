import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/product.dart';
import 'package:vital_sphere_desktop/model/product_category.dart';
import 'package:vital_sphere_desktop/model/brand.dart';
import 'package:vital_sphere_desktop/providers/product_provider.dart';
import 'package:vital_sphere_desktop/providers/product_category_provider.dart';
import 'package:vital_sphere_desktop/providers/brand_provider.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:vital_sphere_desktop/screens/product_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ProductProvider productProvider;
  late ProductCategoryProvider productCategoryProvider;
  late BrandProvider brandProvider;
  bool isLoading = true;
  bool _isSaving = false;
  File? _image;

  List<ProductCategory> _productCategories = [];
  List<Brand> _brands = [];
  bool _isLoadingCategories = true;
  bool _isLoadingBrands = true;
  ProductCategory? _selectedCategory;
  Brand? _selectedBrand;

  @override
  void initState() {
    super.initState();
    productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productCategoryProvider =
        Provider.of<ProductCategoryProvider>(context, listen: false);
    brandProvider = Provider.of<BrandProvider>(context, listen: false);
    
    _initialValue = {
      "name": widget.product?.name ?? '',
      "price": widget.product?.price != null 
          ? widget.product!.price.toStringAsFixed(2) 
          : '0.00',
      "picture": widget.product?.picture,
      "isActive": widget.product?.isActive ?? true,
      "productCategoryId": null,
      "brandId": null,
    };
    initFormData();
  }

  initFormData() async {
    await _loadCategories();
    await _loadBrands();
    
    // Set selected category and brand if editing
    if (widget.product != null && _productCategories.isNotEmpty && _brands.isNotEmpty) {
      try {
        _selectedCategory = _productCategories.firstWhere(
          (cat) => cat.id == widget.product!.productCategoryId,
        );
        _initialValue['productCategoryId'] = _selectedCategory;
      } catch (e) {
        // Category not found, leave as null
        _selectedCategory = null;
        _initialValue['productCategoryId'] = null;
      }
      
      try {
        _selectedBrand = _brands.firstWhere(
          (brand) => brand.id == widget.product!.brandId,
        );
        _initialValue['brandId'] = _selectedBrand;
      } catch (e) {
        // Brand not found, leave as null
        _selectedBrand = null;
        _initialValue['brandId'] = null;
      }
    }
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final result = await productCategoryProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _productCategories = result.items ?? [];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadBrands() async {
    try {
      final result = await brandProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _brands = result.items ?? [];
        _isLoadingBrands = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBrands = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['picture'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.product != null ? "Edit Product" : "Add Product",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  formKey.currentState?.saveAndValidate();
                  if (formKey.currentState?.validate() ?? false) {
                    setState(() => _isSaving = true);
                    var request = Map.from(formKey.currentState?.value ?? {});

                    // Convert price string to double
                    if (request['price'] != null && request['price'] is String) {
                      request['price'] = double.tryParse(request['price']) ?? 0.0;
                    }

                    // Get category and brand from form values
                    final category = request['productCategoryId'] as ProductCategory?;
                    final brand = request['brandId'] as Brand?;
                    
                    if (category != null) {
                      request['productCategoryId'] = category.id;
                    }
                    if (brand != null) {
                      request['brandId'] = brand.id;
                    }

                    // Handle image
                    if (_initialValue['picture'] != null) {
                      request['picture'] = _initialValue['picture'];
                    }

                    try {
                      if (widget.product == null) {
                        await productProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await productProvider.update(
                            widget.product!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                          settings: const RouteSettings(name: 'ProductListScreen'),
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F855A),
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "No product image",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          "Click 'Select Image' to add an image",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading categories...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_productCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No categories available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<ProductCategory>(
      name: "productCategoryId",
      decoration: customTextFieldDecoration(
        "Product Category",
        prefixIcon: Icons.category_outlined,
      ),
      initialValue: _selectedCategory,
      items: _productCategories.map((category) {
        return DropdownMenuItem<ProductCategory>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (ProductCategory? value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a category'),
      ]),
    );
  }

  Widget _buildBrandDropdown() {
    if (_isLoadingBrands) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading brands...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_brands.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No brands available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<Brand>(
      name: "brandId",
      decoration: customTextFieldDecoration(
        "Brand",
        prefixIcon: Icons.branding_watermark_outlined,
      ),
      initialValue: _selectedBrand,
      items: _brands.map((brand) {
        return DropdownMenuItem<Brand>(
          value: brand,
          child: Text(brand.name),
        );
      }).toList(),
      onChanged: (Brand? value) {
        setState(() {
          _selectedBrand = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a brand'),
      ]),
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: image + buttons
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: _initialValue['picture'] != null &&
                                  (_initialValue['picture'] as String).isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(_initialValue['picture']),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder();
                                    },
                                  ),
                                )
                              : _buildImagePlaceholder(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Select Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F855A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_initialValue['picture'] != null &&
                            (_initialValue['picture'] as String).isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _image = null;
                                _initialValue['picture'] = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text("Clear Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                220,
                                53,
                                69,
                              ),
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right column: form fields
                  Expanded(
                    child: FormBuilder(
                      key: formKey,
                      initialValue: _initialValue,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'Go back',
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.shopping_bag,
                                size: 32,
                                color: Color(0xFF2F855A),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                widget.product != null
                                    ? "Edit Product"
                                    : "Add New Product",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F855A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Product Name
                          FormBuilderTextField(
                            name: "name",
                            decoration: customTextFieldDecoration(
                              "Product Name",
                              prefixIcon: Icons.shopping_bag_outlined,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.maxLength(200),
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // Price
                          FormBuilderTextField(
                            name: "price",
                            decoration: customTextFieldDecoration(
                              "Price",
                              prefixIcon: Icons.attach_money,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                              (value) {
                                if (value != null && value.isNotEmpty) {
                                  final price = double.tryParse(value);
                                  if (price == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (price <= 0) {
                                    return 'Price must be greater than 0';
                                  }
                                }
                                return null;
                              },
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // Product Category Dropdown
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),

                          // Brand Dropdown
                          _buildBrandDropdown(),
                          const SizedBox(height: 16),

                          // IsActive Switch
                          FormBuilderSwitch(
                            name: 'isActive',
                            title: const Text('Active Product'),
                            initialValue:
                                _initialValue['isActive'] as bool? ?? true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Save and Cancel Buttons
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

