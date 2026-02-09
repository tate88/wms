// ignore: file_names
import 'dart:convert';
import 'package:country_state_city_picker/model/select_status_model.dart'
    as status;
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:WMS/constants/pref_data.dart';
import 'package:WMS/constants/size_config.dart';
import 'package:WMS/constants/color_data.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:WMS/ui/home/home_screen.dart';

import '../../constants/constant.dart';
import '../../constants/widget_utils.dart';
import '../home/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController idleTimeController = TextEditingController();
  final TextEditingController autoSaveTimeController = TextEditingController();
  int _selectedTabbar = 0;
  TextEditingController phoneRegController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController passSignInController = TextEditingController();
  ValueNotifier<bool> isShowPass = ValueNotifier(false);
  bool chkVal = false;

  final _formKey = GlobalKey<FormState>();
  String? _selectedCompanyId;
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Initialize company codes and country lists
  final List<Map<String, String>> _companies = [
    {'id': 'ACME001', 'name': 'ACME Corporation'},
    {'id': 'TECH002', 'name': 'Tech Solutions Ltd'},
    {'id': 'GLOB003', 'name': 'Global Logistics Inc'},
    {'id': 'SMART004', 'name': 'Smart Warehouse Co'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _loadSettings();
    _loadLastLoginInfo();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', urlController.text);
    //await prefs.setString('idle_time', idleTimeController.text);
    // await prefs.setString('auto_save_time', autoSaveTimeController.text);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      urlController.text = prefs.getString('server_url') ?? '';
      idleTimeController.text = prefs.getString('idle_time') ?? '';
      autoSaveTimeController.text = prefs.getString('auto_save_time') ?? '';
    });
  }

  Future<void> _loadLastLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCompanyId = prefs.getString('last_company_id');
      _userIdController.text = prefs.getString('last_user_id') ?? '';
     
    });
  }

  Future<void> _saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_company_id', _selectedCompanyId ?? '');
    await prefs.setString('last_user_id', _userIdController.text);
    await PrefData.setLogIn(true);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      HapticFeedback.lightImpact();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        await _saveLoginInfo();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Welcome, ${_userIdController.text}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        print('Company: $_selectedCompanyId');
        print('User ID: ${_userIdController.text}');
        print('Password: ${_passwordController.text}');

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        });
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 20,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // URL Input
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'Enter server URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Idle Time Input
              TextFormField(
                controller: idleTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idle Time (seconds)',
                  hintText: 'Enter seconds (e.g., 30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auto Final Save Time Input
              TextFormField(
                controller: autoSaveTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idle Time Auto Final(seconds)',
                  hintText: 'Enter seonds(e.g., 30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Save the settings (you can implement actual saving logic here)
                await _saveSettings();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernContainer({required Widget child, double? height}) {
    return child;
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return _buildModernContainer(
      height: 56,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon:
              Icon(prefixIcon, color: const Color(0xFF1E3A8A), size: 22),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true, // Enable background fill
          fillColor: Colors.white, // Set consistent white background
        ),
        validator: validator,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final availableHeight = constraints.maxHeight - keyboardHeight;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 32.0,
                        right: 32.0,
                        bottom: keyboardHeight > 0 ? 20.0 : 0.0,
                      ),
                      child: Column(
                        mainAxisAlignment: keyboardHeight > 0
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          // Add top spacing when keyboard is visible
                          if (keyboardHeight > 0) const SizedBox(height: 20),
                          // Modern Logo Section (reduced margins)
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      24,
                                    ),
                                    boxShadow: [],
                                  ),
                                  child: Image.asset(
                                    'assets/images/dns-logo.png',
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'ScotPHY WMS',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A202C),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Smart Control • Real Results',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Modern Login Form
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(20), // Reduced from 24
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.08), // Reduced opacity
                                  spreadRadius: 2, // Reduced from 4
                                  blurRadius: 8, // Reduced from 12
                                  offset: const Offset(0, 4), // Reduced from 6
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(16.0), // Further reduced
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Input your credentials',
                                        style: TextStyle(
                                          fontSize: 16, // Further reduced
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 16), // Further reduced

                                    // Company Dropdown
                                    Text(
                                      'Company',
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 14
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6), // Reduced from 8
                                    _buildModernContainer(
                                      height: 48, // Reduced from 56
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCompanyId,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          hintText: 'Select your company',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14, // Reduced from 16
                                            fontWeight: FontWeight.w400,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.business_outlined,
                                            color: const Color(0xFF1E3A8A),
                                            size: 18, // Reduced from 22
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Reduced from 16
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1.0, // Reduced from 1.5
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12, // Reduced from 16
                                            vertical: 8, // Reduced from 12
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF2D3748),
                                          fontSize: 14, // Reduced from 16
                                          fontWeight: FontWeight.w500,
                                        ),
                                        dropdownColor: Colors.white,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a company';
                                          }
                                          return null;
                                        },
                                        items: _companies.map((company) {
                                          return DropdownMenuItem<String>(
                                            value: company['id'],
                                            child: Text(
                                              company['name']!,
                                              style: const TextStyle(
                                                color: Color(0xFF2D3748),
                                                fontSize: 14, // Reduced from 16
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCompanyId = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade600,
                                          size: 20, // Reduced size
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 16), // Reduced from 24

                                    // User ID Field
                                    Text(
                                      'User ID',
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 14
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6), // Reduced from 8
                                    _buildModernInput(
                                      controller: _userIdController,
                                      hintText: 'Enter your user ID',
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your user ID';
                                        }
                                        if (value.length < 3) {
                                          return 'User ID must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.next,
                                    ),

                                    const SizedBox(
                                        height: 16), // Reduced from 24

                                    // Password Field
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 14
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6), // Reduced from 8
                                    _buildModernInput(
                                      controller: _passwordController,
                                      hintText: 'Enter your password',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.black,
                                          size: 18, // Reduced from 20
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _login(),
                                    ),

                                    const SizedBox(
                                        height: 20), // Reduced from 24

                                    // Modern Sign In Button
                                    Container(
                                      width: double.infinity,
                                      height: 48, // Reduced from 56
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2b4e86),
                                        borderRadius: BorderRadius.circular(
                                            12), // Reduced from 16
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Reduced from 16
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20, // Reduced from 24
                                                height: 20, // Reduced from 24
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2.0, // Reduced from 2.5
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize:
                                                      14, // Reduced from 16
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

                          // Conditional spacing based on keyboard
                          SizedBox(height: keyboardHeight > 0 ? 8 : 16),

                          // Modern Footer - hide when keyboard is visible
                          if (keyboardHeight == 0)
                            Text(
                              '© 2025 ScotPHY. All rights reserved.',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Settings Button - Top Right
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showSettings,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
