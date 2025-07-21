import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_logo.dart';
import 'screens/change_password_screen.dart'; // Corrected import for ChangePasswordScreen
import 'screens/employee_dashboard.dart'; // Corrected import for EmployeeDashboard

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter both email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userModel = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userModel != null && mounted) {
        if (userModel.mustChangePassword) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(user: userModel),
            ),
          );
        } else {
          // Navigate to the appropriate dashboard
          if (userModel.role == 'employee') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EmployeeDashboard(user: userModel),
              ),
            );
          } else {
            // Add navigation for other roles as needed
            // For now, just show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        setState(() {
          _error = 'Login failed. Please check your credentials.';
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }
      setState(() {
        _error = errorMessage;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? const LinearGradient(
                  colors: [Color(0xFF181A20), Color(0xFF23262F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFF7043)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ScaleTransition(
              scale: _cardAnimation,
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF23262F)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.10),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Company Motto
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.deepOrange, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "LET'S SAVE THE WORLD",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepOrange, Colors.red],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Branded logo
                    AppLogo.buildWithBackground(size: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to your account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.deepOrange,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF23262F)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.deepOrange,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepOrange,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF23262F)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Forgot password feature coming soon!',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
