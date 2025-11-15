import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/wellness_box.dart';
import 'package:vital_sphere_desktop/providers/wellness_box_provider.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:vital_sphere_desktop/screens/wellness_box_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class WellnessBoxEditScreen extends StatefulWidget {
  final WellnessBox? box;

  const WellnessBoxEditScreen({super.key, this.box});

  @override
  State<WellnessBoxEditScreen> createState() => _WellnessBoxEditScreenState();
}

class _WellnessBoxEditScreenState extends State<WellnessBoxEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late WellnessBoxProvider wellnessBoxProvider;
  bool isLoading = true;
  bool _isSaving = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    wellnessBoxProvider =
        Provider.of<WellnessBoxProvider>(context, listen: false);

    _initialValue = {
      "name": widget.box?.name ?? '',
      "description": widget.box?.description ?? '',
      "includedItems": widget.box?.includedItems ?? '',
      "image": widget.box?.image,
      "isActive": widget.box?.isActive ?? true,
    };
    setState(() {
      isLoading = false;
    });
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
      title: widget.box != null ? "Edit Wellness Box" : "Add Wellness Box",
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

                    // Handle image
                    if (_initialValue['image'] != null) {
                      request['image'] = _initialValue['image'];
                    }

                    // Handle description
                    if (request['description'] == null ||
                        (request['description'] as String).isEmpty) {
                      request['description'] = null;
                    }

                    // Handle includedItems
                    if (request['includedItems'] == null ||
                        (request['includedItems'] as String).isEmpty) {
                      request['includedItems'] = null;
                    }

                    try {
                      if (widget.box == null) {
                        await wellnessBoxProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wellness box created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await wellnessBoxProvider.update(
                            widget.box!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wellness box updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WellnessBoxListScreen(),
                          settings: const RouteSettings(
                              name: 'WellnessBoxListScreen'),
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
        Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "No box image",
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
                                Icons.inventory_2,
                                size: 32,
                                color: Color(0xFF2F855A),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                widget.box != null
                                    ? "Edit Wellness Box"
                                    : "Add New Wellness Box",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F855A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Box Name
                          FormBuilderTextField(
                            name: "name",
                            decoration: customTextFieldDecoration(
                              "Box Name",
                              prefixIcon: Icons.inventory_2_outlined,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.maxLength(150),
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
                            maxLength: 500,
                          ),
                          const SizedBox(height: 16),

                          // Included Items
                          FormBuilderTextField(
                            name: "includedItems",
                            decoration: customTextFieldDecoration(
                              "Included Items (optional)",
                              prefixIcon: Icons.list_outlined,
                            ),
                            maxLines: 4,
                            maxLength: 1000,
                          ),
                          const SizedBox(height: 16),

                          // IsActive Switch
                          FormBuilderSwitch(
                            name: 'isActive',
                            title: const Text('Active Box'),
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

