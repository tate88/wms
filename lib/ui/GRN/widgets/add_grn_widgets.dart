import 'package:flutter/material.dart';
import '../models/grn_models.dart';
import '../constants/grn_constants.dart';
import '../constants/outstanding_stock_constants.dart';
import 'package:intl/intl.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GRNConstants.sectionTitleStyle,
      ),
    );
  }
}

class APDropdown extends StatelessWidget {
  final String? selectedAP;
  final String apSearchQuery;
  final TextEditingController apSearchController;
  final Function(String) onAPSelected;
  final Function(String) onSearchChanged;

  const APDropdown({
    Key? key,
    required this.selectedAP,
    required this.apSearchQuery,
    required this.apSearchController,
    required this.onAPSelected,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: PopupMenuButton<String>(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.business,
                  color: GRNConstants.accentBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedAP ?? 'Select Supplier',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        selectedAP != null ? Colors.black87 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: GRNConstants.accentBlue,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setMenuState) {
                final filtered = GRNConstants.apOptions
                    .where((ap) =>
                        apSearchQuery.isEmpty ||
                        ap.toLowerCase().contains(apSearchQuery.toLowerCase()))
                    .toList();

                return Container(
                  width: 350,
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(GRNConstants.defaultBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchField(setMenuState),
                        const SizedBox(height: 8),
                        if (apSearchQuery.isNotEmpty)
                          _buildResultsCount(filtered),
                        const SizedBox(height: 8),
                        _buildFilteredList(context, filtered),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        onSelected: (String? value) {
          if (value != null) {
            onAPSelected(value);
          }
        },
      ),
    );
  }

  Widget _buildSearchField(StateSetter setMenuState) {
    return TextField(
      controller: apSearchController,
      autofocus: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: GRNConstants.accentBlue),
        suffixIcon: apSearchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: GRNConstants.accentBlue),
                onPressed: () {
                  apSearchController.clear();
                  setMenuState(() {
                    onSearchChanged('');
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
          borderSide:
              const BorderSide(color: GRNConstants.accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        setMenuState(() {
          onSearchChanged(value);
        });
      },
    );
  }

  Widget _buildResultsCount(List<String> filtered) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Found ${filtered.length} results',
        style: const TextStyle(
          color: GRNConstants.accentBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilteredList(BuildContext context, List<String> filtered) {
    return Expanded(
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.blue[100]),
        itemBuilder: (context, index) {
          final value = filtered[index];
          return InkWell(
            onTap: () => Navigator.pop(context, value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (value == selectedAP) ...[
                    const Icon(
                      Icons.check_circle,
                      color: GRNConstants.accentBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: value == selectedAP
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: value == selectedAP
                            ? GRNConstants.accentBlue
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  final TextEditingController dateController;
  final VoidCallback onTap;

  const DatePickerField({
    Key? key,
    required this.dateController,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: GRNConstants.accentBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: dateController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select Date',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: GRNConstants.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodeSection extends StatefulWidget {
  final TextEditingController barcodeController;
  final VoidCallback onScanBarcode;
  final Function(Map<String, dynamic>) onStockSelected;
  final List<Map<String, dynamic>> stockData =
      OutstandingStockConstants.sampleApiData;

  BarcodeSection({
    super.key,
    required this.barcodeController,
    required this.onScanBarcode,
    required this.onStockSelected,
  });

  @override
  State<BarcodeSection> createState() => _BarcodeSectionState();
}

class _BarcodeSectionState extends State<BarcodeSection> {
  List<Map<String, dynamic>> _filteredStocks = [];
  bool _showDropdown = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.barcodeController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.barcodeController.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.barcodeController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _filteredStocks = widget.stockData
            .where((stock) => stock['StkCode']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .take(10) // Limit to 10 results
            .toList();
        _showDropdown = _filteredStocks.isNotEmpty;
      });

      if (_showDropdown) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      setState(() {
        _filteredStocks.clear();
        _showDropdown = false;
      });
      _removeOverlay();
    }
  }

void _showOverlay() {
  _removeOverlay();

  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      width: MediaQuery.of(context).size.width - 32, // Account for padding
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 60), // Position below the text field
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 350), // Limit height for 5 items
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredStocks.length, // Show all items, but limit height
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final stock = _filteredStocks[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    stock['StkCode'], // Display stock code
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    stock['StkNameS'], // Display stock name
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
               
                  onTap: () {
                    widget.barcodeController.text = stock['StkCode'];
                    widget.onStockSelected(stock); // Pass the entire stock item
                    _removeOverlay();
                    setState(() {
                      _showDropdown = false;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
}
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GRNConstants.defaultBorderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            TextField(
              controller: widget.barcodeController,
              decoration: InputDecoration(
                hintText: 'Scan or type stock code',
                prefixIcon: const Icon(
                  Icons.qr_code_scanner,
                  color: GRNConstants.accentBlue,
                ),
                suffixIcon: widget.barcodeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: GRNConstants.accentBlue),
                        onPressed: () {
                          widget.barcodeController.clear();
                          _removeOverlay();
                          setState(() {
                            _showDropdown = false;
                            _filteredStocks.clear();
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onScanBarcode();
                  _removeOverlay();
                  setState(() {
                    _showDropdown = false;
                  });
                }
              },
              onTap: () {
                if (_filteredStocks.isNotEmpty) {
                  _showOverlay();
                }
              },
            ),
            if (_showDropdown && _filteredStocks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Found ${_filteredStocks.length} matching stock codes',
                    style: const TextStyle(
                      color: GRNConstants.accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScannedItemsList extends StatelessWidget {
  final List<GRNItem> scannedItems;
  final Function(int) onDeleteItem;
  final Function(int) onEditQuantity;

  const ScannedItemsList({
    Key? key,
    required this.scannedItems,
    required this.onDeleteItem,
    required this.onEditQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GRNConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Expanded(
      child:
          scannedItems.isEmpty ? _buildEmptyState() : _buildItemsList(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items scanned yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or add items to get started',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scannedItems.length,
      itemBuilder: (context, index) {
        final item = scannedItems[index];
        return Dismissible(
          key: Key(item.barcode),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (direction) => onDeleteItem(index),
          child: ItemCard(
            item: item,
            onEditQuantity: () => onEditQuantity(index),
          ),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final GRNItem item;
  final VoidCallback onEditQuantity;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onEditQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedMfgDate =
        DateFormat('dd/MM/yyyy').format(item.mfgDate);
    final String formattedExpDate =
        DateFormat('dd/MM/yyyy').format(item.expDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Line No',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Short Name',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Values Row
          Row(
            children: [
              // Line Number Value
              Expanded(
                flex: 1,
                child: Text(
                  '#${item.lineNo}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Stock Code Value
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    item.shortName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Quantity Badge
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C42),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.qty} UNIT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailField(
                'Lot No:',
                item.lotNo.isEmpty ? '' : item.lotNo,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Batch No:',
                item.batchNo.isEmpty ? '' : item.batchNo,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Seq No:',
                item.seq.toString(),
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Manufacturing Date:',
                formattedMfgDate,
              ),
              const SizedBox(height: 12),
              _buildDetailField(
                'Expiry Date:',
                formattedExpDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final bool canPrintBarcode;
  final bool hasItems;
  final VoidCallback onPrintLabel;
  final VoidCallback onFinalSave;

  const ActionButtons({
    Key? key,
    required this.canPrintBarcode,
    required this.hasItems,
    required this.onPrintLabel,
    required this.onFinalSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: hasItems ? onFinalSave : null,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(GRNConstants.defaultBorderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NextButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const NextButton({
    Key? key,
    required this.isEnabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: GRNConstants.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(GRNConstants.defaultBorderRadius),
          ),
        ),
        label: const Text(
          'Next',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
