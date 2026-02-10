class LocationTransferRequest {
  final String forkliftCode;
  final String stockCode;
  final String? sourceLocationCode;
  final double quantity;

  LocationTransferRequest({
    required this.forkliftCode,
    required this.stockCode,
    required this.sourceLocationCode,
    this.quantity = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'forkliftCode': forkliftCode,
      'stockCode': stockCode,
      'quantity': quantity,
    };
  }

  factory LocationTransferRequest.fromMap(Map<String, dynamic> map) {
    return LocationTransferRequest(
      forkliftCode: map['forkliftCode'] ?? '',
      sourceLocationCode: map['sourceLocationCode'],
      stockCode: map['stockCode'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 1.0,
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
  final String? sourceLocationCode;
  final String? stockCode;
  final double? quantity;
  final String? destinationLocationCode;
  final int
      currentStep; // 0=Forklift, 1=Source Location, 2=Stock Code, 3=Quantity
  final bool isLoading;
  final String? errorMessage;
  final LocationTransferResponse? lastResponse;

  LocationTransferData({
    this.forkliftCode,
    this.sourceLocationCode,
    this.stockCode,
    this.quantity,
    this.destinationLocationCode,
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lastResponse,
  });

  LocationTransferData copyWith({
    String? forkliftCode,
    String? sourceLocationCode,
    String? stockCode,
    double? quantity,
    String? destinationLocationCode,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
    LocationTransferResponse? lastResponse,
    bool clearErrorMessage = false,
  }) {
    return LocationTransferData(
      forkliftCode: forkliftCode ?? this.forkliftCode,
      sourceLocationCode: sourceLocationCode ?? this.sourceLocationCode,
      stockCode: stockCode ?? this.stockCode,
      quantity: quantity ?? this.quantity,
      destinationLocationCode:
          destinationLocationCode ?? this.destinationLocationCode,
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
        return sourceLocationCode?.isNotEmpty == true;
      case 2:
        return stockCode?.isNotEmpty == true;
      case 3:
        return false; // Last step
      default:
        return false;
    }
  }

  bool get canSubmit {
    return forkliftCode?.isNotEmpty == true &&
        sourceLocationCode?.isNotEmpty == true &&
        stockCode?.isNotEmpty == true &&
        quantity != null &&
        quantity! > 0;
  }

  String get currentStepTitle {
    switch (currentStep) {
      case 0:
        return 'Select Forklift/Trolley';
      case 1:
        return 'Scan Source Location';
      case 2:
        return 'Scan Stock Code';
      case 3:
        return 'Enter Quantity';
      default:
        return 'Unknown Step';
    }
  }

  String get currentStepHint {
    switch (currentStep) {
      case 0:
        return 'Choose forklift with loaded stock';
      case 1:
        return 'Scan or enter location code';
      case 2:
        return 'Scan stock barcode';
      case 3:
        return 'Enter the quantity to transfer';
      default:
        return '';
    }
  }

  double get progress {
    switch (currentStep) {
      case 0:
        return 0.25;
      case 1:
        return 0.5;
      case 2:
        return 0.75;
      case 3:
        return 1.0;
      default:
        return 0.0;
    }
  }
}
