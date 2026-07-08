import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/data/controller/purposeController.dart';
import 'package:extend_system/app/data/controller/categoryController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final authController = Get.find<AuthController>();
  final purposeController = Get.put(PurposeController());
  final categoryController = Get.put(CategoryController());

  final formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  bool isEditing = false;
  late RxBool isDarkMode;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: authController.user.value?['name'] ?? '',
    );
    emailController = TextEditingController(
      text: authController.user.value?['email'] ?? '',
    );
    isDarkMode = Get.isDarkMode.obs;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _submitProfileForm() {
    if (formKey.currentState!.validate()) {
      authController.updateProfile(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
      );
      setState(() {
        isEditing = false;
      });
    }
  }

  void _showAddCategoryDialog(String type) {
    final nameController = TextEditingController();
    final catFormKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add ${type.capitalizeFirst} Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.darkTeal,
          ),
        ),
        content: Form(
          key: catFormKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Shopping, Freelance',
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
              if (catFormKey.currentState!.validate()) {
                categoryController.addCategory(
                  name: nameController.text.trim(),
                  type: type,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddPurposeDialog() {
    final nameController = TextEditingController();
    final purpFormKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Purpose',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.darkTeal,
          ),
        ),
        content: Form(
          key: purpFormKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Purpose Name',
              hintText: 'e.g., Trip, Car, House',
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
              if (purpFormKey.currentState!.validate()) {
                purposeController.addPurpose(name: nameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.darkTeal,
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.darkTeal,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Card Section
            Obx(() {
              final userName = authController.user.value?['name'] ?? 'User';
              final userEmail = authController.user.value?['email'] ?? 'email@example.com';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, Color(0xFF07656A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.close_rounded : Icons.edit_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            if (isEditing) _buildProfileEditForm(isDark) else ...[
              // Preferences / Theme Section
              _buildSectionTitle("Preferences", isDark),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2222) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                  ),
                ),
                child: Obx(
                  () => SwitchListTile(
                    title: const Text(
                      "Dark Mode",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      isDarkMode.value ? "Dark theme active" : "Light theme active",
                      style: const TextStyle(fontSize: 11),
                    ),
                    secondary: Icon(
                      isDarkMode.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppTheme.primaryTeal,
                    ),
                    value: isDarkMode.value,
                    activeColor: AppTheme.primaryTeal,
                    onChanged: (val) {
                      isDarkMode.value = val;
                      Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category & Purpose Creation Section
              _buildSectionTitle("Quick Management", isDark),
              const SizedBox(height: 10),
              _buildSettingItem(
                icon: Icons.add_chart_rounded,
                label: "Add Income Category",
                color: Colors.green,
                isDark: isDark,
                onTap: () => _showAddCategoryDialog("income"),
              ),
              const SizedBox(height: 10),
              _buildSettingItem(
                icon: Icons.remove_circle_outline_rounded,
                label: "Add Expense Category",
                color: Colors.red,
                isDark: isDark,
                onTap: () => _showAddCategoryDialog("expense"),
              ),
              const SizedBox(height: 10),
              _buildSettingItem(
                icon: Icons.star_outline_rounded,
                label: "Add Purpose",
                color: AppTheme.primaryTeal,
                isDark: isDark,
                onTap: _showAddPurposeDialog,
              ),
              const SizedBox(height: 32),

              // Logout Button
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[400] : AppTheme.darkTeal,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.08),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildProfileEditForm(bool isDark) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Edit Details', isDark),
          const SizedBox(height: 16),
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
              fillColor: isDark ? const Color(0xFF1E2222) : Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
              fillColor: isDark ? const Color(0xFF1E2222) : Colors.white,
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
                  onPressed: authController.isLoading.value ? null : _submitProfileForm,
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
}
