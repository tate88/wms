import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/outstanding_stock_models.dart';
import '../constants/outstanding_stock_constants.dart';

class OutstandingStockService {
  static final OutstandingStockService _instance = OutstandingStockService._internal();
  factory OutstandingStockService() => _instance;
  OutstandingStockService._internal();

  /// Fetch outstanding stock data from API
  Future<List<OutstandingStockItem>> fetchOutstandingStock(String poNumber) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(seconds: 1));

      // For now, return sample data
      // In real implementation, this would be an HTTP request
      final List<Map<String, dynamic>> apiData = OutstandingStockConstants.sampleApiData;
      
      return apiData.map((data) => OutstandingStockItem.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch outstanding stock: $e');
    }
  }

  /// Process receive stock transaction
  Future<ReceiveStockData> processReceiveStock({
    required OutstandingStockItem item,
    required int quantity,
    required String uom,
    required String poNumber,
  }) async {
    try {
      // Simulate API processing delay
      await Future.delayed(Duration(seconds: 2));

      // Create receive transaction data
      final receiveData = ReceiveStockData(
        quantity: quantity,
        uom: uom,
      );

      // In real implementation, this would send data to API
      // For now, just simulate success
      return receiveData;
    } catch (e) {
      throw Exception('Failed to process receive transaction: $e');
    }
  }

  /// Get PO details
  Future<PODetails> getPODetails(String poNumber) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 500));

      // Return sample PO details
      // In real implementation, this would fetch from API
      return PODetails(
        poNumber: poNumber,
        supplier: 'ABC Suppliers Ltd',
        date: formatDisplayDate(DateTime.now().subtract(Duration(days: 7))),
        refNo: poNumber,
       
      );
    } catch (e) {
      throw Exception('Failed to fetch PO details: $e');
    }
  }

  /// Update outstanding quantities after receive
  List<OutstandingStockItem> updateOutstandingQuantities({
  required List<OutstandingStockItem> currentItems,
  required OutstandingStockItem receivedItem,
  required int receivedQuantity,
}) {
  return currentItems.map((item) {
    if (item.stkCode == receivedItem.stkCode) {
      final newOutstanding = item.trxStkQty - receivedQuantity;
      return OutstandingStockItem(
        stkCode: item.stkCode,
        stkNameS: item.stkNameS,
        trxUom: item.trxUom,
        trxStkQty: newOutstanding > 0 ? newOutstanding : 0,
        trxETDDate: item.trxETDDate,
        stkQty: item.stkQty,
        stkUom: item.stkUom,
        availableUoms: item.availableUoms,
      );
    }
    return item;
  }).where((item) => item.trxStkQty > 0).toList();
}
  /// Filter items by search query
  List<OutstandingStockItem> filterItems({
    required List<OutstandingStockItem> items,
    required String query,
  }) {
    if (query.isEmpty) return items;

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) {
      return item.stkCode.toLowerCase().contains(lowercaseQuery) ||
             item.stkNameS.toLowerCase().contains(lowercaseQuery) ||
             item.trxUom.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Sort items by different criteria
  List<OutstandingStockItem> sortItems({
    required List<OutstandingStockItem> items,
    required String sortBy,
    bool ascending = true,
  }) {
    final sortedItems = List<OutstandingStockItem>.from(items);
    
    switch (sortBy) {
      case 'stockCode':
        sortedItems.sort((a, b) => 
          ascending 
            ? a.stkCode.compareTo(b.stkCode)
            : b.stkCode.compareTo(a.stkCode));
        break;
      case 'stockName':
        sortedItems.sort((a, b) => 
          ascending 
            ? a.stkNameS.compareTo(b.stkNameS)
            : b.stkNameS.compareTo(a.stkNameS));
        break;
      case 'quantity':
        sortedItems.sort((a, b) => 
          ascending 
            ? a.trxStkQty.compareTo(b.trxStkQty)
            : b.trxStkQty.compareTo(a.trxStkQty));
        break;
      case 'etdDate':
        sortedItems.sort((a, b) {
          final aDate = _parseDate(a.trxETDDate);
          final bDate = _parseDate(b.trxETDDate);
          return ascending 
            ? aDate.compareTo(bDate)
            : bDate.compareTo(aDate);
        });
        break;
      default:
        break;
    }
    
    return sortedItems;
  }

  /// Validate receive quantity
  bool validateReceiveQuantity({
    required int quantity,
    required int outstandingQuantity,
  }) {
    return quantity > 0 && quantity <= outstandingQuantity;
  }

  /// Get available UOMs for an item
  List<String> getAvailableUOMs(OutstandingStockItem item) {
    return item.availableUoms ?? [item.trxUom];
  }

  /// Calculate receive progress percentage
  double calculateReceiveProgress({
    required List<OutstandingStockItem> originalItems,
    required List<OutstandingStockItem> currentItems,
  }) {
    if (originalItems.isEmpty) return 0.0;

    final originalTotal = originalItems.fold<int>(
      0, (sum, item) => sum + item.trxStkQty);
    final currentTotal = currentItems.fold<int>(
      0, (sum, item) => sum + item.trxStkQty);

    final receivedTotal = originalTotal - currentTotal;
    return originalTotal > 0 ? (receivedTotal / originalTotal) * 100 : 0.0;
  }

  /// Export outstanding stock to JSON
  String exportToJson(List<OutstandingStockItem> items) {
    final data = items.map((item) => item.toMap()).toList();
    return jsonEncode(data);
  }

  /// Import outstanding stock from JSON
  List<OutstandingStockItem> importFromJson(String jsonString) {
    try {
      final List<dynamic> data = jsonDecode(jsonString);
      return data.map((json) => OutstandingStockItem.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to import data: Invalid JSON format');
    }
  }

  /// Generate unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'RCV${timestamp.toString().substring(8)}$random';
  }

  /// Parse date string (DD/MM/YYYY format)
  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      // If parsing fails, return current date
    }
    return DateTime.now();
  }

  /// Format date to display string
  String formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  /// Get formatted currency display
  String formatCurrency(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Get status color based on outstanding quantity
  Color getStatusColor(int outstandingQty, int originalQty) {
    final percentage = outstandingQty / originalQty;
    if (percentage <= 0.25) return Colors.green;
    if (percentage <= 0.5) return Colors.orange;
    if (percentage <= 0.75) return Colors.amber;
    return Colors.red;
  }

  /// Get progress color
  Color getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 50) return Colors.orange;
    if (progress >= 25) return Colors.amber;
    return Colors.red;
  }
}