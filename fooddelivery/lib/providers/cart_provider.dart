import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  int? _currentRestaurantId;
  String _restaurantName = '';
  String _restaurantImage = '';
  
  Map<int, CartItem> get items => _items;
  int? get currentRestaurantId => _currentRestaurantId;
  String get restaurantName => _restaurantName;
  String get restaurantImage => _restaurantImage;
  bool get isEmpty => _items.isEmpty;
  
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee => _items.isEmpty ? 0 : 2.99;
  
  double get tax => subtotal * 0.1;
  
  double get total => subtotal + deliveryFee + tax;

  void addItem({
    required MenuItem menuItem,
    required int quantity,
    List<MenuItemOptionChoice> selectedChoices = const [],
    String specialInstructions = '',
  }) {
    // If adding from a different restaurant, clear the cart first
    if (_currentRestaurantId != null && 
        _currentRestaurantId != menuItem.restaurantId) {
      clearCart();
    }
    
    // Set current restaurant
    _currentRestaurantId = menuItem.restaurantId;
    
    // Calculate total price for this item
    double itemTotalPrice = menuItem.price * quantity;
    for (var choice in selectedChoices) {
      itemTotalPrice += choice.price * quantity;
    }
    
    // Check if item already exists in cart
    if (_items.containsKey(menuItem.id)) {
      // Update existing item
      final existingItem = _items[menuItem.id]!;
      _items[menuItem.id] = CartItem(
        menuItem: menuItem,
        quantity: existingItem.quantity + quantity,
        selectedChoices: selectedChoices.isEmpty 
            ? existingItem.selectedChoices 
            : selectedChoices,
        specialInstructions: specialInstructions.isEmpty 
            ? existingItem.specialInstructions 
            : specialInstructions,
        totalPrice: existingItem.totalPrice + itemTotalPrice,
      );
    } else {
      // Add new item
      _items[menuItem.id] = CartItem(
        menuItem: menuItem,
        quantity: quantity,
        selectedChoices: selectedChoices,
        specialInstructions: specialInstructions,
        totalPrice: itemTotalPrice,
      );
    }
    
    notifyListeners();
  }
  
  void removeItem(int menuItemId) {
    _items.remove(menuItemId);
    if (_items.isEmpty) {
      _currentRestaurantId = null;
      _restaurantName = '';
      _restaurantImage = '';
    }
    notifyListeners();
  }
  
  void updateQuantity(int menuItemId, int quantity) {
    if (_items.containsKey(menuItemId)) {
      final item = _items[menuItemId]!;
      if (quantity <= 0) {
        removeItem(menuItemId);
      } else {
        // Recalculate total price
        double unitPrice = item.menuItem.price;
        for (var choice in item.selectedChoices) {
          unitPrice += choice.price;
        }
        
        _items[menuItemId] = CartItem(
          menuItem: item.menuItem,
          quantity: quantity,
          selectedChoices: item.selectedChoices,
          specialInstructions: item.specialInstructions,
          totalPrice: unitPrice * quantity,
        );
        notifyListeners();
      }
    }
  }
  
  void clearCart() {
    _items.clear();
    _currentRestaurantId = null;
    _restaurantName = '';
    _restaurantImage = '';
    notifyListeners();
  }
  
  void setRestaurantInfo(String name, String image) {
    _restaurantName = name;
    _restaurantImage = image;
    notifyListeners();
  }
  
  List<CartItem> getCartItemsList() {
    return _items.values.toList();
  }
}
