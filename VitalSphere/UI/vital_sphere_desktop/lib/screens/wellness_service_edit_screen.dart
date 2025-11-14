import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_service.dart';
import 'package:vital_sphere_desktop/model/wellness_service_category.dart';
import 'package:vital_sphere_desktop/providers/wellness_service_provider.dart';
import 'package:vital_sphere_desktop/providers/wellness_service_category_provider.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:vital_sphere_desktop/screens/wellness_service_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class WellnessServiceEditScreen extends StatefulWidget {
  final WellnessService? service;

  const WellnessServiceEditScreen({super.key, this.service});

  @override
  State<WellnessServiceEditScreen> createState() =>
      _WellnessServiceEditScreenState();
}

class _WellnessServiceEditScreenState extends State<WellnessServiceEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late WellnessServiceProvider wellnessServiceProvider;
  late WellnessServiceCategoryProvider wellnessServiceCategoryProvider;
  bool isLoading = true;
  bool _isSaving = false;
  File? _image;

  List<WellnessServiceCategory> _categories = [];
  bool _isLoadingCategories = true;
  WellnessServiceCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    wellnessServiceProvider =
        Provider.of<WellnessServiceProvider>(context, listen: false);
    wellnessServiceCategoryProvider =
        Provider.of<WellnessServiceCategoryProvider>(context, listen: false);

    _initialValue = {
      "name": widget.service?.name ?? '',
      "price": widget.service?.price != null
          ? widget.service!.price.toStringAsFixed(2)
          : '0.00',
      "description": widget.service?.description ?? '',
      "durationMinutes": widget.service?.durationMinutes?.toString() ?? '',
      "image": widget.service?.image,
      "isActive": widget.service?.isActive ?? true,
      "wellnessServiceCategoryId": null,
    };
    initFormData();
  }

  initFormData() async {
    await _loadCategories();

    // Set selected category if editing
    if (widget.service != null && _categories.isNotEmpty) {
      try {
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.id == widget.service!.wellnessServiceCategoryId,
        );
        _initialValue['wellnessServiceCategoryId'] = _selectedCategory;
      } catch (e) {
        // Category not found, leave as null
        _selectedCategory = null;
        _initialValue['wellnessServiceCategoryId'] = null;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final result = await wellnessServiceCategoryProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _categories = result.items ?? [];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['image'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.service != null ? "Edit Wellness Service" : "Add Wellness Service",
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
                      request['price'] =
                          double.tryParse(request['price']) ?? 0.0;
                    }

                    // Convert durationMinutes string to int
                    if (request['durationMinutes'] != null &&
                        request['durationMinutes'] is String) {
                      final durationStr = request['durationMinutes'] as String;
                      if (durationStr.isEmpty) {
                        request['durationMinutes'] = null;
                      } else {
                        request['durationMinutes'] =
                            int.tryParse(durationStr);
                      }
                    }

                    // Get category from form values
                    final category =
                        request['wellnessServiceCategoryId'] as WellnessServiceCategory?;

                    if (category != null) {
                      request['wellnessServiceCategoryId'] = category.id;
                    }

                    // Handle image
                    if (_initialValue['image'] != null) {
                      request['image'] = _initialValue['image'];
                    }

                    // Handle description
                    if (request['description'] == null ||
                        (request['description'] as String).isEmpty) {
                      request['description'] = null;
                    }

                    try {
                      if (widget.service == null) {
                        await wellnessServiceProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wellness service created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await wellnessServiceProvider.update(
                            widget.service!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wellness service updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WellnessServiceListScreen(),
                          settings: const RouteSettings(
                              name: 'WellnessServiceListScreen'),
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
        Icon(Icons.spa, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "No service image",
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

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No categories available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<WellnessServiceCategory>(
      name: "wellnessServiceCategoryId",
      decoration: customTextFieldDecoration(
        "Wellness Service Category",
        prefixIcon: Icons.category_outlined,
      ),
      initialValue: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem<WellnessServiceCategory>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (WellnessServiceCategory? value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: 'Please select a category'),
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
                          child: _initialValue['image'] != null &&
                                  (_initialValue['image'] as String).isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(_initialValue['image']),
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
                        if (_initialValue['image'] != null &&
                            (_initialValue['image'] as String).isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _image = null;
                                _initialValue['image'] = null;
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
                                Icons.spa,
                                size: 32,
                                color: Color(0xFF2F855A),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                widget.service != null
                                    ? "Edit Wellness Service"
                                    : "Add New Wellness Service",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F855A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Service Name
                          FormBuilderTextField(
                            name: "name",
                            decoration: customTextFieldDecoration(
                              "Service Name",
                              prefixIcon: Icons.spa_outlined,
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

                          // Duration Minutes
                          FormBuilderTextField(
                            name: "durationMinutes",
                            decoration: customTextFieldDecoration(
                              "Duration (minutes)",
                              prefixIcon: Icons.access_time_outlined,
                            ),
                            keyboardType: TextInputType.number,
                            
                            validator:
                             FormBuilderValidators.compose([
                                                            FormBuilderValidators.required(),

                              FormBuilderValidators.numeric(),
                              (value) {
                                if (value is String) {
                                if (value != null && value.isNotEmpty) {
                                  final duration = int.tryParse(value);
                                  if (duration == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (duration < 1 || duration > 1440) {
                                    return 'Duration must be between 1 and 1440 minutes';
                                  }
                                  }
                                  return null;
                                }
                                return 'Please enter a valid number';
                              },
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          FormBuilderTextField(
                            name: "description",
                            decoration: customTextFieldDecoration(
                              "Description (optional)",
                              prefixIcon: Icons.description_outlined,
                            ),
                            maxLines: 3,
                            maxLength: 1000,
                
                          ),
                          const SizedBox(height: 16),

                          // Wellness Service Category Dropdown
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),

                          // IsActive Switch
                          FormBuilderSwitch(
                            name: 'isActive',
                            title: const Text('Active Service'),
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

