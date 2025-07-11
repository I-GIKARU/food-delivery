import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/auth_provider.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:fooddelivery/providers/order_provider.dart';
import 'package:fooddelivery/screens/order_tracking_screen.dart';
import 'package:fooddelivery/screens/payment_method_screen.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedAddress = '';
  String _selectedPaymentMethod = '';
  double _tipAmount = 0;
  final List<double> _tipOptions = [0, 2, 3, 5];
  
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          // Stepper
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _placeOrder();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep < 2 ? 'Continue' : 'Place Order'),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                // Delivery Address
                Step(
                  title: const Text('Delivery Address'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mock addresses for demo
                      _buildAddressCard(
                        'Home',
                        '123 Main St, Apt 4B, San Francisco, CA 94105',
                        isSelected: _selectedAddress == 'Home',
                        onSelect: () {
                          setState(() {
                            _selectedAddress = 'Home';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAddressCard(
                        'Work',
                        '456 Market St, Floor 3, San Francisco, CA 94103',
                        isSelected: _selectedAddress == 'Work',
                        onSelect: () {
                          setState(() {
                            _selectedAddress = 'Work';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to add address screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add address functionality would go here'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 
                      ? StepState.complete 
                      : _selectedAddress.isEmpty 
                          ? StepState.error 
                          : StepState.indexed,
                ),
                
                // Payment Method
                Step(
                  title: const Text('Payment Method'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mock payment methods for demo
                      _buildPaymentMethodCard(
                        'Credit Card',
                        'Visa ending in 4242',
                        Icons.credit_card,
                        isSelected: _selectedPaymentMethod == 'Credit Card',
                        onSelect: () {
                          setState(() {
                            _selectedPaymentMethod = 'Credit Card';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodCard(
                        'PayPal',
                        'john.doe@example.com',
                        Icons.account_balance_wallet,
                        isSelected: _selectedPaymentMethod == 'PayPal',
                        onSelect: () {
                          setState(() {
                            _selectedPaymentMethod = 'PayPal';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodCard(
                        'Cash on Delivery',
                        'Pay when your order arrives',
                        Icons.money,
                        isSelected: _selectedPaymentMethod == 'Cash on Delivery',
                        onSelect: () {
                          setState(() {
                            _selectedPaymentMethod = 'Cash on Delivery';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 
                      ? StepState.complete 
                      : _selectedPaymentMethod.isEmpty 
                          ? StepState.error 
                          : StepState.indexed,
                ),
                
                // Order Summary
                Step(
                  title: const Text('Order Summary'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order items summary
                      Text(
                        'Items (${cartProvider.itemCount})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...cartProvider.getCartItemsList().map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity}x ${item.menuItem.name}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const Divider(height: 24),
                      
                      // Delivery address
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedAddress == 'Home'
                            ? '123 Main St, Apt 4B, San Francisco, CA 94105'
                            : '456 Market St, Floor 3, San Francisco, CA 94103',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Payment method
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPaymentMethod,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tip options
                      Text(
                        'Add a Tip',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _tipOptions.map((tip) {
                          return ChoiceChip(
                            label: Text(tip == 0 ? 'No Tip' : '\$${tip.toStringAsFixed(0)}'),
                            selected: _tipAmount == tip,
                            onSelected: (selected) {
                              setState(() {
                                _tipAmount = selected ? tip : 0;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Order total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee'),
                          Text('\$${cartProvider.deliveryFee.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax'),
                          Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (_tipAmount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tip'),
                            Text('\$${_tipAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${(cartProvider.total + _tipAmount).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressCard(String label, String address, {
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onSelect(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit address screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit address functionality would go here'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodCard(
    String title,
    String subtitle,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onSelect(),
              ),
              const SizedBox(width: 8),
              Icon(icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _placeOrder() async {
    if (_selectedAddress.isEmpty || _selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select delivery address and payment method'),
        ),
      );
      return;
    }
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your order...'),
          ],
        ),
      ),
    );
    
    try {
      final order = await orderProvider.placeOrder(
        restaurantId: cartProvider.currentRestaurantId!,
        restaurantName: cartProvider.restaurantName,
        restaurantImage: cartProvider.restaurantImage,
        items: cartProvider.getCartItemsList(),
        deliveryAddress: _selectedAddress == 'Home'
            ? '123 Main St, Apt 4B, San Francisco, CA 94105'
            : '456 Market St, Floor 3, San Francisco, CA 94103',
        paymentMethod: _selectedPaymentMethod,
        tip: _tipAmount,
      );
      
      // Clear cart
      cartProvider.clearCart();
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Navigate to order tracking screen
      if (mounted && order != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: order.id),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
        ),
      );
    }
  }
}
