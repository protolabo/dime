import 'package:dime_flutter/view/commercant/signUp_commercant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth_viewmodel.dart';
import '../../vm/current_store.dart';
import 'choose_commerce.dart';
import 'create_qr_menu.dart';

class SignInCommercantPage extends StatefulWidget {
  const SignInCommercantPage({super.key});

  @override
  State<SignInCommercantPage> createState() => _SignInCommercantPageState();
}

class _SignInCommercantPageState extends State<SignInCommercantPage> {
  final _formKey = GlobalKey<FormState>();
  final _employeeCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureCode = true;
  bool _isLoading = false;

  bool _useEmployeeCode = false;

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    bool success;
    if (_useEmployeeCode) {
      //impleeeementation
       success = true;
       // await authVM.employeeSignIn(
       //   code: _employeeCodeController.text.trim(),
       // );
    } else {
      success = await authVM.commercantSignIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    await CurrentStoreService.setCurrentStore(authVM.stores?[0]['store_id']);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateQrMenuPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Sign in failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your account to continue your experience with Dime.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Employee Code field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _employeeCodeController,
                    obscureText: _obscureCode,
                    decoration: InputDecoration(
                      hintText: 'Employee Code',
                      hintStyle: const TextStyle(color: Colors.black87),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCode ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF666666),
                        ),
                        onPressed: () =>
                            setState(() => _obscureCode = !_obscureCode),
                      ),
                    ),
                    validator: (value) {
                      if (_useEmployeeCode && (value?.isEmpty ?? true)) {
                        return 'Please enter employee code';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() => _useEmployeeCode = true);
                      } else if (_emailController.text.isEmpty &&
                          _passwordController.text.isEmpty) {
                        setState(() => _useEmployeeCode = false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'Or',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Manager Email field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Manager Email',
                      hintStyle: TextStyle(color: Colors.black87),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (!_useEmployeeCode && (value?.isEmpty ?? true)) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      if (val.isNotEmpty || _passwordController.text.isNotEmpty) {
                        setState(() => _useEmployeeCode = false);
                      } else if (_employeeCodeController.text.isEmpty) {
                        setState(() => _useEmployeeCode = false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Manager Password field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Manager Password',
                      hintStyle: const TextStyle(color: Colors.black87),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF666666),
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (!_useEmployeeCode && (value?.isEmpty ?? true)) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      if (val.isNotEmpty || _emailController.text.isNotEmpty) {
                        setState(() => _useEmployeeCode = false);
                      } else if (_employeeCodeController.text.isEmpty) {
                        setState(() => _useEmployeeCode = false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implement forgot password
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                      children: [
                        const TextSpan(text: "Don't have account? "),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpCommercantPage(),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFFE57373),
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
