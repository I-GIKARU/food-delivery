import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/services/api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  RestaurantProvider({required this.apiService});

  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchRestaurants({
    String? search,
    String? category,
    double? latitude,
    double? longitude,
    String? sortBy,
  }) async {
    _isLoading = true;
    _error = null;
    if (search != null) _searchQuery = search;
    if (category != null) _selectedCategory = category;
    notifyListeners();

    try {
      _restaurants = await apiService.getRestaurants(
        search: search,
        category: category,
        latitude: latitude,
        longitude: longitude,
        sortBy: sortBy,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantDetails(int restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRestaurant = await apiService.getRestaurantDetails(restaurantId);
      await fetchMenuItems(restaurantId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMenuItems(int restaurantId, {String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await apiService.getMenuItems(restaurantId, category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedRestaurant() {
    _selectedRestaurant = null;
    _menuItems = [];
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<String> getUniqueCategories() {
    final categories = <String>{};
    for (final restaurant in _restaurants) {
      categories.addAll(restaurant.categories);
    }
    return categories.toList()..sort();
  }

  List<String> getMenuCategories() {
    final categories = <String>{};
    for (final item in _menuItems) {
      categories.add(item.category);
    }
    return categories.toList()..sort();
  }
}
