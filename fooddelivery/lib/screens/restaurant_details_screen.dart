import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/restaurant_provider.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fooddelivery/screens/menu_item_details_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    await restaurantProvider.fetchRestaurantDetails(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        final restaurant = provider.selectedRestaurant;
        
        return Scaffold(
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : restaurant == null
                  ? const Center(child: Text('Restaurant not found'))
                  : CustomScrollView(
                      slivers: [
                        // App bar with restaurant image
                        SliverAppBar(
                          expandedHeight: 200,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: CachedNetworkImage(
                              imageUrl: restaurant.image,
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
                        ),
                        
                        // Restaurant info
                        SliverToBoxAdapter(
                          child: Padding(
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
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.rating.toString(),
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${restaurant.reviewCount})',
                                          style: Theme.of(context).textTheme.bodyMedium,
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
                                      label: Text(category),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Description
                                Text(
                                  restaurant.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Delivery info
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${restaurant.deliveryTime} min',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.delivery_dining,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Hours
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: restaurant.isOpen ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      restaurant.isOpen ? 'Open Now' : 'Closed',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${restaurant.openingHours} - ${restaurant.closingHours}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Menu categories
                                Text(
                                  'Menu',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Menu categories
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.getMenuCategories().length,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                final category = provider.getMenuCategories()[index];
                                final isSelected = _selectedCategory == category;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = selected ? category : null;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Menu items
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final menuItems = _selectedCategory == null
                                    ? provider.menuItems
                                    : provider.menuItems.where(
                                        (item) => item.category == _selectedCategory
                                      ).toList();
                                
                                if (index >= menuItems.length) return null;
                                
                                final menuItem = menuItems[index];
                                return MenuItemCard(
                                  menuItem: menuItem,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuItemDetailsScreen(
                                          menuItem: menuItem,
                                          restaurantName: restaurant.name,
                                          restaurantImage: restaurant.image,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback onTap;
  
  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: menuItem.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Menu item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      menuItem.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      menuItem.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${menuItem.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        
                        // Quick add button
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                cartProvider.addItem(
                                  menuItem: menuItem,
                                  quantity: 1,
                                );
                                
                                // Set restaurant info in cart
                                final restaurantProvider = Provider.of<RestaurantProvider>(
                                  context, 
                                  listen: false
                                );
                                final restaurant = restaurantProvider.selectedRestaurant;
                                if (restaurant != null) {
                                  cartProvider.setRestaurantInfo(
                                    restaurant.name,
                                    restaurant.image,
                                  );
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${menuItem.name} added to cart'),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/cart');
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
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
}
