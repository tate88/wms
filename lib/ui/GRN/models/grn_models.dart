class GRNItem {
  final int seq;
  final int lineNo;
  final String barcode;
  final String shortName;
  final int qty;
  final String lotNo;
  final String batchNo;
  final DateTime expDate;
  final DateTime mfgDate;

  GRNItem(
      {required this.seq,
      required this.lineNo,
      required this.barcode,
      required this.shortName,
      required this.qty,
      required this.lotNo,
      required this.batchNo,
      required this.expDate,
      required this.mfgDate});

  Map<String, dynamic> toMap() {
    return {
      'seq': seq,
      'barcode': barcode,
      'qty': qty,
    };
  }

  factory GRNItem.fromMap(Map<String, dynamic> map) {
    return GRNItem(
      seq: map['seq'],
      lineNo: map['lineNo'],
      barcode: map['barcode'],
      qty: map['qty'],
      shortName: map['shortName'],
      lotNo: map['lotNo'],
      batchNo: map['batchNo'],
      mfgDate: map['mfgDate'],
      expDate: map['expDate'],
    );
  }

  GRNItem copyWith({
    int? seq,
    int? lineNo,
    String? barcode,
    String? shortName,
    int? qty,
    DateTime? timestamp,
    String? lotNo,
    String? batchNo,
    DateTime? mfgDate,
    DateTime? expDate,
  }) {
    return GRNItem(
      seq: seq ?? this.seq,
      lineNo: lineNo ?? this.lineNo,
      barcode: barcode ?? this.barcode,
      shortName: shortName ?? this.shortName,
      qty: qty ?? this.qty,

      lotNo: lotNo ?? this.lotNo,
      batchNo: batchNo ?? this.batchNo,
      mfgDate: mfgDate ?? this.mfgDate,
      expDate: expDate ?? this.expDate,
    );
  }
}

class GRNData {
  final String? selectedAP;
  final DateTime selectedDate;
  final List<GRNItem> scannedItems;
  final int currentSeqNumber;
  final bool canPrintBarcode;

  GRNData({
    this.selectedAP,
    required this.selectedDate,
    required this.scannedItems,
    required this.currentSeqNumber,
    required this.canPrintBarcode,
  });

  GRNData copyWith({
    String? selectedAP,
    DateTime? selectedDate,
    List<GRNItem>? scannedItems,
    int? currentSeqNumber,
    bool? canPrintBarcode,
  }) {
    return GRNData(
      selectedAP: selectedAP ?? this.selectedAP,
      selectedDate: selectedDate ?? this.selectedDate,
      scannedItems: scannedItems ?? this.scannedItems,
      currentSeqNumber: currentSeqNumber ?? this.currentSeqNumber,
      canPrintBarcode: canPrintBarcode ?? this.canPrintBarcode,
    );
  }

  int get totalQuantity => scannedItems.fold(0, (sum, item) => sum + item.qty);
}
