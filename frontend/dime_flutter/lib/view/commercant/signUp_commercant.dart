import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_viewmodel.dart';
import '../../vm/components/address_autocomplete.dart';
import 'signIn_commercant.dart';

class SignUpCommercantPage extends StatefulWidget {
  const SignUpCommercantPage({super.key});

  @override
  State<SignUpCommercantPage> createState() => _SignUpCommercantPageState();
}

class _SignUpCommercantPageState extends State<SignUpCommercantPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal info controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Store info controllers
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Canada'); // prérempli Canada

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms of Service')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authVM.commercantSignUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      storeName: _storeNameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store account created! Please sign in.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInCommercantPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Sign up failed')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: const Color(0xFFF0F0F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
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
                const Text('Sign Up', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                const Text(
                  'Create your store account and start managing your business.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5),
                ),
                const SizedBox(height: 32),

                const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        validator: (v) => v?.isEmpty ?? true ? 'Please enter your first name' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        validator: (v) => v?.isEmpty ?? true ? 'Please enter your last name' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Please enter email';
                    if (!v!.contains('@')) return 'Please enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF666666)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Please enter password';
                    if (v!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                const Text('Store Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _storeNameController,
                  hintText: 'Store Name',
                  validator: (v) => v?.isEmpty ?? true ? 'Please enter store name' : null,
                ),
                const SizedBox(height: 16),

                AddressAutocomplete(
                  addressController: _addressController,
                  onPlaceSelected: (place) {
                    _cityController.text = place['city'] ?? _cityController.text;
                    _postalCodeController.text = place['postal_code'] ?? _postalCodeController.text;
                    _countryController.text = place['country'] ?? _countryController.text;
                    if ((_countryController.text).isEmpty || (_countryController.text.toLowerCase() != 'canada')) {
                      _countryController.text = 'Canada';
                    }
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _cityController,
                        hintText: 'City',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _postalCodeController,
                        hintText: 'Postal Code',
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _countryController,
                  hintText: 'Country',
                  readOnly: true, // verrouille le pays
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter country' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      activeColor: const Color(0xFF5D5266),
                    ),
                    const Expanded(
                      child: Text(
                        "I'm agree to The Terms of Service and Privacy Policy",
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Store Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInCommercantPage()),
                    ),
                    child: const Text('Already have an account? Sign In', style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
