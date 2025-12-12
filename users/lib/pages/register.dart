import 'package:flutter/material.dart';
import 'package:safetify/services/auth_service.dart';
import '../constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTermsAndPrivacy = false;

  // Error messages
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool isValid = true;

    // Validate name
    if (nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter your full name');
      isValid = false;
    } else if (nameCtrl.text.trim().length < 3) {
      setState(() => _nameError = 'Name must be at least 3 characters');
      isValid = false;
    }

    // Validate email
    if (emailCtrl.text.trim().isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailCtrl.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email');
      isValid = false;
    }

    // Validate phone
    if (phoneCtrl.text.trim().isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      isValid = false;
    } else if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phoneCtrl.text.trim())) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      isValid = false;
    }

    // Validate password
    if (passCtrl.text.isEmpty) {
      setState(() => _passwordError = 'Please enter a password');
      isValid = false;
    } else if (passCtrl.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    // Validate confirm password
    if (confirmPassCtrl.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (passCtrl.text != confirmPassCtrl.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    if (!_acceptTermsAndPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms & Conditions and Privacy Policy'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      isValid = false;
    }

    if (!isValid) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }

    return isValid;
  }

  Future<void> _register() async {
    if (!_validateFields()) return;

    setState(() => _loading = true);

    try {
      await AuthService().register(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        phoneCtrl.text.trim(),
        passCtrl.text,
      );

      //WELCOME EMAIL
      await sendWelcomeEmail(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
      );

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has been created successfully. Please sign in',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safetyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  Future<void> sendWelcomeEmail(String name, String email) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final idToken = await user.getIdToken();

  final url = Uri.parse("https://safetify-backend.onrender.com/email/welcome");

  final body = jsonEncode({
    "email": email,
    "name": name,
  });

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $idToken",
    },
    body: body,
  );

  print("Welcome email response: ${response.body}");
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
                        Icons.person_add_alt_1_rounded,
                        size: 50,
                        color: AppColors.safetyBlue,
                      ),
                    ),

                    const SizedBox(height: 32),

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
                            // Full Name
                            TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                errorText: _nameError,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if (_nameError != null) setState(() => _nameError = null);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email
                            TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                errorText: _emailError,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if (_emailError != null) setState(() => _emailError = null);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Phone
                            TextField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                errorText: _phoneError,
                                hintText: 'e.g., 08012345678',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if (_phoneError != null) setState(() => _phoneError = null);
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if (_passwordError != null) setState(() => _passwordError = null);
                              },
                            ),


                            const SizedBox(height: 16),

                            // Confirm Password
                            TextField(
                              controller: confirmPassCtrl,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                errorText: _confirmPasswordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                  },
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                              },
                            ),

                            const SizedBox(height: 20),

                            // Terms & Privacy Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _acceptTermsAndPrivacy,
                                    onChanged: (value) {
                                      setState(() => _acceptTermsAndPrivacy = value ?? false);
                                    },
                                    activeColor: AppColors.safetyBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I accept the ',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pushNamed(context, '/terms'),
                                            child: const Text(
                                              'Terms & Conditions',
                                              style: TextStyle(
                                                color: AppColors.safetyBlue,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pushNamed(context, '/privacy'),
                                            child: const Text(
                                              'Privacy Policy',
                                              style: TextStyle(
                                                color: AppColors.safetyBlue,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _register,
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
                                        'Create Account',
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

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Sign In',
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
