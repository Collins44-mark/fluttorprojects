import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'screens/user_dashboard.dart';
import 'screens/department_dashboard.dart';
import 'screens/employee_dashboard.dart';
import 'screens/change_password_screen.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_key);
    if (mode == 'light') {
      value = ThemeMode.light;
    } else if (mode == 'dark') {
      value = ThemeMode.dark;
    } else {
      // If system theme is dark, default to light unless user chooses dark
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      value = brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_key, 'light');
    } else if (mode == ThemeMode.dark)
      await prefs.setString(_key, 'dark');
    else
      await prefs.setString(_key, 'system');
  }
}

final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'GUARDIAN SAVE',
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: Colors.deepOrange.shade50,
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepOrange.withOpacity(0.97),
              elevation: 2,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              iconTheme: const IconThemeData(color: Colors.white, size: 26),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade100,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade100,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.deepOrange, width: 2),
              ),
              labelStyle: TextStyle(
                color: Colors.deepOrange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange,
              ),
              bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
              bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            dividerTheme: DividerThemeData(
              color: Colors.deepOrange.shade100,
              thickness: 1.2,
              space: 32,
            ),
            iconTheme: const IconThemeData(color: Colors.deepOrange, size: 28),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepOrange,
            scaffoldBackgroundColor: const Color(0xFF181A20),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.deepOrange),
            ),
            cardColor: const Color(0xFF23262F),
            colorScheme: ColorScheme.dark(
              primary: Colors.deepOrange,
              secondary: Colors.orange,
              surface: Color(0xFF23262F),
            ),
          ),
          themeMode: mode,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Check if there's an error
        if (snapshot.hasError) {
          return const ErrorScreen(
            message: 'Authentication error. Please restart the app.',
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            future: _authService
                .getUserData(snapshot.data!.uid)
                .timeout(const Duration(seconds: 15)),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen(message: 'Loading user data...');
              }

              if (userSnapshot.hasError) {
                return const ErrorScreen(
                  message:
                      'Error loading user data. Please check your internet connection and try again.',
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final user = userSnapshot.data!;
                print('DEBUG: User role is: "${user.role}"'); // Debug print
                print('DEBUG: User email is: "${user.email}"'); // Debug print
                if ((user.role == 'employee' || user.role == 'worker') &&
                    (user.mustChangePassword ?? false)) {
                  print('DEBUG: Employee must change password');
                  return ChangePasswordScreen(user: user);
                }
                if (user.role == 'department' || user.role == 'admin') {
                  print('DEBUG: Going to DepartmentDashboard'); // Debug print
                  return DepartmentDashboard(user: user);
                } else if (user.role == 'employee' || user.role == 'worker') {
                  print('DEBUG: Going to EmployeeDashboard'); // Debug print
                  return EmployeeDashboard(user: user);
                } else {
                  print('DEBUG: Going to UserDashboard'); // Debug print
                  return UserDashboard(user: user);
                }
              }

              // User data not found - this shouldn't happen for authenticated users
              return const ErrorScreen(
                message:
                    'Unable to load user data. Please check your internet connection and try again.',
              );
            },
          );
        }

        // User not logged in
        return const LoginPage();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String? message;
  const SplashScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.deepOrange),
            const SizedBox(height: 24),
            Text(
              message ?? 'Loading...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 72,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement retry logic
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
