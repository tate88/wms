import 'package:flutter/material.dart';

class GRNConstants {
  static const Color primaryBlue = Color(0xFF2b4e86);
  static const Color lightBlue = Color(0xFF3a5998);
  static const Color accentBlue = Color(0xFF1E3A8A);
  static const Color orange = Colors.orange;
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textDark = Color(0xFF1A202C);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color borderGray = Color(0xFFE2E8F0);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const TextStyle headerStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle formLabelStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
  );
  static const TextStyle valueStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle tableHeaderStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color.fromARGB(255, 12, 12, 12),
  );

  static const TextStyle tableRowIdStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
  );

  static const TextStyle stockCodeStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
  );

  static const TextStyle stockNameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static final TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: GRNConstants.textMedium,
  );

  static const TextStyle tableRowTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textMedium,
  );

  static const TextStyle tableRowBoldStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle emptyStateHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF64748B),
  );

  static const TextStyle emptyStateSubStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF94A3B8),
  );

  static const TextStyle dialogHeaderStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const double borderRadius = 8.0;
  static const double containerHeight = 56.0;
  static const double iconSize = 20.0;

  // Sample AP data with codes and names
  static const List<Map<String, String>> apOptions = [
    {'apCode': 'SUP001', 'apName': 'ANG JUN SHIPPING AGENCIES'},
    {'apCode': 'SUP002', 'apName': 'BONANZA SHIPPING AGENCIES SDN BHD'},
    {'apCode': 'SUP003', 'apName': 'CASH SUPPLIER'},
    {'apCode': 'SUP004', 'apName': 'Tech Solutions'},
    {'apCode': 'SUP005', 'apName': 'Global Trading'},
    {'apCode': 'SUP006', 'apName': 'Maritime Services'},
    {'apCode': 'SUP007', 'apName': 'Supply Chain Co'},
    {'apCode': 'SUP008', 'apName': 'Ocean Freight Services'},
    {'apCode': 'SUP009', 'apName': 'Express Logistics'},
    {'apCode': 'SUP010', 'apName': 'International Trading'}
  ];

  // Text styles

  // Border radius
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double dialogBorderRadius = 16.0;
}
