import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth_viewmodel.dart';

class ViewTeamMembersPage extends StatefulWidget {
  const ViewTeamMembersPage({super.key});

  @override
  State<ViewTeamMembersPage> createState() => _ViewTeamMembersPageState();
}

class _ViewTeamMembersPageState extends State<ViewTeamMembersPage> {
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  Set<int> _visibleCodes = {};

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final employees = await authVM.getTeamMembers();

    setState(() {
      _employees = employees;
      _isLoading = false;
    });
  }

  void _toggleCodeVisibility(int actorId) {
    setState(() {
      if (_visibleCodes.contains(actorId)) {
        _visibleCodes.remove(actorId);
      } else {
        _visibleCodes.add(actorId);
      }
    });
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Team Members',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? const Center(
        child: Text(
          'No team members yet',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTeamMembers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _employees.length,
          itemBuilder: (context, index) {
            final employee = _employees[index];
            final actorId = employee['actor_id'] as int;
            final firstName = employee['first_name'] as String;
            final lastName = employee['last_name'] as String;
            final code = employee['permanent_code'] as String?;
            final isVisible = _visibleCodes.contains(actorId);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF2D2D2D),
                          child: Text(
                            '${firstName[0]}${lastName[0]}'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                employee['email'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Permanent Code: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isVisible && code != null ? code : '••••••',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF666666),
                          ),
                          onPressed: () => _toggleCodeVisibility(actorId),
                        ),
                        if (code != null)
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: Color(0xFF666666),
                            ),
                            onPressed: () => _copyToClipboard(code),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
