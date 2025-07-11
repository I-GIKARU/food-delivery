import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://kenyan-food-delivery-backend-67998046123.us-central1.run.app/api/v1';
  
  // Use environment variable for mock data flag
  final bool useMockData = dotenv.env['USE_MOCK_DATA']?.toLowerCase() == 'true';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'message': 'Password reset email sent'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to request password reset: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'message': 'Email verified successfully'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to verify email: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'token': 'mock_token_12345',
        'user': {
          'id': 1,
          'name': 'John Doe',
          'email': email,
          'phone': '+1234567890',
          'address': '123 Main St, City',
          'profile_image': 'https://randomuser.me/api/portraits/men/1.jpg',
          'role': 'customer',
        }
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'access_token': data['data']['access_token'],
        'user': data['data']['user'],
      };
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String phone, String role) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'token': 'mock_token_12345',
        'user': {
          'id': 1,
          'name': name,
          'email': email,
          'phone': phone,
          'address': '',
          'profile_image': '',
          'role': role,
        }
      };
    }

    // Split name into first and last name
    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone_number': phone,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'preferred_language': 'en',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'access_token': data['data']['access_token'],
        'user': data['data']['user'],
      };
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Restaurants
  Future<List<Restaurant>> getRestaurants({
    String? search,
    String? category,
    double? latitude,
    double? longitude,
    String? sortBy,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Restaurant(
          id: 1,
          name: 'Burger King',
          description: 'Home of the Whopper',
          address: '123 Main St, City',
          phone: '+1234567890',
          image: 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9',
          rating: 4.5,
          reviewCount: 120,
          categories: ['Fast Food', 'Burgers'],
          priceRange: '\$',
          isOpen: true,
          openingHours: '08:00',
          closingHours: '22:00',
          deliveryFee: 2.99,
          deliveryTime: 30,
          latitude: 37.7749,
          longitude: -122.4194,
          featuredItems: [
            MenuItem(
              id: 1,
              restaurantId: 1,
              name: 'Whopper',
              description: 'The iconic burger',
              price: 5.99,
              image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
              category: 'Burgers',
              isAvailable: true,
              rating: 4.7,
              reviewCount: 85,
            ),
            MenuItem(
              id: 2,
              restaurantId: 1,
              name: 'Chicken Royale',
              description: 'Crispy chicken sandwich',
              price: 4.99,
              image: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086',
              category: 'Chicken',
              isAvailable: true,
              rating: 4.5,
              reviewCount: 65,
            ),
          ],
        ),
        Restaurant(
          id: 2,
          name: 'Pizza Hut',
          description: 'America\'s favorite pizza',
          address: '456 Oak St, City',
          phone: '+1234567891',
          image: 'https://images.unsplash.com/photo-1590947132387-155cc02f3212',
          rating: 4.2,
          reviewCount: 98,
          categories: ['Pizza', 'Italian'],
          priceRange: '\$\$',
          isOpen: true,
          openingHours: '10:00',
          closingHours: '23:00',
          deliveryFee: 1.99,
          deliveryTime: 40,
          latitude: 37.7739,
          longitude: -122.4312,
          featuredItems: [
            MenuItem(
              id: 3,
              restaurantId: 2,
              name: 'Pepperoni Pizza',
              description: 'Classic pepperoni pizza',
              price: 12.99,
              image: 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee',
              category: 'Pizza',
              isAvailable: true,
              rating: 4.8,
              reviewCount: 92,
            ),
          ],
        ),
        Restaurant(
          id: 3,
          name: 'Taco Bell',
          description: 'Think outside the bun',
          address: '789 Pine St, City',
          phone: '+1234567892',
          image: 'https://images.unsplash.com/photo-1552332386-f8dd00dc2f85',
          rating: 3.9,
          reviewCount: 76,
          categories: ['Mexican', 'Fast Food'],
          priceRange: '\$',
          isOpen: true,
          openingHours: '09:00',
          closingHours: '01:00',
          deliveryFee: 3.99,
          deliveryTime: 25,
          latitude: 37.7729,
          longitude: -122.4232,
          featuredItems: [
            MenuItem(
              id: 4,
              restaurantId: 3,
              name: 'Crunchy Taco',
              description: 'Classic crunchy taco',
              price: 1.99,
              image: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b',
              category: 'Tacos',
              isAvailable: true,
              rating: 4.3,
              reviewCount: 58,
            ),
          ],
        ),
        Restaurant(
          id: 4,
          name: 'Subway',
          description: 'Eat fresh',
          address: '101 Elm St, City',
          phone: '+1234567893',
          image: 'https://images.unsplash.com/photo-1530469912745-a215c6b256ea',
          rating: 4.0,
          reviewCount: 112,
          categories: ['Sandwiches', 'Healthy'],
          priceRange: '\$',
          isOpen: true,
          openingHours: '07:00',
          closingHours: '22:00',
          deliveryFee: 2.49,
          deliveryTime: 35,
          latitude: 37.7719,
          longitude: -122.4132,
          featuredItems: [
            MenuItem(
              id: 5,
              restaurantId: 4,
              name: 'Italian BMT',
              description: 'Classic Italian sub',
              price: 6.99,
              image: 'https://images.unsplash.com/photo-1509722747041-616f39b57569',
              category: 'Sandwiches',
              isAvailable: true,
              rating: 4.6,
              reviewCount: 78,
            ),
          ],
        ),
        Restaurant(
          id: 5,
          name: 'Starbucks',
          description: 'Coffee and more',
          address: '202 Maple St, City',
          phone: '+1234567894',
          image: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
          rating: 4.7,
          reviewCount: 156,
          categories: ['Coffee', 'Breakfast'],
          priceRange: '\$\$',
          isOpen: true,
          openingHours: '06:00',
          closingHours: '20:00',
          deliveryFee: 3.49,
          deliveryTime: 20,
          latitude: 37.7709,
          longitude: -122.4032,
          featuredItems: [
            MenuItem(
              id: 6,
              restaurantId: 5,
              name: 'Caramel Macchiato',
              description: 'Espresso with caramel',
              price: 4.95,
              image: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d',
              category: 'Coffee',
              isAvailable: true,
              rating: 4.9,
              reviewCount: 112,
            ),
          ],
        ),
      ];
    }

    final headers = await getHeaders();
    final queryParams = {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (sortBy != null) 'sort_by': sortBy,
    };

    final uri = Uri.parse('$baseUrl/restaurants').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants: ${response.body}');
    }
  }

  Future<Restaurant> getRestaurantDetails(int restaurantId) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final restaurants = await getRestaurants();
      return restaurants.firstWhere((r) => r.id == restaurantId);
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/$restaurantId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Restaurant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load restaurant details: ${response.body}');
    }
  }

  // Menu Items
  Future<List<MenuItem>> getMenuItems(int restaurantId, {String? category}) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        MenuItem(
          id: 1,
          restaurantId: restaurantId,
          name: 'Whopper',
          description: 'The iconic burger with flame-grilled beef patty, tomatoes, lettuce, mayo, pickles, and onions on a sesame seed bun.',
          price: 5.99,
          image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
          category: 'Burgers',
          isAvailable: true,
          isVegetarian: false,
          isVegan: false,
          isGlutenFree: false,
          rating: 4.7,
          reviewCount: 85,
          options: [
            MenuItemOption(
              id: 1,
              name: 'Size',
              choices: [
                MenuItemOptionChoice(id: 1, name: 'Regular', price: 0),
                MenuItemOptionChoice(id: 2, name: 'Double', price: 2.00),
                MenuItemOptionChoice(id: 3, name: 'Triple', price: 3.50),
              ],
              required: true,
              maxSelections: 1,
            ),
            MenuItemOption(
              id: 2,
              name: 'Add-ons',
              choices: [
                MenuItemOptionChoice(id: 4, name: 'Cheese', price: 0.50),
                MenuItemOptionChoice(id: 5, name: 'Bacon', price: 1.00),
                MenuItemOptionChoice(id: 6, name: 'Avocado', price: 1.50),
              ],
              required: false,
              maxSelections: 3,
            ),
          ],
        ),
        MenuItem(
          id: 2,
          restaurantId: restaurantId,
          name: 'Chicken Royale',
          description: 'Crispy chicken breast fillet with lettuce and mayo on a long sesame seed bun.',
          price: 4.99,
          image: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086',
          category: 'Chicken',
          isAvailable: true,
          isVegetarian: false,
          isVegan: false,
          isGlutenFree: false,
          rating: 4.5,
          reviewCount: 65,
          options: [
            MenuItemOption(
              id: 3,
              name: 'Spice Level',
              choices: [
                MenuItemOptionChoice(id: 7, name: 'Regular', price: 0),
                MenuItemOptionChoice(id: 8, name: 'Spicy', price: 0.50),
              ],
              required: true,
              maxSelections: 1,
            ),
          ],
        ),
        MenuItem(
          id: 3,
          restaurantId: restaurantId,
          name: 'French Fries',
          description: 'Golden crispy french fries, perfectly salted.',
          price: 2.49,
          image: 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d',
          category: 'Sides',
          isAvailable: true,
          isVegetarian: true,
          isVegan: true,
          isGlutenFree: false,
          rating: 4.3,
          reviewCount: 92,
          options: [
            MenuItemOption(
              id: 4,
              name: 'Size',
              choices: [
                MenuItemOptionChoice(id: 9, name: 'Small', price: 0),
                MenuItemOptionChoice(id: 10, name: 'Medium', price: 0.50),
                MenuItemOptionChoice(id: 11, name: 'Large', price: 1.00),
              ],
              required: true,
              maxSelections: 1,
            ),
          ],
        ),
        MenuItem(
          id: 4,
          restaurantId: restaurantId,
          name: 'Coca-Cola',
          description: 'Refreshing Coca-Cola soft drink.',
          price: 1.99,
          image: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97',
          category: 'Drinks',
          isAvailable: true,
          isVegetarian: true,
          isVegan: true,
          isGlutenFree: true,
          rating: 4.8,
          reviewCount: 45,
          options: [
            MenuItemOption(
              id: 5,
              name: 'Size',
              choices: [
                MenuItemOptionChoice(id: 12, name: 'Small', price: 0),
                MenuItemOptionChoice(id: 13, name: 'Medium', price: 0.50),
                MenuItemOptionChoice(id: 14, name: 'Large', price: 1.00),
              ],
              required: true,
              maxSelections: 1,
            ),
            MenuItemOption(
              id: 6,
              name: 'Ice',
              choices: [
                MenuItemOptionChoice(id: 15, name: 'Regular Ice', price: 0),
                MenuItemOptionChoice(id: 16, name: 'Less Ice', price: 0),
                MenuItemOptionChoice(id: 17, name: 'No Ice', price: 0),
              ],
              required: true,
              maxSelections: 1,
            ),
          ],
        ),
        MenuItem(
          id: 5,
          restaurantId: restaurantId,
          name: 'Chocolate Sundae',
          description: 'Creamy vanilla soft serve with chocolate sauce.',
          price: 2.99,
          image: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb',
          category: 'Desserts',
          isAvailable: true,
          isVegetarian: true,
          isVegan: false,
          isGlutenFree: false,
          rating: 4.6,
          reviewCount: 38,
          options: [
            MenuItemOption(
              id: 7,
              name: 'Toppings',
              choices: [
                MenuItemOptionChoice(id: 18, name: 'Sprinkles', price: 0.25),
                MenuItemOptionChoice(id: 19, name: 'Nuts', price: 0.50),
                MenuItemOptionChoice(id: 20, name: 'Whipped Cream', price: 0.25),
              ],
              required: false,
              maxSelections: 3,
            ),
          ],
        ),
      ];
    }

    final headers = await getHeaders();
    final queryParams = {
      if (category != null) 'category': category,
    };

    final uri = Uri.parse('$baseUrl/restaurants/$restaurantId/menu')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MenuItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load menu items: ${response.body}');
    }
  }

  // Orders
  Future<List<Order>> getOrders() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Order(
          id: 1,
          userId: 1,
          restaurantId: 1,
          restaurantName: 'Burger King',
          restaurantImage: 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9',
          items: [
            CartItem(
              menuItem: MenuItem(
                id: 1,
                restaurantId: 1,
                name: 'Whopper',
                description: 'The iconic burger',
                price: 5.99,
                image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
                category: 'Burgers',
                isAvailable: true,
              ),
              quantity: 2,
              totalPrice: 11.98,
            ),
            CartItem(
              menuItem: MenuItem(
                id: 3,
                restaurantId: 1,
                name: 'French Fries',
                description: 'Golden crispy french fries',
                price: 2.49,
                image: 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d',
                category: 'Sides',
                isAvailable: true,
              ),
              quantity: 1,
              totalPrice: 2.49,
            ),
          ],
          subtotal: 14.47,
          deliveryFee: 2.99,
          tax: 1.45,
          tip: 2.00,
          total: 20.91,
          status: 'delivered',
          paymentMethod: 'Credit Card',
          paymentStatus: 'paid',
          deliveryAddress: '123 Main St, City',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          estimatedDeliveryTime: DateTime.now().subtract(const Duration(days: 2, minutes: 30)),
          statusUpdates: [
            OrderStatusUpdate(
              status: 'pending',
              timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 30)),
            ),
            OrderStatusUpdate(
              status: 'confirmed',
              timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 25)),
            ),
            OrderStatusUpdate(
              status: 'preparing',
              timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 15)),
            ),
            OrderStatusUpdate(
              status: 'out_for_delivery',
              timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
              message: 'Your order is on the way!',
            ),
            OrderStatusUpdate(
              status: 'delivered',
              timestamp: DateTime.now().subtract(const Duration(days: 2, minutes: 30)),
              message: 'Your order has been delivered. Enjoy!',
            ),
          ],
        ),
        Order(
          id: 2,
          userId: 1,
          restaurantId: 2,
          restaurantName: 'Pizza Hut',
          restaurantImage: 'https://images.unsplash.com/photo-1590947132387-155cc02f3212',
          items: [
            CartItem(
              menuItem: MenuItem(
                id: 3,
                restaurantId: 2,
                name: 'Pepperoni Pizza',
                description: 'Classic pepperoni pizza',
                price: 12.99,
                image: 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee',
                category: 'Pizza',
                isAvailable: true,
              ),
              quantity: 1,
              totalPrice: 12.99,
            ),
          ],
          subtotal: 12.99,
          deliveryFee: 1.99,
          tax: 1.30,
          tip: 2.50,
          total: 18.78,
          status: 'out_for_delivery',
          paymentMethod: 'PayPal',
          paymentStatus: 'paid',
          deliveryAddress: '123 Main St, City',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 15)),
          driver: DeliveryDriver(
            id: 1,
            name: 'Mike Johnson',
            phone: '+1234567890',
            profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
            rating: 4.8,
            latitude: 37.7739,
            longitude: -122.4312,
          ),
          statusUpdates: [
            OrderStatusUpdate(
              status: 'pending',
              timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            ),
            OrderStatusUpdate(
              status: 'confirmed',
              timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
            ),
            OrderStatusUpdate(
              status: 'preparing',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            ),
            OrderStatusUpdate(
              status: 'out_for_delivery',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              message: 'Your order is on the way!',
            ),
          ],
        ),
      ];
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  Future<Order> getOrderDetails(int orderId) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final orders = await getOrders();
      return orders.firstWhere((o) => o.id == orderId);
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load order details: ${response.body}');
    }
  }

  Future<Order> placeOrder({
    required int restaurantId,
    required List<CartItem> items,
    required String deliveryAddress,
    required String paymentMethod,
    double? tip,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 2));
      
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final deliveryFee = 2.99;
      final tax = subtotal * 0.1;
      final tipAmount = tip ?? 0.0;
      final total = subtotal + deliveryFee + tax + tipAmount;
      
      return Order(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1,
        restaurantId: restaurantId,
        restaurantName: 'Restaurant Name',
        restaurantImage: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        tip: tipAmount,
        total: total,
        status: 'pending',
        paymentMethod: paymentMethod,
        paymentStatus: 'paid',
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 45)),
        statusUpdates: [
          OrderStatusUpdate(
            status: 'pending',
            timestamp: DateTime.now(),
          ),
        ],
      );
    }

    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: jsonEncode({
        'restaurant_id': restaurantId,
        'items': items.map((item) => item.toJson()).toList(),
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        if (tip != null) 'tip': tip,
      }),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to place order: ${response.body}');
    }
  }

  // User Profile
  Future<User> getUserProfile() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        address: '123 Main St, City',
        profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        role: 'customer',
      );
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  Future<User> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: 1,
        name: name ?? 'John Doe',
        email: 'john.doe@example.com',
        phone: phone ?? '+1234567890',
        address: address ?? '123 Main St, City',
        profileImage: profileImage ?? 'https://randomuser.me/api/portraits/men/1.jpg',
        role: 'customer',
      );
    }

    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (profileImage != null) 'profile_image': profileImage,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }

  // Addresses
  Future<List<Address>> getUserAddresses() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Address(
          id: 1,
          userId: 1,
          label: 'Home',
          address: '123 Main St',
          city: 'San Francisco',
          state: 'CA',
          zipCode: '94105',
          country: 'USA',
          instructions: 'Ring the doorbell',
          latitude: 37.7749,
          longitude: -122.4194,
          isDefault: true,
        ),
        Address(
          id: 2,
          userId: 1,
          label: 'Work',
          address: '456 Market St',
          city: 'San Francisco',
          state: 'CA',
          zipCode: '94103',
          country: 'USA',
          instructions: 'Leave at reception',
          latitude: 37.7899,
          longitude: -122.4014,
          isDefault: false,
        ),
      ];
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/addresses'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load addresses: ${response.body}');
    }
  }

  // Payment Methods
  Future<List<PaymentMethod>> getUserPaymentMethods() async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        PaymentMethod(
          id: 1,
          userId: 1,
          type: 'credit_card',
          lastFour: '4242',
          brand: 'Visa',
          holderName: 'John Doe',
          expiryDate: '12/25',
          isDefault: true,
        ),
        PaymentMethod(
          id: 2,
          userId: 1,
          type: 'paypal',
          lastFour: '',
          brand: 'PayPal',
          holderName: 'john.doe@example.com',
          expiryDate: '',
          isDefault: false,
        ),
      ];
    }

    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/payment-methods'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment methods: ${response.body}');
    }
  }
}
