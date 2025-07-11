import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider({required this.apiService});

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await apiService.getOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await apiService.getOrderDetails(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder({
    required int restaurantId,
    required String restaurantName,
    required String restaurantImage,
    required List<CartItem> items,
    required String deliveryAddress,
    required String paymentMethod,
    double? tip,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await apiService.placeOrder(
        restaurantId: restaurantId,
        items: items,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        tip: tip,
      );
      
      // Add to orders list
      _orders.insert(0, order);
      _selectedOrder = order;
      
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  List<Order> getActiveOrders() {
    return _orders.where((order) => 
      order.status != 'delivered' && 
      order.status != 'cancelled'
    ).toList();
  }

  List<Order> getPastOrders() {
    return _orders.where((order) => 
      order.status == 'delivered' || 
      order.status == 'cancelled'
    ).toList();
  }
}
