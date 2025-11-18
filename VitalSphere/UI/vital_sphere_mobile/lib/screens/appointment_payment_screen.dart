import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vital_sphere_mobile/model/wellness_service.dart';
import 'package:vital_sphere_mobile/model/gift.dart';
import 'package:vital_sphere_mobile/model/wellness_box.dart';
import 'package:vital_sphere_mobile/providers/appointment_provider.dart';
import 'package:vital_sphere_mobile/providers/user_provider.dart';
import 'package:vital_sphere_mobile/providers/gift_provider.dart';
import 'package:vital_sphere_mobile/providers/wellness_box_provider.dart';
import 'package:vital_sphere_mobile/screens/gift_screen.dart';
import 'package:vital_sphere_mobile/utils/base_picture_cover.dart';

class AppointmentPaymentScreen extends StatefulWidget {
  final WellnessService service;
  final DateTime scheduledAt;
  final String? notes;

  const AppointmentPaymentScreen({
    super.key,
    required this.service,
    required this.scheduledAt,
    this.notes,
  });

  @override
  State<AppointmentPaymentScreen> createState() => _AppointmentPaymentScreenState();
}

class _AppointmentPaymentScreenState extends State<AppointmentPaymentScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _paymentCompleted = false;
  int? _generatedAppointmentId;

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFF2F855A), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2F855A),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2F855A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
                  ),
                )
              : _paymentCompleted
                  ? _buildPaymentSuccessScreen()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildPaymentForm(context),
                    ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Success message
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F855A).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF48BB78).withOpacity(0.2),
                        const Color(0xFF2F855A).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: Color(0xFF2F855A),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Appointment Booked!',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your appointment has been successfully booked.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Appointment #${_generatedAppointmentId ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appointment details card
          _buildAppointmentDetailsCard(),

          const SizedBox(height: 32),

          // Action buttons
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2F855A),
                      Color(0xFF38A169),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F855A).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate back to service list
                      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/service-list');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.calendar_today_outlined, size: 22),
                    label: const Text(
                      'Back to Services',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2F855A).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Service', widget.service.name),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Date',
                  '${widget.scheduledAt.day}/${widget.scheduledAt.month}/${widget.scheduledAt.year}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Time',
                  '${widget.scheduledAt.hour.toString().padLeft(2, '0')}:${widget.scheduledAt.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total Amount',
                  '\$${widget.service.price.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We look forward to seeing you!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF1F2937) : Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF2F855A) : const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 24),
          _buildServiceDetailsCard(),
          const SizedBox(height: 24),
          _buildAppointmentDateTimeCard(),
          const SizedBox(height: 24),
          _buildBillingSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2F855A),
            Color(0xFF38A169),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${widget.service.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF2F855A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Service Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BasePictureCover(
                  base64: widget.service.image,
                  size: 60,
                  fallbackIcon: Icons.spa_rounded,
                  borderColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2F855A),
                  backgroundColor: const Color(0xFFE8F5E9),
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.service.durationMinutes != null)
                      Text(
                        'Duration: ${widget.service.durationMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '\$${widget.service.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2F855A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF2F855A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Appointment Date & Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2F855A).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF2F855A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.scheduledAt.day}/${widget.scheduledAt.month}/${widget.scheduledAt.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF2F855A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.scheduledAt.hour.toString().padLeft(2, '0')}:${widget.scheduledAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF2F855A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Billing Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'name',
            'Full Name',
            initialValue: _getUserFullName(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'address',
            'Address',
            initialValue: '',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'city',
                  'City',
                  initialValue: '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('state', 'State', initialValue: ''),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'country',
                  'Country',
                  initialValue: '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'pincode',
                  'ZIP Code',
                  keyboardType: TextInputType.number,
                  isNumeric: true,
                  initialValue: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserFullName() {
    final user = UserProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return '';
  }

  Widget _buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              FormBuilderValidators.numeric(
                errorText: 'This field must be numeric',
              ),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2F855A),
            Color(0xFF38A169),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.lock_outline_rounded, size: 22),
          label: const Text(
            "Proceed to Payment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              final formData = formKey.currentState?.value;

              try {
                await _processStripePayment(formData!);
              } catch (e) {
                _showErrorSnackbar('Payment failed: ${e.toString()}');
              }
            }
          },
        ),
      ),
    );
  }

  // Stripe Payment Methods
  Future<void> _initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      final data = await _createPaymentIntent(
        amount: (widget.service.price * 100).round().toString(),
        currency: 'USD',
        name: formData['name'],
        address: formData['address'],
        pin: formData['pincode'],
        city: formData['city'],
        state: formData['state'],
        country: formData['country'],
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'VitalSphere',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      if (secretKey == null) {
        throw Exception('STRIPE_SECRET_KEY not found in environment variables');
      }

      // Create customer
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': UserProvider.currentUser?.email ?? 'test@example.com',
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
        },
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to create customer: ${customerResponse.body}');
      }

      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      // Create ephemeral key
      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) {
        throw Exception(
          'Failed to create ephemeral key: ${ephemeralKeyResponse.body}',
        );
      }

      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      // Create payment intent
      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'VitalSphere Wellness Service Appointment',
          'metadata[name]': name,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
          'metadata[service]': widget.service.name,
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
          'amount': amount,
          'currency': currency,
        };
      } else {
        throw Exception(
          'Failed to create payment intent: ${paymentIntentResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    try {
      await _initPaymentSheet(formData);
      await stripe.Stripe.instance.presentPaymentSheet();

      // Check if user should receive a gift BEFORE creating appointment
      final user = UserProvider.currentUser;
      int? wellnessBoxId;
      if (user != null) {
        wellnessBoxId = await _determineGiftWellnessBoxId(user.id);
      }

      // Create appointment in backend
      final appointmentData = await _createAppointment();
      final appointmentId = appointmentData['id'];

      // If user won a gift, create it and navigate to gift screen
      if (user != null && wellnessBoxId != null) {
        try {
          final gift = await _createGift(user.id, wellnessBoxId);
          final wellnessBox = await _getWellnessBox(wellnessBoxId);
          
          if (gift != null && wellnessBox != null) {
            // Navigate to gift screen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftScreen(
                    gift: gift,
                    wellnessBox: wellnessBox,
                  ),
                ),
              );
              return;
            }
          }
        } catch (e) {
          // If gift creation fails, continue to show success screen
          print('Failed to create gift: $e');
        }
      }

      // No gift or gift creation failed - show success screen
      setState(() {
        _paymentCompleted = true;
        _generatedAppointmentId = appointmentId;
        _isLoading = false;
      });

      _showSuccessSnackbar('Payment successful!');
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (e.toString().contains('canceled')) {
        _showInfoSnackbar('Payment was canceled');
      } else {
        _showErrorSnackbar('Payment failed: ${e.toString()}');
      }
    }
  }

  Future<Map<String, dynamic>> _createAppointment() async {
    try {
      final user = UserProvider.currentUser;
      if (user == null) throw Exception('User not found');

      // Create appointment using the backend endpoint
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      final appointmentRequest = {
        'userId': user.id,
        'wellnessServiceId': widget.service.id,
        'scheduledAt': widget.scheduledAt.toIso8601String(),
        'notes': widget.notes,
      };

      final result = await appointmentProvider.insert(appointmentRequest);

      return {
        'id': result.id,
      };
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<bool> _isFirstAppointment(int userId) async {
    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final result = await appointmentProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1,
          'includeTotalCount': true,
          'userId': userId,
        },
      );
      // If totalCount is 0, it's their first appointment
      return (result.totalCount ?? 0) == 0;
    } catch (e) {
      // If error, assume it's not first to be safe
      return false;
    }
  }

  Future<int?> _determineGiftWellnessBoxId(int userId) async {
    final isFirst = await _isFirstAppointment(userId);
    
    if (isFirst) {
      // First appointment = 100% gift the first wellness box user hasn't received
      return await _getFirstUnreceivedWellnessBoxId(userId);
    } else {
      // Other appointments = 50/50 chance
      final random = Random();
      if (random.nextDouble() < 0.5) {
        // 50% chance - get random wellness box
        return await _getRandomWellnessBoxId();
      } else {
        // 50% chance - no gift
        return null;
      }
    }
  }

  Future<int?> _getFirstUnreceivedWellnessBoxId(int userId) async {
    try {
      // Get all gifts for this user
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      final giftsResult = await giftProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
          'userId': userId,
        },
      );
      
      // Get list of wellness box IDs the user already has
      final receivedBoxIds = (giftsResult.items ?? [])
          .map((gift) => gift.wellnessBoxId)
          .toSet();
      
      // Get all wellness boxes
      final wellnessBoxProvider = Provider.of<WellnessBoxProvider>(context, listen: false);
      final boxesResult = await wellnessBoxProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      
      final allBoxes = (boxesResult.items ?? [])
          .where((box) => box.isActive)
          .toList();
      
      if (allBoxes.isEmpty) return null;
      
      // Sort boxes by ID and find the first one user hasn't received
      allBoxes.sort((a, b) => a.id.compareTo(b.id));
      
      for (final box in allBoxes) {
        if (!receivedBoxIds.contains(box.id)) {
          return box.id;
        }
      }
      
      // If user has all boxes, return the first one (lowest ID)
      return allBoxes.first.id;
    } catch (e) {
      // If error, fallback to first box (id = 1) or null
      return null;
    }
  }

  Future<int?> _getRandomWellnessBoxId() async {
    try {
      final wellnessBoxProvider = Provider.of<WellnessBoxProvider>(context, listen: false);
      final result = await wellnessBoxProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      
      final boxes = result.items ?? [];
      if (boxes.isEmpty) return null;
      
      // Filter active boxes
      final activeBoxes = boxes.where((box) => box.isActive).toList();
      if (activeBoxes.isEmpty) return null;
      
      // Pick random box
      final random = Random();
      final randomBox = activeBoxes[random.nextInt(activeBoxes.length)];
      return randomBox.id;
    } catch (e) {
      return null;
    }
  }

  Future<Gift?> _createGift(int userId, int wellnessBoxId) async {
    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);
      
      final giftRequest = {
        'userId': userId,
        'wellnessBoxId': wellnessBoxId,
        'giftedAt': DateTime.now().toIso8601String(),
      };

      final result = await giftProvider.insert(giftRequest);
      return result;
    } catch (e) {
      throw Exception('Failed to create gift: $e');
    }
  }

  Future<WellnessBox?> _getWellnessBox(int wellnessBoxId) async {
    try {
      final wellnessBoxProvider = Provider.of<WellnessBoxProvider>(context, listen: false);
      return await wellnessBoxProvider.getById(wellnessBoxId);
    } catch (e) {
      return null;
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2F855A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

