import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Payment Screen
/// Payment method selection and card entry
class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderDescription;
  final Function(Map<String, dynamic> paymentMethod) onPaymentConfirmed;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderDescription,
    required this.onPaymentConfirmed,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedMethod = 'card';
  bool _saveCard = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    if (_selectedMethod == 'card' && !_formKey.currentState!.validate()) {
      return;
    }

    final paymentMethod = {
      'type': _selectedMethod,
      if (_selectedMethod == 'card') ...{
        'card_number': _cardNumberController.text.replaceAll(' ', ''),
        'card_holder': _cardHolderController.text,
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'save_card': _saveCard,
      },
    };

    widget.onPaymentConfirmed(paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.orderDescription,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                          const Divider(
                            color: Color(0xFF333333),
                            height: 32,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment method selection
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildPaymentMethodOption(
                      'card',
                      'Credit/Debit Card',
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodOption(
                      'apple_pay',
                      'Apple Pay',
                      Icons.apple,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodOption(
                      'google_pay',
                      'Google Pay',
                      Icons.payment,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodOption(
                      'paypal',
                      'PayPal',
                      Icons.account_balance_wallet,
                    ),

                    // Card details form (shown when card is selected)
                    if (_selectedMethod == 'card') ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Card Details',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Card number
                            TextFormField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                                _CardNumberInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Card Number',
                                labelStyle: const TextStyle(color: Color(0xFF888888)),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.credit_card,
                                  color: Color(0xFF888888),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card number';
                                }
                                final cleaned = value.replaceAll(' ', '');
                                if (cleaned.length < 16) {
                                  return 'Card number must be 16 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Card holder name
                            TextFormField(
                              controller: _cardHolderController,
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: InputDecoration(
                                labelText: 'Card Holder Name',
                                labelStyle: const TextStyle(color: Color(0xFF888888)),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Color(0xFF888888),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card holder name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Expiry and CVV
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                      _ExpiryDateInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'MM/YY',
                                      labelStyle: const TextStyle(color: Color(0xFF888888)),
                                      filled: true,
                                      fillColor: const Color(0xFF1A1A1A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (value.length < 5) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'CVV',
                                      labelStyle: const TextStyle(color: Color(0xFF888888)),
                                      filled: true,
                                      fillColor: const Color(0xFF1A1A1A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (value.length < 3) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Save card checkbox
                            CheckboxListTile(
                              value: _saveCard,
                              onChanged: (value) {
                                setState(() {
                                  _saveCard = value ?? false;
                                });
                              },
                              title: const Text(
                                'Save card for future purchases',
                                style: TextStyle(color: Color(0xFF888888)),
                              ),
                              activeColor: const Color(0xFFFFFFFF),
                              checkColor: const Color(0xFF000000),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Pay button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Color(0xFF333333)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    foregroundColor: const Color(0xFF000000),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    'Pay \$${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String title, IconData icon) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF333333),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF888888),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF888888),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFFFFFF),
              ),
          ],
        ),
      ),
    );
  }
}

// Card number formatter (adds spaces every 4 digits)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry date formatter (MM/YY)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
