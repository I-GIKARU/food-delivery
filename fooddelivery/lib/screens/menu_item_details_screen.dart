import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MenuItemDetailsScreen extends StatefulWidget {
  final MenuItem menuItem;
  final String restaurantName;
  final String restaurantImage;

  const MenuItemDetailsScreen({
    super.key,
    required this.menuItem,
    required this.restaurantName,
    required this.restaurantImage,
  });

  @override
  State<MenuItemDetailsScreen> createState() => _MenuItemDetailsScreenState();
}

class _MenuItemDetailsScreenState extends State<MenuItemDetailsScreen> {
  int _quantity = 1;
  String _specialInstructions = '';
  final Map<int, List<MenuItemOptionChoice>> _selectedChoices = {};

  @override
  void initState() {
    super.initState();
    // Initialize selected choices
    for (var option in widget.menuItem.options) {
      if (option.required && option.choices.isNotEmpty) {
        _selectedChoices[option.id] = [option.choices.first];
      } else {
        _selectedChoices[option.id] = [];
      }
    }
  }

  double get _totalPrice {
    double basePrice = widget.menuItem.price * _quantity;
    double optionsPrice = 0;
    
    for (var optionChoices in _selectedChoices.values) {
      for (var choice in optionChoices) {
        optionsPrice += choice.price;
      }
    }
    
    return basePrice + (optionsPrice * _quantity);
  }

  List<MenuItemOptionChoice> get _allSelectedChoices {
    List<MenuItemOptionChoice> choices = [];
    for (var optionChoices in _selectedChoices.values) {
      choices.addAll(optionChoices);
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu item image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: widget.menuItem.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 50),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu item name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.menuItem.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        '\$${widget.menuItem.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating
                  if (widget.menuItem.reviewCount > 0)
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: widget.menuItem.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.menuItem.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    widget.menuItem.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Dietary info
                  Wrap(
                    spacing: 8,
                    children: [
                      if (widget.menuItem.isVegetarian)
                        Chip(
                          label: const Text('Vegetarian'),
                          avatar: const Icon(Icons.eco, size: 16),
                          backgroundColor: Colors.green.shade100,
                        ),
                      if (widget.menuItem.isVegan)
                        Chip(
                          label: const Text('Vegan'),
                          avatar: const Icon(Icons.spa, size: 16),
                          backgroundColor: Colors.green.shade100,
                        ),
                      if (widget.menuItem.isGlutenFree)
                        Chip(
                          label: const Text('Gluten Free'),
                          avatar: Icon(Icons.do_not_disturb_on, size: 16), // Changed icon and removed const
                          backgroundColor: Colors.amber.shade100,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options
                  ...widget.menuItem.options.map((option) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              option.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              option.required ? '(Required)' : '(Optional)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (option.maxSelections > 1)
                              Text(
                                ' • Select up to ${option.maxSelections}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...option.choices.map((choice) {
                          final isSelected = _selectedChoices[option.id]!.contains(choice);
                          
                          return ListTile(
                            title: Text(choice.name),
                            subtitle: choice.price > 0
                                ? Text('+\$${choice.price.toStringAsFixed(2)}')
                                : null,
                            trailing: option.maxSelections == 1
                                ? Radio<MenuItemOptionChoice>(
                                    value: choice,
                                    groupValue: _selectedChoices[option.id]!.isNotEmpty
                                        ? _selectedChoices[option.id]!.first
                                        : null,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedChoices[option.id] = [value!];
                                      });
                                    },
                                  )
                                : Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          // Check if adding would exceed max selections
                                          if (_selectedChoices[option.id]!.length < option.maxSelections) {
                                            _selectedChoices[option.id]!.add(choice);
                                          }
                                        } else {
                                          // Don't allow removing if required and it's the last choice
                                          if (!(option.required && _selectedChoices[option.id]!.length <= 1)) {
                                            _selectedChoices[option.id]!.remove(choice);
                                          }
                                        }
                                      });
                                    },
                                  ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }).toList(),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // Special instructions
                  Text(
                    'Special Instructions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'E.g., No onions, extra sauce, etc.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        _specialInstructions = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _quantity.toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartProvider = Provider.of<CartProvider>(
                          context, 
                          listen: false
                        );
                        
                        cartProvider.addItem(
                          menuItem: widget.menuItem,
                          quantity: _quantity,
                          selectedChoices: _allSelectedChoices,
                          specialInstructions: _specialInstructions,
                        );
                        
                        cartProvider.setRestaurantInfo(
                          widget.restaurantName,
                          widget.restaurantImage,
                        );
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.menuItem.name} added to cart'),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ),
                        );
                        
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Add to Cart - \$${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
