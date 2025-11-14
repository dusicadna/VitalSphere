import 'package:flutter/material.dart';
import 'package:vital_sphere_desktop/layouts/master_screen.dart';
import 'package:vital_sphere_desktop/model/city.dart';
import 'package:vital_sphere_desktop/providers/city_provider.dart';
import 'package:vital_sphere_desktop/utils/base_textfield.dart';
import 'package:vital_sphere_desktop/screens/city_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CityEditScreen extends StatefulWidget {
  final City? city;

  const CityEditScreen({super.key, this.city});

  @override
  State<CityEditScreen> createState() => _CityEditScreenState();
}

class _CityEditScreenState extends State<CityEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CityProvider cityProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    _initialValue = {
      "name": widget.city?.name ?? '',
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
      title: widget.city != null ? "Edit City" : "Add City",
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
                      if (widget.city == null) {
                        await cityProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await cityProvider.update(widget.city!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CityListScreen(),
                          settings: const RouteSettings(name: 'CityListScreen'),
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
                        Icons.location_city,
                        size: 32,
                        color: Color(0xFF2F855A),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.city != null ? "Edit City" : "Add New City",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F855A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // City Name
                  FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "City Name",
                      prefixIcon: Icons.location_on,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(r'^[\p{L} ]+$', unicode: true),
                        errorText:
                            'Only letters (including international), and spaces allowed',
                      ),
                    ]),
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

