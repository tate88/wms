import 'package:flutter/material.dart';
import '../models/grn_list_models.dart';
import '../constants/grn_constants.dart';
import '../outstanding_stock_page.dart';

class GRNFilterSection extends StatelessWidget {
  final GRNFilters filters;
  final List<String> uniqueAPCodes;
  final List<String> uniqueDates;
  final String dropdownSearchQuery;
  final TextEditingController poNumberController;
  final TextEditingController invoiceNumberController;
  final TextEditingController dropdownSearchController;
  final Function(String?) onAPCodeChanged;
  final Function(String) onDateChanged;
  final Function(String) onSearchQueryChanged;
  final VoidCallback onSelectCustomDate;

  const GRNFilterSection({
    Key? key,
    required this.filters,
    required this.uniqueAPCodes,
    required this.uniqueDates,
    required this.dropdownSearchQuery,
    required this.poNumberController,
    required this.invoiceNumberController,
    required this.dropdownSearchController,
    required this.onAPCodeChanged,
    required this.onDateChanged,
    required this.onSearchQueryChanged,
    required this.onSelectCustomDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
          decoration: BoxDecoration(
            color: GRNConstants.primaryBlue,
          ),
          child: Column(
            children: [
              _buildFirstRow(),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildSecondRow(context),
        ),
      ],
    );
  }

  Widget _buildFirstRow() {
    return Column(
      children: [
        _buildStyledField(
          controller: poNumberController,
          label: "DO No",
          hint: "Enter DO number",
        ),
        const SizedBox(height: 16),
        _buildStyledField(
          controller: invoiceNumberController,
          label: "Invoice No",
          hint: "Enter invoice number",
        ),
      ],
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.white, // 👈 focus 后
        ),
        filled: false,
        fillColor: Colors.grey[400],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildSecondRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAPCodeDropdown(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateDropdown(),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        hintText: hintText,
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: GRNConstants.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: GRNConstants.orange,
                size: GRNConstants.iconSize,
              )
            : null,
        prefixIconConstraints: icon != null
            ? const BoxConstraints(minWidth: 40, minHeight: 20)
            : null,
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAPCodeDropdown(BuildContext context) {
  // Create structured supplier options list
  final structuredOptions = GRNConstants.apOptions;

  // Special marker for "all suppliers" option
  const String allSuppliersMarker = '__ALL_SUPPLIERS__';

  // Build popup menu items
  final List<PopupMenuEntry<String>> menuItems = [];


  menuItems.add(
    PopupMenuItem<String>(
      value: allSuppliersMarker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.list_alt,
              color: GRNConstants.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'List POs for all suppliers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: filters.selectedAPCode == null
                      ? GRNConstants.primaryBlue
                      : Colors.black87,
                ),
              ),
            ),
            if (filters.selectedAPCode == null)
              const Icon(
                Icons.check,
                color: GRNConstants.primaryBlue,
                size: 18,
              ),
          ],
        ),
      ),
    ),
  );


  // Add supplier options
  for (int i = 0; i < structuredOptions.length; i++) {
    final supplier = structuredOptions[i];
    final apCode = supplier['apCode']!;
    final apName = supplier['apName']!;
    final isSelected = apCode == filters.selectedAPCode;

    menuItems.add(
      PopupMenuItem<String>(
        value: apCode,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
            
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      apCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? GRNConstants.primaryBlue
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      apName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: GRNConstants.primaryBlue,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  return PopupMenuButton<String>(
    onSelected: (String value) {
      final selectedValue = value == allSuppliersMarker ? null : value;
      onAPCodeChanged(selectedValue);
    },
    itemBuilder: (BuildContext context) => menuItems,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    offset: const Offset(0, 8),
    color: Colors.white,
    elevation: 8,
    child: Container(
      height: GRNConstants.containerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(GRNConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.business,
            color: GRNConstants.orange,
            size: GRNConstants.iconSize,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filters.selectedAPCode ?? 'Supplier',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: GRNConstants.orange,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildDateDropdown() {
    return Container(
      height: GRNConstants.containerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(GRNConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              color: GRNConstants.orange,
              size: GRNConstants.iconSize,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                filters.selectedDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: GRNConstants.orange,
            ),
          ],
        ),
        itemBuilder: (context) => [
          ...uniqueDates.map((date) => PopupMenuItem<String>(
                value: date,
                child: Text(date),
              )),
        ],
        onSelected: (value) {
          if (value == 'Specific Date') {
            onSelectCustomDate();
          } else if (value != null) {
            onDateChanged(value);
          }
        },
      ),
    );
  }
}


class GRNDataTable extends StatelessWidget {
  final List<GRNRecordModel> records;
  final bool isLoading;
  final VoidCallback onRefresh;

  const GRNDataTable({
    Key? key,
    required this.records,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              color: GRNConstants.accentBlue,
              child:
                  records.isEmpty ? _buildEmptyState() : _buildTableContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              'PO No',
              textAlign: TextAlign.left,
              style: GRNConstants.tableHeaderStyle,
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              'Date',
              textAlign: TextAlign.left,
              style: GRNConstants.tableHeaderStyle,
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              'Ref No',
              textAlign: TextAlign.left,
              style: GRNConstants.tableHeaderStyle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Supplier',
              textAlign: TextAlign.left,
              style: GRNConstants.tableHeaderStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        Container(
          height: 300,
          margin: const EdgeInsets.all(40),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 24),
                Text(
                  'No GRN records found',
                  style: GRNConstants.emptyStateHeaderStyle,
                ),
                SizedBox(height: 12),
                Text(
                  'Pull down to refresh',
                  style: GRNConstants.emptyStateSubStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableContent() {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return GRNTableRow(
          record: record,
          index: index,
        );
      },
    );
  }
}

class GRNTableRow extends StatelessWidget {
  final GRNRecordModel record;
  final int index;

  const GRNTableRow({
    Key? key,
    required this.record,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutstandingStockPage(
              poNumber: record.orderId,
              supplier: record.apCode,
              date: record.date,
              refNo: record.refNo,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : Colors.grey[50],
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                record.orderId,
                style: GRNConstants.tableRowTextStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                record.date,
                style: GRNConstants.tableRowTextStyle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                record.refNo,
                style: GRNConstants.tableRowTextStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                record.apName,
                textAlign: TextAlign.left,
                style: GRNConstants.tableRowTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
