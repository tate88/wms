// Stock Item Model

import 'package:WMS/generated/l10n.dart';

class StockItem {
  final String stockCode;
  final double quantity;
  final String? itemName;
  final String? lotNo;
  final String? lotBatch;
  final String? lotSeq;

  StockItem({
    required this.stockCode,
    required this.quantity,
    this.itemName,
    this.lotNo,
    this.lotBatch,
    this.lotSeq,
  });

  Map<String, dynamic> toMap() {
    return {
      'stockCode': stockCode,
      'quantity': quantity,
      'itemName': itemName,
      'lotNo': lotNo,
      'lotBatch': lotBatch,
      'lotSeq': lotSeq,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      stockCode: map['stockCode'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      itemName: map['itemName'] ?? '',
      lotNo: map['lotNo'] ?? '',
      lotBatch: map['lotBatch'] ?? '',
      lotSeq: map['lotSeq'] ?? '',
    );
  }
}

class LocationTransferRequest {
  final String forkliftCode;
  final List<StockItem> stockItems;
  final String? sourceLocationCode;

  LocationTransferRequest({
    required this.forkliftCode,
    required this.stockItems,
    this.sourceLocationCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'forkliftCode': forkliftCode,
      'stockItems': stockItems.map((item) => item.toMap()).toList(),
      'sourceLocationCode': sourceLocationCode,
    };
  }

  factory LocationTransferRequest.fromMap(Map<String, dynamic> map) {
    return LocationTransferRequest(
      forkliftCode: map['forkliftCode'] ?? '',
      stockItems: (map['stockItems'] as List<dynamic>?)
              ?.map((item) => StockItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      sourceLocationCode: map['sourceLocationCode'],
    );
  }
}

class LocationTransferResponse {
  final bool success;
  final String message;
  final String? transferId;
  final DateTime? timestamp;

  LocationTransferResponse({
    required this.success,
    required this.message,
    this.transferId,
    this.timestamp,
  });

  factory LocationTransferResponse.fromMap(Map<String, dynamic> map) {
    return LocationTransferResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      transferId: map['transferId'],
      timestamp:
          map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'transferId': transferId,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class LocationTransferData {
  final String? forkliftCode;
  final String? destinationLocationCode;
  final String? sourceLocationCode;
  final String? stockCode;
  final double? quantity;
  final List<StockItem> stockItems;
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;
  final LocationTransferResponse? lastResponse;

  const LocationTransferData({
    this.forkliftCode,
    this.destinationLocationCode,
    this.sourceLocationCode,
    this.stockCode,
    this.quantity,
    this.stockItems = const [],
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lastResponse,
  });

  LocationTransferData copyWith({
    String? forkliftCode,
    String? destinationLocationCode,
    String? sourceLocationCode,
    String? stockCode,
    double? quantity,
    List<StockItem>? stockItems,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
    LocationTransferResponse? lastResponse,
    bool clearErrorMessage = false,
  }) {
    return LocationTransferData(
      forkliftCode: forkliftCode ?? this.forkliftCode,
      destinationLocationCode:
          destinationLocationCode ?? this.destinationLocationCode,
      sourceLocationCode: sourceLocationCode ?? this.sourceLocationCode,
      stockCode: stockCode ?? this.stockCode,
      quantity: quantity ?? this.quantity,
      stockItems: stockItems ?? this.stockItems,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  bool get canProceedToNext {
    switch (currentStep) {
      case 0:
        return forkliftCode?.isNotEmpty == true;
      case 1:
        return stockItems.isNotEmpty;
      case 2:
        return false; // Last step
      default:
        return false;
    }
  }

  bool get canSubmit {
    return forkliftCode?.isNotEmpty == true &&
        stockItems.isNotEmpty &&
        sourceLocationCode?.isNotEmpty == true;
  }

  String get currentStepTitle {
    switch (currentStep) {
      case 0:
        return 'Select Forklift/Trolley';
      case 1:
        return 'Add Stock Items';
      case 2:
        return 'Scan Source Location';
      default:
        return 'Unknown Step';
    }
  }

  String get currentStepHint {
    switch (currentStep) {
      case 0:
        return 'Choose forklift with loaded stock';
      case 1:
        return 'Add stock items with quantities';
      case 2:
        return 'Scan or enter source location code';
      default:
        return '';
    }
  }

  double get progress {
    switch (currentStep) {
      case 0:
        return 0.33;
      case 1:
        return 0.66;
      case 2:
        return 1.0;
      default:
        return 0.0;
    }
  }
}

// Location To Request Model
class LocationToRequest {
  final String forkliftCode;
  final String destinationLocationCode;
  final List<StockItem> stockItems;

  LocationToRequest({
    required this.forkliftCode,
    required this.destinationLocationCode,
    required this.stockItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'forkliftCode': forkliftCode,
      'destinationLocationCode': destinationLocationCode,
      'stockItems': stockItems.map((item) => item.toMap()).toList(),
    };
  }

  factory LocationToRequest.fromMap(Map<String, dynamic> map) {
    return LocationToRequest(
      forkliftCode: map['forkliftCode'] ?? '',
      destinationLocationCode: map['destinationLocationCode'] ?? '',
      stockItems: (map['stockItems'] as List<dynamic>?)
              ?.map((item) => StockItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
