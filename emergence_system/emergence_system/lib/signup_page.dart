import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_logo.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

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
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please fill in all required fields, including your name.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userModel = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        role: 'user',
        phoneNumber: _phoneController.text.trim(),
      );

      if (userModel != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome ${userModel.fullName}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (route) => false); // Go to root
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please use a stronger password.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed. Please try again.';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
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
                        labelText: 'Email *',
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
                      controller: _nameController,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintText: 'Enter your phone number',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone,
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
                        labelText: 'Password *',
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
                        onPressed: _isLoading ? null : _signUp,
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
                                'Sign Up',
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Login',
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
