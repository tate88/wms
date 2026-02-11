class GRNRecordModel {
  final String orderId;
  final String date;
  final String apCode;
  final String apName;
  final String refNo;

  const GRNRecordModel({
    required this.orderId,
    required this.date,
    required this.apCode,
    required this.apName,
    required this.refNo,
  });

  
  factory GRNRecordModel.fromJson(Map<String, dynamic> json) {
    return GRNRecordModel(
      orderId: json['orderId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      apCode: json['apCode']?.toString() ?? '',
      apName: json['apName']?.toString() ?? '',
      refNo: json['refNo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'date': date,
      'apCode': apCode,
      'apName': apName,
      'refNo': refNo,
    };
  }
}


class GRNFilters {
  final String? selectedAPCode;
  final String selectedDate;
  final DateTime? selectedCustomDate;
  final String poNumber;
  final String invoiceNumber;

  GRNFilters({
    this.selectedAPCode,
    required this.selectedDate,
    this.selectedCustomDate,
    required this.poNumber,
    required this.invoiceNumber,
  });

  GRNFilters copyWith({
    Object? selectedAPCode = _undefined,
    String? selectedDate,
    DateTime? selectedCustomDate,
    String? poNumber,
    String? invoiceNumber,
  }) {
    return GRNFilters(
      selectedAPCode: selectedAPCode == _undefined
          ? this.selectedAPCode
          : selectedAPCode as String?,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCustomDate: selectedCustomDate ?? this.selectedCustomDate,
      poNumber: poNumber ?? this.poNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }
}

const Object _undefined = Object();

class GRNState {
  final List<GRNRecordModel> records;
  final GRNFilters filters;
  final bool isLoading;
  final String dropdownSearchQuery;

  GRNState({
    required this.records,
    required this.filters,
    required this.isLoading,
    required this.dropdownSearchQuery,
  });

  GRNState copyWith({
    List<GRNRecordModel>? records,
    GRNFilters? filters,
    bool? isLoading,
    String? dropdownSearchQuery,
  }) {
    return GRNState(
      records: records ?? this.records,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      dropdownSearchQuery: dropdownSearchQuery ?? this.dropdownSearchQuery,
    );
  }

  List<GRNRecordModel> get filteredRecords {
    

    final filtered = records.where((record) {
      bool matchesAP = filters.selectedAPCode == null ||
          filters.selectedAPCode == 'List POs for all suppliers' ||
          filters.selectedAPCode == 'Supplier' ||
          record.apCode == filters.selectedAPCode;

      bool matchesDate = filters.selectedDate == 'List POs for all dates' ||
          filters.selectedDate == 'Date' ||
          record.date == filters.selectedDate ||
          (filters.selectedCustomDate != null &&
              record.date == _formatDate(filters.selectedCustomDate!));

      return matchesAP && matchesDate;
    }).toList();

   
    return filtered;
  }

  List<String> get uniqueDates {
    final Set<String> dates = {"List POs for all dates", "Specific Date"};
    for (var record in records) {
      if (record.date.isNotEmpty) {
        dates.add(record.date);
      }
    }
    return dates.toList();
  }

  List<String> get uniqueAPCodes {
    final Set<String> apCodes = {'List POs for all suppliers'};
    for (var record in records) {
      if (record.apCode.isNotEmpty) {
        apCodes.add(record.apCode);
      }
    }
    return apCodes.toList();
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
