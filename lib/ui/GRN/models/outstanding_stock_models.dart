class OutstandingStockItem {
  final String stkCode;
  final String stkNameS;
  final String trxUom;
  final int trxStkQty;
  final String trxETDDate;
  final int stkQty;
  final String stkUom;
  final List<String> availableUoms;

  OutstandingStockItem({
    required this.stkCode,
    required this.stkNameS,
    required this.trxUom,
    required this.trxStkQty,
    required this.trxETDDate,
    required this.stkQty,
    required this.stkUom,
    required this.availableUoms,
  });

  factory OutstandingStockItem.fromMap(Map<String, dynamic> map) {
    return OutstandingStockItem(
      stkCode: map['StkCode']?.toString() ?? '',
      stkNameS: map['StkNameS']?.toString() ?? '',
      trxUom: map['TrxUom']?.toString() ?? '',
      trxStkQty: map['TrxStkQty'] ?? 0,
      trxETDDate: map['TrxETDDate']?.toString() ?? '',
      stkQty: map['StkQty'] ?? 0,
      stkUom: map['StkUom']?.toString() ?? '',
      availableUoms: List<String>.from(map['AvailableUoms'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'StkCode': stkCode,
      'StkNameS': stkNameS,
      'TrxUom': trxUom,
      'TrxStkQty': trxStkQty,
      'TrxETDDate': trxETDDate,
      'StkQty': stkQty,
      'StkUom': stkUom,
      'AvailableUoms': availableUoms,
    };
  }
}

class ReceiveStockData {
  final int quantity;
  final String uom;

  ReceiveStockData({
    required this.quantity,
    required this.uom,
  });
}

class PODetails {
  final String poNumber;
  final String supplier;
  final String date;
  final String refNo;

  PODetails({
    required this.poNumber,
    required this.supplier,
    required this.date,
    required this.refNo,
  });
}

class OutstandingStockState {
  final List<OutstandingStockItem> items;
  final bool isLoading;
  final PODetails poDetails;

  OutstandingStockState({
    required this.items,
    required this.isLoading,
    required this.poDetails,
  });

  OutstandingStockState copyWith({
    List<OutstandingStockItem>? items,
    bool? isLoading,
    PODetails? poDetails,
  }) {
    return OutstandingStockState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      poDetails: poDetails ?? this.poDetails,
    );
  }
}


