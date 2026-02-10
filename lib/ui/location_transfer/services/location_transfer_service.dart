import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_transfer_models.dart';

class LocationTransferService {
  static const String baseUrl =
      'https://api.example.com'; // Replace with your API base URL
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Submit location transfer request
  static Future<LocationTransferResponse> submitTransfer(
    LocationTransferRequest request,
  ) async {
    try {
      // Simulate network delay for demo
      await Future.delayed(const Duration(seconds: 2));

      final uri = Uri.parse('$baseUrl/transfer');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // Add any authentication headers here
              // 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toMap()),
          )
          .timeout(timeoutDuration);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        return LocationTransferResponse.fromMap(responseBody);
      } else {
        // Error response
        final errorMessage = responseBody['message'] ??
            responseBody['error'] ??
            'Transfer failed with status ${response.statusCode}';

        return LocationTransferResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      String errorMessage = 'Failed to submit transfer';

      if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Request timeout. Please check your connection and try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      return LocationTransferResponse(
        success: false,
        message: errorMessage,
      );
    }
  }

  /// Mock successful transfer for testing
  static Future<LocationTransferResponse> submitTransferMock(
    LocationTransferRequest request,
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different scenarios based on input
    if (request.forkliftCode.toLowerCase() == 'error') {
      return LocationTransferResponse(
        success: false,
        message: 'Invalid forklift code',
      );
    }

    if (request.stockCode.toLowerCase() == 'notfound') {
      return LocationTransferResponse(
        success: false,
        message: 'Stock not found in the specified location',
      );
    }

    // Default success response
    return LocationTransferResponse(
      success: true,
      message: 'Transfer completed successfully',
      transferId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
    );
  }

  /// Mock successful transfer to destination for testing
  static Future<LocationTransferResponse> submitTransferToMock(
    dynamic request, // Using dynamic to accept LocationToRequest
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Access the fields dynamically to work with LocationToRequest
    final forkliftCode = request.forkliftCode ?? '';
    final stockCode = request.stockCode ?? '';

    // Simulate different scenarios based on input
    if (forkliftCode.toLowerCase() == 'error') {
      return LocationTransferResponse(
        success: false,
        message: 'Invalid forklift code',
      );
    }

    if (stockCode.toLowerCase() == 'notfound') {
      return LocationTransferResponse(
        success: false,
        message: 'Stock not found for transfer',
      );
    }

    // Default success response for destination transfer
    return LocationTransferResponse(
      success: true,
      message: 'Stock transferred to destination successfully',
      transferId: 'TXNTO${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
    );
  }

  /// Validate barcode format (optional validation)
  static bool isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;

    // Add your barcode validation logic here
    // For example, check length, format, characters, etc.
    return barcode.length >= 3;
  }

  /// Format transfer data for display
  static String formatTransferSummary(LocationTransferData data) {
    final buffer = StringBuffer();
    buffer.writeln('Transfer Summary:');
    buffer.writeln('Forklift: ${data.forkliftCode ?? 'Not scanned'}');
    buffer.writeln('Location: ${data.sourceLocationCode ?? 'Not scanned'}');
    buffer.writeln('Stock: ${data.stockCode ?? 'Not scanned'}');
    return buffer.toString();
  }
}
