import 'package:dime_flutter/view/commercant/scan_page_commercant.dart';
import 'package:dime_flutter/view/commercant/search_page_commercant.dart';
import 'package:dime_flutter/view/commercant/viewTeamMembers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth_viewmodel.dart';
import '../components/header_commercant.dart';
import '../components/nav_bar_commercant.dart';
import '../styles.dart';
import 'create_qr_menu.dart';

class ManageTeamPage extends StatefulWidget {
  const ManageTeamPage({super.key});

  @override
  State<ManageTeamPage> createState() => _ManageTeamPageState();
}

class _ManageTeamPageState extends State<ManageTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _generatedCode;
  bool _obscureCode = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  void _checkAccess() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final userRole = authVM.userRole;
      if (userRole != 'owner') {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Only store owners can manage teams.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _addTeamMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final result = await authVM.addTeamMember(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      setState(() {
        _generatedCode = result['permanent_code'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team member added successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Error adding team member')),
      );
    }
  }


  void _viewCurrentMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViewTeamMembersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const HeaderCommercant(),
      body:
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Manage Your Team',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add and organize your employees to keep your store running smoothly',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // First Name and Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'FirstName',
                          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                          filled: true,
                          fillColor: const Color(0xFFF0F0F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter first name' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'LastName',
                          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                          filled: true,
                          fillColor: const Color(0xFFF0F0F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter last name' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Generated Permanent Code Display (only shows after member is added)
                if (_generatedCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permanent Code Generated:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _obscureCode ? '••••••••' : _generatedCode!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureCode ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF2E7D32),
                              ),
                              onPressed: () =>
                                  setState(() => _obscureCode = !_obscureCode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share this code with the team member to allow them to join.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Add a new Team Member button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addTeamMember,
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
                      'Add a new Team Member',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Or divider
                const Center(
                  child: Text(
                    'Or',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // See Current Team Members button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _viewCurrentMembers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7B8F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'See Current Team Members',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
          }
          else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
          }
        },
      ),
    );
  }
}