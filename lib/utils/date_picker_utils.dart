import 'package:WMS/ui/GRN/constants/grn_constants.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? backgroundColor,
  Color? headerColor,
  Color? headerTextColor,
  Color? bodyTextColor,
  Color? buttonTextColor,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor:
              backgroundColor ?? Colors.white, // Default to white
          colorScheme: ColorScheme.light(
            primary: headerColor ?? GRNConstants.primaryBlue, // Header background color
            onPrimary: headerTextColor ?? Colors.white, // Header text color
            onSurface: bodyTextColor ?? Colors.black, // Body text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor:
                  buttonTextColor ?? GRNConstants.primaryBlue,// Button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
