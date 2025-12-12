import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetify/constants.dart';
import 'package:safetify/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final AuthService authService = AuthService();
  
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _setupAnimations();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        emailCtrl.text = prefs.getString('saved_email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_email', emailCtrl.text.trim());
    } else {
      await prefs.remove('saved_email');
    }
  }

  bool _validateFields() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (emailCtrl.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailCtrl.text.trim())) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    }

    if (passCtrl.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (passCtrl.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    if (!isValid) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }

    return isValid;
  }

  Future<void> _login() async {
    if (_loading) return;
    if (!_validateFields()) return;

    setState(() => _loading = true);

    try {
      final user = await authService.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (user != null) {
        await _saveRememberMe();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (!mounted) return;
        setState(() {
          _passwordError = 'Invalid email or password';
          _loading = false;
        });
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Login failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      setState(() {
        _passwordError = errorMessage;
        _loading = false;
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordError = e.toString().replaceAll("Exception: ", "");
        _loading = false;
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.safetyBlue.withOpacity(0.1),
              AppColors.safetyBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.safetyBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 60,
                        color: AppColors.safetyBlue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue to Safetify',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form Card
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Email Field
                            TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                errorText: _emailError,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.safetyBlue, width: 2),
                                ),
                              ),
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: passCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                errorText: _passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.safetyBlue, width: 2),
                                ),
                              ),
                              onChanged: (_) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Remember Me & Forgot Password
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value ?? false);
                                  },
                                  activeColor: AppColors.safetyBlue,
                                ),
                                const Text('Remember me'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/forgotpassword');
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: AppColors.safetyBlue),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.safetyBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.safetyBlue,
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
