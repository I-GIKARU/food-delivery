import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps; // Add alias
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  gmaps.GoogleMapController? _mapController;
  Set<gmaps.Marker> _markers = {}; // Use the aliased type
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();

    // Set up periodic refresh for order status
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshOrderDetails();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrderDetails(widget.orderId);
    _updateMapMarkers();
  }

  Future<void> _refreshOrderDetails() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrderDetails(widget.orderId);
    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final order = orderProvider.selectedOrder;

    if (order == null || order.driver == null) return;

    setState(() {
      _markers = {
        // Restaurant marker
        gmaps.Marker( // Use the aliased Marker class
          markerId: const gmaps.MarkerId('restaurant'),
          position: gmaps.LatLng(37.7749, -122.4194), // Mock restaurant location
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
          infoWindow: gmaps.InfoWindow(title: order.restaurantName),
        ),

        // Delivery address marker
        gmaps.Marker(
          markerId: const gmaps.MarkerId('delivery_address'),
          position: gmaps.LatLng(37.7849, -122.4294), // Mock delivery address
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
          infoWindow: const gmaps.InfoWindow(title: 'Delivery Address'),
        ),

        // Driver marker
        gmaps.Marker(
          markerId: const gmaps.MarkerId('driver'),
          position: gmaps.LatLng(
            order.driver!.latitude,
            order.driver!.longitude,
          ),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
          infoWindow: gmaps.InfoWindow(title: 'Driver: ${order.driver!.name}'),
        ),
      };
    });

    // Move camera to driver location
    _mapController?.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(order.driver!.latitude, order.driver!.longitude),
        14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = provider.selectedOrder;

          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Order not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrderDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Order status
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    // Order ID and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildStatusChip(order.status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Order progress
                    _buildOrderProgress(order),
                  ],
                ),
              ),

              // Map view
              if (order.status != 'pending' && order.status != 'cancelled')
                Expanded(
                  flex: 2,
                  child: gmaps.GoogleMap(
                    initialCameraPosition: const gmaps.CameraPosition(
                      target: gmaps.LatLng(37.7749, -122.4194), // Default to San Francisco
                      zoom: 13,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _updateMapMarkers();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                  ),
                ),

              // Order details
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant info
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: CachedNetworkImage(
                                imageUrl: order.restaurantImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.restaurant, size: 30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.restaurantName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                if (order.estimatedDeliveryTime != null)
                                  Text(
                                    'Estimated delivery: ${_formatDateTime(order.estimatedDeliveryTime!)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Driver info
                      if (order.driver != null && order.status == 'out_for_delivery')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Driver',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: CachedNetworkImageProvider(
                                        order.driver!.profileImage,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.driver!.name,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                order.driver!.rating.toString(),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.phone),
                                      onPressed: () {
                                        // Call driver
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Calling ${order.driver!.name}...'),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.message),
                                      onPressed: () {
                                        // Message driver
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Messaging ${order.driver!.name}...'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Order items
                      Text(
                        'Order Items',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menuItem.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
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

                      // Order summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${order.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee'),
                          Text('\$${order.deliveryFee.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax'),
                          Text('\$${order.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (order.tip > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tip'),
                            Text('\$${order.tip.toStringAsFixed(2)}'),
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
                            '\$${order.total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Delivery address
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.deliveryAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      // Payment info
                      Text(
                        'Payment',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Method: ${order.paymentMethod}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Status: ${order.paymentStatus}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: order.paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Order status history
                      Text(
                        'Order Status Updates',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...order.statusUpdates.map((update) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (update != order.statusUpdates.last)
                                    Container(
                                      width: 2,
                                      height: 30,
                                      color: Colors.grey.shade300,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatStatusText(update.status),
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(update.timestamp),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (update.message != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        update.message!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 24),

                      // Support button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Contact support
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contacting support...'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Contact Support'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.grey;
        text = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'Confirmed';
        break;
      case 'preparing':
        color = Colors.orange;
        text = 'Preparing';
        break;
      case 'out_for_delivery':
        color = Colors.purple;
        text = 'Out for Delivery';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildOrderProgress(Order order) {
    const allStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'out_for_delivery',
      'delivered',
    ];

    // If order is cancelled, show special UI
    if (order.status == 'cancelled') {
      return Column(
        children: [
          Lottie.asset(
            'assets/animations/cancelled.json',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 8),
          const Text('Order Cancelled'),
        ],
      );
    }

    // Find current status index
    final currentStatusIndex = allStatuses.indexOf(order.status);
    if (currentStatusIndex == -1) return const SizedBox.shrink();

    return Row(
      children: List.generate(allStatuses.length, (index) {
        final isCompleted = index <= currentStatusIndex;
        final isActive = index == currentStatusIndex;

        return Expanded(
          child: Column(
            children: [
              // Status indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  )
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
                    : null,
              ),

              // Status line
              if (index < allStatuses.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 3,
                    color: index < currentStatusIndex
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),

              const SizedBox(height: 8),

              // Status text
              Text(
                _formatStatusText(allStatuses[index]),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : isCompleted
                      ? Colors.black
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'out_for_delivery':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.split('_').map((word) =>
        word.substring(0, 1).toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute $period';
  }
}