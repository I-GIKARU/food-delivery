import 'package:flutter/material.dart';
import 'package:fooddelivery/models/models.dart';
import 'package:fooddelivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fooddelivery/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
      
      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                
                // Profile image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: CachedNetworkImageProvider(
                    user.profileImage.isNotEmpty
                        ? user.profileImage
                        : 'https://ui-avatars.com/api/?name=${user.name}&size=120',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // User name
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // User role
                Chip(
                  label: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 24),
                
                // Profile form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email field (disabled)
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        enabled: false,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home),
                        ),
                        enabled: _isEditing,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Edit/Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    child: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Additional options
                const ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Saved Addresses'),
                  trailing: Icon(Icons.chevron_right),
                ),
                
                const Divider(),
                
                const ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Payment Methods'),
                  trailing: Icon(Icons.chevron_right),
                ),
                
                const Divider(),
                
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notification Settings'),
                  trailing: Icon(Icons.chevron_right),
                ),
                
                const Divider(),
                
                const ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.chevron_right),
                ),
                
                const Divider(),
                
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
