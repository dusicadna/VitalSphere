import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/brand.dart';
import 'package:vital_sphere_desktop/providers/brand_provider.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:vital_sphere_desktop/screens/brand_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class BrandEditScreen extends StatefulWidget {
  final Brand? brand;

  const BrandEditScreen({super.key, this.brand});

  @override
  State<BrandEditScreen> createState() => _BrandEditScreenState();
}

class _BrandEditScreenState extends State<BrandEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late BrandProvider brandProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _initialValue = {
      "name": widget.brand?.name ?? '',
      "isActive": widget.brand?.isActive ?? true,
    };
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.brand != null ? "Edit Brand" : "Add Brand",
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

                    try {
                      if (widget.brand == null) {
                        await brandProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Brand created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await brandProvider.update(widget.brand!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Brand updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const BrandListScreen(),
                          settings: const RouteSettings(name: 'BrandListScreen'),
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

  Widget _buildForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: _initialValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Go back',
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.branding_watermark,
                        size: 32,
                        color: Color(0xFF2F855A),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.brand != null
                            ? "Edit Brand"
                            : "Add New Brand",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F855A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Brand Name
                  FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "Brand Name",
                      prefixIcon: Icons.branding_watermark_outlined,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(150),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // IsActive Switch
                  FormBuilderSwitch(
                    name: 'isActive',
                    title: const Text('Active Brand'),
                    initialValue: _initialValue['isActive'] as bool? ?? true,
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
        ),
      ),
    );
  }
}

