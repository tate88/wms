import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:WMS/ui/GRN/GRN_page.dart';
import 'package:WMS/constants/constant.dart';
import 'package:WMS/ui/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:WMS/constants/pref_data.dart';
import 'dart:async';
import 'package:WMS/constants/color_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = "ADMIN";
  final String userID = "ADMIN001";
  final String project1Attributes = "Project 1 Attributes";
  final String version = "T10.9";
  String selectedLocation = "03 HCM COLDSTORAGE"; // Changed to mutable
  late Timer _timer;
  String _currentDateTime = "";
  
  // Add list of available locations
  final List<String> availableLocations = [
    "01 HCM WAREHOUSE",
    "02 HCM DISTRIBUTION",
    "03 HCM COLDSTORAGE",
    "04 HN WAREHOUSE",
    "05 HN COLDSTORAGE",
    "06 DN WAREHOUSE",
  ];
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Receiving', 'image': 'assets/images/Receiving_style_2_30_1.png'},
    {'title': 'Putaway', 'image': 'assets/images/Putaway_style_2_30_1.png'},
    {
      'title': 'Stock Movement',
      'image': 'assets/images/Stock_movement_style_2_30_1.png'
    },
    {
      'title': 'Location Transfer',
      'image': 'assets/images/Location_transfer_style_2_30_1.png'
    },
    {'title': 'Picking', 'image': 'assets/images/Picking_style_2_30_1.png'},
    {'title': 'Loading', 'image': 'assets/images/Loading_style_2_30_1.png'},
    {
      'title': 'Stock Count',
      'image': 'assets/images/Stock_count_style_2_30_1.png'
    },
    {
      'title': 'Palletization',
      'image': 'assets/images/Palletization_style_2_30_1.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

void _updateTime() {
  final now = DateTime.now();
  setState(() {
    _currentDateTime =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  });
}

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onMenuItemTap(String title) {
    HapticFeedback.selectionClick();

    switch (title) {
      case 'Receiving':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GRNPage()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title selected'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _shareLogs() {
    // TODO: Implement share logs functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs shared successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearLogs() {
    // TODO: Implement clear logs functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs cleared successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to calculate proper positioning
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 900;

    // Calculate header height dynamically
    final headerHeight = isTablet
        ? (isLargeTablet ? 240.0 : 200.0)
        : (isSmallScreen ? 160.0 : 180.0);

    // Calculate grid top position: statusBar + header - overlap
    final gridTopPosition =
        statusBarHeight + headerHeight - 50; // Adjust overlap

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header Section - Always on top
          Column(
            children: [
              // Add padding for status bar
              Container(
                color: AppColors.primaryBlue,
                height: statusBarHeight,
              ),
              Container(
                height: headerHeight,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,// Corporate blue
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _currentDateTime,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Header Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: project1Attributes,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          // Version and Location Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Show location selector when settings icon is tapped
                                      _showLocationSelector();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                     
                                      child: const Icon(
                                        Icons.settings,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedLocation,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              // Flexible(
                              //   child: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       const Icon(
                              //         Icons.location_on,
                              //         color: Colors.orange,
                              //         size: 18,
                              //       ),
                              //       const SizedBox(width: 6),
                              //       Flexible(
                              //         child: Text(
                              //           location,
                              //           style: TextStyle(
                              //             color: Colors.orange,
                              //             fontSize: isSmallScreen ? 10 : 12,
                              //             fontWeight: FontWeight.w500,
                              //           ),
                              //           overflow: TextOverflow.ellipsis,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Overlapping Menu Cards - Positioned below header text
          Positioned(
            top: gridTopPosition,
            left: isTablet ? 32 : 16,
            right: isTablet ? 32 : 16,
            bottom: 0,
            child: GridView.builder(
              padding: const EdgeInsets.only(
                top: 20, // Add padding to prevent covering header text
                bottom: 20,
              ),
              physics: const BouncingScrollPhysics(), // Enable bouncing scroll
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLargeTablet ? 4 : (isTablet ? 3 : 2),
                crossAxisSpacing: isTablet ? 20 : (isSmallScreen ? 12 : 16),
                mainAxisSpacing: isTablet ? 20 : (isSmallScreen ? 12 : 16),
                childAspectRatio: 1.0,
                mainAxisExtent: isTablet
                    ? (isLargeTablet ? 200 : 190)
                    : (isSmallScreen ? 160 : 180),
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuCard(
                  title: item['title'],
                  image: item['image'],
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildMenuDrawer(),
    );
  }

  Widget _buildMenuDrawer() {
    return Drawer(
      backgroundColor: Colors.white ,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
         
            decoration: const BoxDecoration(
               color: AppColors.primaryBlue,
               
            ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30
              ), 
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar with Animation
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF0E426C), // Corporate blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              userID,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
             
              ],
            ),
          ),

          // Divider with some spacing
          const SizedBox(height: 8),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
              //  color: const Color(0xFF0E426C).withOpacity(0.1), // Blue
          
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.share,
                color: AppColors.primaryBlue,
                size: 20,
              ), // Blue
            ),
            title: const Text(
              'Share Logs',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _shareLogs();
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
              //  color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.orange, size: 20), // Red with greyish tint
            ),
            title: const Text(
              'Clear Logs',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _clearLogs();
            },
          ),

          const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
               // color: const Color(0xFF2E7D32).withOpacity(0.1), // Green
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(
               fontWeight: FontWeight.w500,
             
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey, 
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showLogoutConfirmation();
            },
          ),

          const SizedBox(height: 20),

          // Footer with app version
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ScotPHY WMS v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required String title, required String image}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Define colors for different menu items
    Color getBorderColor(String title) {
      switch (title.toLowerCase()) {
        case 'receiving':
          return const Color(0xFF64B5F6); // Red
        case 'putaway':
          return const Color(0xFF64B5F6); // Blue
        case 'stock movement':
          return const Color(0xFF64B5F6); // Green
        case 'location transfer':
          return const Color(0xFF64B5F6); // Orange
        case 'picking':
          return const Color(0xFF64B5F6); // Purple
        case 'loading':
          return const Color(0xFF64B5F6); // Teal
        case 'stock count':
          return const Color(0xFF64B5F6); // Pink
        case 'palletization':
          return const Color(0xFF64B5F6); // Deep Purple
        default:
          return const Color(0xFF64B5F6); // Default Blue
      }
    }

    return GestureDetector(
      onTap: () => _onMenuItemTap(title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
                color: getBorderColor(title), width: isTablet ? 5 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: isTablet ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    image,
                    fit: BoxFit
                        .contain, // Use BoxFit.contain to scale down the image
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Title Section
          ],
        ),
      ),
    );
  }

  // Add this method to show logout confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFF4A6B8A), size: 24), // Blue with greyish tint
              const SizedBox(width: 12),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear only the logged-in state, keep user info for next login
                final prefs = await SharedPreferences.getInstance();
                await PrefData.setLogIn(false);

                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6B8A), // Blue with greyish tint
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // Add this method to show location selector modal with snackbar
  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Location list
                ...availableLocations.map((location) {
                final isSelected = location == selectedLocation;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                  title: Text(
                    location,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primaryBlue: Colors.black87,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedLocation = location;
                    });
                    Navigator.pop(context);
                    
                    // Show snackbar with selected location
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('Location changed to: $location'),
                          ],
                        ),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                );
              }).toList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
