import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fooddelivery/screens/home_screen.dart';
import 'package:fooddelivery/screens/login_screen.dart';
import 'package:fooddelivery/screens/register_screen.dart';
import 'package:fooddelivery/screens/forgot_password.dart';
import 'package:provider/provider.dart';
import 'package:fooddelivery/utils/theme.dart';
import 'package:fooddelivery/screens/splash_screen.dart';
import 'package:fooddelivery/services/api_service.dart';
import 'package:fooddelivery/services/location_service.dart';
import 'package:fooddelivery/services/auth_service.dart';
import 'package:fooddelivery/providers/auth_provider.dart';
import 'package:fooddelivery/providers/cart_provider.dart';
import 'package:fooddelivery/providers/restaurant_provider.dart';
import 'package:fooddelivery/providers/order_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<RestaurantProvider>(
          create: (context) => RestaurantProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Food Delivery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/home': (context) => const HomeScreen(),
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
