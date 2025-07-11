// Models for the Food Delivery App

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String role; // customer, restaurant_owner, delivery_driver

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
      email: json['email'],
      phone: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profile_picture'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'role': role,
    };
  }
}

class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final String priceRange;
  final bool isOpen;
  final String openingHours;
  final String closingHours;
  final double deliveryFee;
  final int deliveryTime; // in minutes
  final double latitude;
  final double longitude;
  final List<MenuItem> featuredItems;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    required this.priceRange,
    required this.isOpen,
    required this.openingHours,
    required this.closingHours,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.latitude,
    required this.longitude,
    this.featuredItems = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      address: json['address'],
      phone: json['phone'],
      image: json['image'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      categories: List<String>.from(json['categories']),
      priceRange: json['price_range'],
      isOpen: json['is_open'],
      openingHours: json['opening_hours'],
      closingHours: json['closing_hours'],
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      deliveryTime: json['delivery_time'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      featuredItems: json['featured_items'] != null
          ? List<MenuItem>.from(
              json['featured_items'].map((x) => MenuItem.fromJson(x)))
          : [],
    );
  }
}

class MenuItem {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isAvailable;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final List<MenuItemOption> options;
  final double rating;
  final int reviewCount;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.isAvailable,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.options = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
      isAvailable: json['is_available'],
      isVegetarian: json['is_vegetarian'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      options: json['options'] != null
          ? List<MenuItemOption>.from(
              json['options'].map((x) => MenuItemOption.fromJson(x)))
          : [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class MenuItemOption {
  final int id;
  final String name;
  final List<MenuItemOptionChoice> choices;
  final bool required;
  final int maxSelections;

  MenuItemOption({
    required this.id,
    required this.name,
    required this.choices,
    required this.required,
    required this.maxSelections,
  });

  factory MenuItemOption.fromJson(Map<String, dynamic> json) {
    return MenuItemOption(
      id: json['id'],
      name: json['name'],
      choices: List<MenuItemOptionChoice>.from(
          json['choices'].map((x) => MenuItemOptionChoice.fromJson(x))),
      required: json['required'],
      maxSelections: json['max_selections'],
    );
  }
}

class MenuItemOptionChoice {
  final int id;
  final String name;
  final double price;

  MenuItemOptionChoice({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuItemOptionChoice.fromJson(Map<String, dynamic> json) {
    return MenuItemOptionChoice(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  final int quantity;
  final List<MenuItemOptionChoice> selectedChoices;
  final String specialInstructions;
  final double totalPrice;

  CartItem({
    required this.menuItem,
    required this.quantity,
    this.selectedChoices = const [],
    this.specialInstructions = '',
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menu_item']),
      quantity: json['quantity'],
      selectedChoices: json['selected_choices'] != null
          ? List<MenuItemOptionChoice>.from(json['selected_choices']
              .map((x) => MenuItemOptionChoice.fromJson(x)))
          : [],
      specialInstructions: json['special_instructions'] ?? '',
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.id,
      'quantity': quantity,
      'selected_choices': selectedChoices.map((choice) => choice.id).toList(),
      'special_instructions': specialInstructions,
      'total_price': totalPrice,
    };
  }
}

class Order {
  final int id;
  final int userId;
  final int restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double tip;
  final double total;
  final String status; // pending, confirmed, preparing, out_for_delivery, delivered, cancelled
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final DeliveryDriver? driver;
  final List<OrderStatusUpdate> statusUpdates;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.tip,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.driver,
    this.statusUpdates = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      restaurantImage: json['restaurant_image'],
      items: List<CartItem>.from(
          json['items'].map((x) => CartItem.fromJson(x))),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      tip: (json['tip'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      deliveryAddress: json['delivery_address'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      driver: json['driver'] != null
          ? DeliveryDriver.fromJson(json['driver'])
          : null,
      statusUpdates: json['status_updates'] != null
          ? List<OrderStatusUpdate>.from(json['status_updates']
              .map((x) => OrderStatusUpdate.fromJson(x)))
          : [],
    );
  }
}

class DeliveryDriver {
  final int id;
  final String name;
  final String phone;
  final String profileImage;
  final double rating;
  final double latitude;
  final double longitude;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.profileImage,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryDriver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class OrderStatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? message;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
    );
  }
}

class Review {
  final int id;
  final int userId;
  final String userName;
  final String userImage;
  final int restaurantId;
  final int? menuItemId;
  final int? orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.restaurantId,
    this.menuItemId,
    this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userImage: json['user_image'],
      restaurantId: json['restaurant_id'],
      menuItemId: json['menu_item_id'],
      orderId: json['order_id'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
    );
  }
}

class Address {
  final int id;
  final int userId;
  final String label;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String instructions;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.instructions = '',
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      label: json['label'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      country: json['country'],
      instructions: json['instructions'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }
}

class PaymentMethod {
  final int id;
  final int userId;
  final String type; // credit_card, paypal, etc.
  final String lastFour;
  final String brand;
  final String holderName;
  final String expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.lastFour,
    required this.brand,
    required this.holderName,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      lastFour: json['last_four'],
      brand: json['brand'],
      holderName: json['holder_name'],
      expiryDate: json['expiry_date'],
      isDefault: json['is_default'] ?? false,
    );
  }
}
