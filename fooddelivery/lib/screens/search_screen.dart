import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/screens/splash_screen.dart';
import 'package:fooddelivery/screens/login_screen.dart';
import 'package:fooddelivery/screens/register_screen.dart';
import 'package:fooddelivery/screens/home_screen.dart';
import 'package:fooddelivery/screens/restaurant_details_screen.dart';
import 'package:fooddelivery/screens/menu_item_details_screen.dart';
import 'package:fooddelivery/screens/cart_screen.dart';
import 'package:fooddelivery/screens/checkout_screen.dart';
import 'package:fooddelivery/screens/payment_method_screen.dart';
import 'package:fooddelivery/screens/order_tracking_screen.dart';
import 'package:fooddelivery/screens/orders_screen.dart';
import 'package:fooddelivery/screens/profile_screen.dart';
import 'package:fooddelivery/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:fooddelivery/providers/auth_provider.dart';
import 'package:fooddelivery/providers/restaurant_provider.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:fooddelivery/providers/order_provider.dart';
import 'package:fooddelivery/utils/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for restaurants or food',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black),
          autofocus: true,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildSearchSuggestions()
          : _buildSearchResults(),
    );
  }
  
  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Pizza'),
              _buildSuggestionChip('Burger'),
              _buildSuggestionChip('Chinese'),
              _buildSuggestionChip('Italian'),
              _buildSuggestionChip('Mexican'),
              _buildSuggestionChip('Sushi'),
              _buildSuggestionChip('Vegetarian'),
              _buildSuggestionChip('Desserts'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Mock recent searches
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Burger King'),
            trailing: const Icon(Icons.north_west),
            onTap: () {
              _searchController.text = 'Burger King';
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Pizza'),
            trailing: const Icon(Icons.north_west),
            onTap: () {
              _searchController.text = 'Pizza';
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Chinese food'),
            trailing: const Icon(Icons.north_west),
            onTap: () {
              _searchController.text = 'Chinese food';
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
      },
    );
  }
  
  Widget _buildSearchResults() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        // Trigger search when query changes
        if (provider.searchQuery != _query) {
          provider.fetchRestaurants(search: _query);
        }
        
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error searching restaurants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.fetchRestaurants(search: _query),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (provider.restaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$_query"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try a different search term or browse restaurants',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = provider.restaurants[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Restaurant image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            restaurant.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.restaurant, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Restaurant details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.categories.join(', '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant.deliveryTime} min',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  restaurant.priceRange,
                                  style: Theme.of(context).textTheme.bodySmall,
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
          },
        );
      },
    );
  }
}
