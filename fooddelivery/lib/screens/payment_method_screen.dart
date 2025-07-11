import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/utils/theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card type selection
              Text(
                'Select Card Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCardTypeOption('Visa', 'assets/images/visa.png'),
                  _buildCardTypeOption('Mastercard', 'assets/images/mastercard.png'),
                  _buildCardTypeOption('Amex', 'assets/images/amex.png'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Card details
              Text(
                'Card Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Card number
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.replaceAll(' ', '').length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format card number with spaces
                  if (value.length > 0 && value.length % 5 == 0) {
                    if (value.substring(value.length - 1) != ' ') {
                      _cardNumberController.text = 
                          value.substring(0, value.length - 1) + 
                          ' ' + 
                          value.substring(value.length - 1);
                      _cardNumberController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _cardNumberController.text.length),
                      );
                    }
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Card holder name
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Expiry date and CVV
              Row(
                children: [
                  // Expiry date
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Use format MM/YY';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Format expiry date with slash
                        if (value.length == 2 && !value.contains('/')) {
                          _expiryDateController.text = value + '/';
                          _expiryDateController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _expiryDateController.text.length),
                          );
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        if (value.length < 3 || value.length > 4) {
                          return 'CVV must be 3-4 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Save as default
              CheckboxListTile(
                title: const Text('Save as default payment method'),
                value: true,
                onChanged: (value) {
                  // In a real app, this would update state
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 24),
              
              // Add card button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // In a real app, this would save the card
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment method added successfully'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add Card',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security note
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Payment',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your payment information is encrypted and securely stored.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCardTypeOption(String name, String imagePath) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.credit_card,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            // In a real app, this would be an image:
            // Image.asset(imagePath, height: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(name),
      ],
    );
  }
}
