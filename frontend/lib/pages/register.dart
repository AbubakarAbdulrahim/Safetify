import 'package:flutter/material.dart';
import 'package:safetify/services/auth_service.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  
  bool _loading = false;

  final AuthService authService = AuthService();

  Future<void> _register() async {
    if (_loading) return;

    // validation
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _loading = true);

    final fullName = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phoneNumber = phoneCtrl.text.trim();
    final password = passCtrl.text.trim();

    try {
      final user = await authService.register(fullName, email, phoneNumber, password);

      if (user != null) {
        if (mounted) {
          setState(() => _loading = false);
        } else {

          return;
        }

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text('Your account has been created successfully. Please log in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.'), backgroundColor: AppColors.alertRed,),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.alertRed,),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Center(
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.safetyBlue,
                  size: 60,
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              _buildTextField(
                controller: nameCtrl,
                label: 'Full name',
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: emailCtrl,
                label: 'Email address',
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: phoneCtrl,
                label: 'Phone number',
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: passCtrl,
                label: 'Password',
                obscure: true,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safetyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.safetyBlue.withOpacity(0.8),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Login',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.safetyBlue, width: 2),
        ),
      ),
    );
  }
}
