import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'location_transfer_page.dart';
import 'location_to_page.dart';
import 'put_away_page.dart';
import 'location_transfer_req.dart';
import '../../constants/wms_constant.dart';

class LocationTransferSelectionPage extends StatelessWidget {
  const LocationTransferSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: GRNConstants.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title:
          const Text('Location Transfer', style: GRNConstants.headerStyle),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        

            // Transfer Options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Put Away Option
                    _buildTransferOption(
                      context: context,
                      title: 'Direct Transfer',
                      subtitle: 'Receive item directly',
                      description:
                          '',
                      icon: Icons.drive_file_move,
                      color: GRNConstants.primaryBlue,
                      onTap: () => _navigateToPutAway(context),
                    ),

                    const SizedBox(height: 20),

                    // Transfer From Option
                    _buildTransferOption(
                      context: context,
                      title: 'Load Transfer',
                      subtitle: 'Move item to carrier',
                  
                      icon: Icons.logout,
                      color: GRNConstants.primaryBlue,
                      onTap: () => _navigateToTransferFrom(context),
                    ),

                    const SizedBox(height: 20),

                    // Transfer To Option
                    _buildTransferOption(
                      context: context,
                      title: 'Receive Transfer',
                      subtitle: 'Receive item from carrier',
                 
                      icon: Icons.login,
                      color: GRNConstants.primaryBlue,
                      onTap: () => _navigateToTransferTo(context),
                    ),


                        const SizedBox(height: 20),

                    // Transfer To Option
                    _buildTransferOption(
                      context: context,
                      title: 'Transfer Request From',
                      subtitle: 'Receive item from carrier',
                      icon: Icons.login,
                      color: GRNConstants.primaryBlue,
                      onTap: () => _navigateToTransferRequestFrom(context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    String? description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
           
          ],
        ),
      ),
    );
  }

  void _navigateToPutAway(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PutAwayPage(),
      ),
    );
  }

  void _navigateToTransferFrom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationTransferPage(),
      ),
    );
  }

  void _navigateToTransferTo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationToPage(),
      ),
    );
  }
    void _navigateToTransferRequestFrom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationTransferReqPage(),
      ),
    );
  }
}
