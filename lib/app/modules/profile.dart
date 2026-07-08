import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/data/controller/purposeController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authController = Get.find<AuthController>();
  final purposeController = Get.put(PurposeController());
  
  final formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: authController.user.value?['name'] ?? '',
    );
    emailController = TextEditingController(
      text: authController.user.value?['email'] ?? '',
    );
    purposeController.getPurposes();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      authController.updateProfile(
        username: usernameController.text,
        email: emailController.text,
      );
      setState(() {
        isEditing = false;
      });
    }
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showPurposeDialog({int? id, String? currentName}) {
    final nameController = TextEditingController(text: currentName);
    final purposeFormKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          id == null ? 'Add Purpose' : 'Edit Purpose',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal),
        ),
        content: Form(
          key: purposeFormKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Purpose Name',
              hintText: 'e.g., Vacation, Education',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (purposeFormKey.currentState!.validate()) {
                if (id == null) {
                  purposeController.addPurpose(name: nameController.text.trim());
                } else {
                  purposeController.updatePurpose(id: id, name: nameController.text.trim());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(id == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
        actions: [
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppTheme.darkTeal),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Header with Avatar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, Color(0xFF07656A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          (authController.user.value?['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      authController.user.value?['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Email
                    Text(
                      authController.user.value?['email'] ?? 'email@example.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. Profile Details Form / View
              if (isEditing) _buildEditForm() else _buildProfileView(context),
              const SizedBox(height: 28),

              // 3. Purpose Management Section (New Position)
              if (!isEditing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Purposes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryTeal, size: 26),
                      onPressed: () => _showPurposeDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPurposesList(),
                const SizedBox(height: 32),
              ],

              // 4. Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red[100]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkTeal,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.person_outline,
          label: 'Username',
          value: authController.user.value?['name'] ?? 'N/A',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.email_outlined,
          label: 'Email',
          value: authController.user.value?['email'] ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
            ),
          ),
          const SizedBox(height: 16),
          // Username Input
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryTeal),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Email Input
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Save & Cancel Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: authController.isLoading.value ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurposesList() {
    if (purposeController.isLoading.value && purposeController.purposes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }
    
    if (purposeController.purposes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No purposes added yet.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purposeController.purposes.length,
      itemBuilder: (context, index) {
        final purpose = purposeController.purposes[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2222) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                    child: const Icon(Icons.star_rounded, color: AppTheme.primaryTeal, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    purpose.name,
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkTeal),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                    onPressed: () => _showPurposeDialog(id: purpose.id, currentName: purpose.name),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Delete Purpose', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal)),
                          content: const Text('Are you sure you want to delete this purpose?'),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                purposeController.deletePurpose(purpose.id);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
            child: Icon(icon, color: AppTheme.primaryTeal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkTeal),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
