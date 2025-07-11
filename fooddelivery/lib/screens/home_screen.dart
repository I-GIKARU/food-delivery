import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/auth_provider.dart';
import 'package:fooddelivery/providers/restaurant_provider.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:fooddelivery/providers/order_provider.dart';
import 'package:fooddelivery/screens/restaurant_details_screen.dart';
import 'package:fooddelivery/screens/cart_screen.dart';
import 'package:fooddelivery/screens/orders_screen.dart';
import 'package:fooddelivery/screens/profile_screen.dart';
import 'package:fooddelivery/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const RestaurantsTab(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load restaurants
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    await restaurantProvider.fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: cartProvider.itemCount > 0,
            badgeContent: Text(
              cartProvider.itemCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                if (cartProvider.itemCount > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your cart is empty')),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class RestaurantsTab extends StatefulWidget {
  const RestaurantsTab({super.key});

  @override
  State<RestaurantsTab> createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<RestaurantsTab> {
  String? _selectedCategory;
  final List<String> _categories = [
    'All',
    'Fast Food',
    'Pizza',
    'Burgers',
    'Chinese',
    'Italian',
    'Mexican',
    'Healthy',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Categories
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category || 
                                (category == 'All' && _selectedCategory == null);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected 
                          ? (category == 'All' ? null : category)
                          : null;
                    });
                    
                    // Filter restaurants
                    final restaurantProvider = Provider.of<RestaurantProvider>(
                      context, 
                      listen: false
                    );
                    restaurantProvider.fetchRestaurants(
                      category: _selectedCategory == 'All' ? null : _selectedCategory,
                    );
                  },
                ),
              );
            },
          ),
        ),
        
        // Restaurant list
        Expanded(
          child: Consumer<RestaurantProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading restaurants',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => provider.fetchRestaurants(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              if (provider.restaurants.isEmpty) {
                return const Center(
                  child: Text('No restaurants found'),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => provider.fetchRestaurants(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.restaurants[index];
                    return RestaurantCard(restaurant: restaurant);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  
  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailsScreen(
                restaurantId: restaurant.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: restaurant.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
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
                  // Restaurant name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${restaurant.reviewCount})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Categories
                  Wrap(
                    spacing: 8,
                    children: restaurant.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Delivery info
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} min',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        restaurant.priceRange,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
