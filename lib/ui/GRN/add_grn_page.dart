import 'package:WMS/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'models/grn_models.dart';
import 'constants/grn_constants.dart';

import 'widgets/add_grn_widgets.dart';
import 'dialogs/add_grn_dialogs.dart';

class AddGRNPage extends StatefulWidget {
  final TextEditingController poNumberController;
  final TextEditingController invoiceNumberController;

  const AddGRNPage({
    super.key,
    required this.poNumberController,
    required this.invoiceNumberController,
  });

  @override
  State<AddGRNPage> createState() => _AddGRNPageState();
}

class _AddGRNPageState extends State<AddGRNPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _apSearchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // State
  late GRNData _grnData;
  String _apSearchQuery = '';
  bool _showAddItemSection = true; // Controls visibility of BarcodeSection
  bool _showFloatingButton = true; // Controls visibility of the floating button

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _grnData = GRNData(
      selectedDate: DateTime.now(),
      scannedItems: [],
      currentSeqNumber: 1,
      canPrintBarcode: false,
    );
    _dateController.text = _formatDate(_grnData.selectedDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barcodeController.dispose();
    _apSearchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSetupTab(),
              _buildScanItemsTab(),
            ],
          ),
          if (_tabController.index == 1 && _showFloatingButton)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showAddItemSection = true;
                  });
                },
                backgroundColor: GRNConstants.primaryBlue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: GRNConstants.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text('Receiving', style: GRNConstants.headerStyle),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: GRNConstants.orange,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Header'),
          Tab(text: 'Details'),
        ],
        onTap: (index) {
          if (_tabController.index == 1 && index == 0) {
            return; // Prevent navigation back to Header
          }
          _tabController.animateTo(index);
        },
      ),
    );
  }

  Widget _buildSetupTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GRNConstants.primaryBlue.withOpacity(0.1),
                        GRNConstants.lightBlue.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GRNConstants.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        label: 'DO No',
                        value: widget.poNumberController.text,
                        icon: Icons.inventory_2,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        label: 'Invoice No',
                        value: widget.invoiceNumberController.text,
                        icon: Icons.description,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Supplier'),
                APDropdown(
                  selectedAP: _grnData.selectedAP,
                  apSearchQuery: _apSearchQuery,
                  apSearchController: _apSearchController,
                  onAPSelected: _onAPSelected,
                  onSearchChanged: _onSearchChanged,
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Receiving Date'),
                DatePickerField(
                  dateController: _dateController,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: NextButton(
            isEnabled: _grnData.selectedAP != null,
            onPressed: () => _tabController.animateTo(1),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GRNConstants.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GRNConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: GRNConstants.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: GRNConstants.primaryBlue.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanItemsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showAddItemSection) ...[
            BarcodeSection(
              barcodeController: _barcodeController,
              onScanBarcode: () => _scanBarcode(_barcodeController.text),
             onStockSelected: (Map<String, dynamic> stockData) {
              _barcodeController.text = stockData['StkCode'] ?? ''; 
            
              _scanBarcode(stockData['StkNameS']); 
              },
            ),
            const SizedBox(height: 24),
          ],
          // Always show the scanned items list
          ScannedItemsList(
            scannedItems: _grnData.scannedItems,
            onDeleteItem: _deleteItem,
            onEditQuantity: _editQuantity,
          ),
          const SizedBox(height: 24),
          ActionButtons(
            canPrintBarcode: _grnData.canPrintBarcode,
            hasItems: _grnData.scannedItems.isNotEmpty,
            onPrintLabel: _printBarcodeLabel,
            onFinalSave: _finalSave,
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _onAPSelected(String ap) {
    setState(() {
      _grnData = _grnData.copyWith(selectedAP: ap);
      _apSearchController.clear();
      _apSearchQuery = '';
    });
  }

  void _onSearchChanged(String query) {
    _apSearchQuery = query;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _grnData.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: GRNConstants.accentBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: GRNConstants.accentBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _grnData = _grnData.copyWith(selectedDate: picked);
        _dateController.text = DateFormat('dd/MM/yyyy')
            .format(picked);
      });
    }
  }

  void _scanBarcode(String stkname) {
    if (_barcodeController.text.isEmpty) {
      _showErrorDialog('Please enter a barcode.');
      return;
    }
    _showQuantityDialog(_barcodeController.text, stkname);
  }

  void _showQuantityDialog(String barcode, String stkname) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuantityInputDialog(
        stkcode: barcode,
        stkname1: stkname, 
        isLotItem: true, 
        onAddItem:
            (barcode, quantityText, lotNo, batchNo, mfgDate, expDate, seqNo) =>
                _addScannedItem(
                    barcode,
                    stkname,
                    quantityText,
                    lotNo,
                    batchNo,
                    DateTime.tryParse(mfgDate) ?? DateTime.now(),
                    DateTime.tryParse(expDate) ?? DateTime.now(),
                    seqNo),
      ),
    );
  }

  void _addScannedItem(String barcode, String stkname, String quantityText, String lotNo,
      String batchNo, DateTime mfgDate, DateTime expDate, int seqNo) {
    if (quantityText.isEmpty) {
      _showErrorDialog('Please enter a valid quantity.');
      return;
    }

    final int quantity = int.tryParse(quantityText) ?? 0;
    if (quantity <= 0) {
      _showErrorDialog('Quantity must be greater than 0.');
      return;
    }

    // Check if item with same stock code already exists
    int existingIndex =
        _grnData.scannedItems.indexWhere((item) => item.barcode == barcode);

    GRNItem newItem;

    if (existingIndex != -1) {
      // Item exists, create new item with same line number but incremented seq
      final existingItem = _grnData.scannedItems[existingIndex];

      // Find the highest seq number for this stock code
      int maxSeq = _grnData.scannedItems
          .where((item) => item.barcode == barcode)
          .map((item) => item.seq)
          .reduce((max, seq) => seq > max ? seq : max);

      newItem = GRNItem(
        seq: maxSeq + 1, // Increment sequence number
        barcode: barcode,
        shortName: existingItem.shortName, 
        qty: quantity,
        lotNo: lotNo,
        batchNo: batchNo,
        expDate: expDate,
        mfgDate: mfgDate,
        lineNo: existingItem.lineNo, // Keep same line number
      );
    } else {
      // New stock code, create with new line number
      // Calculate next line number based on unique barcodes
      Set<String> uniqueBarcodes =
          _grnData.scannedItems.map((item) => item.barcode).toSet();
      int nextLineNo = uniqueBarcodes.length + 1;

      newItem = GRNItem(
        seq: 1, // Start sequence from 1 for new stock code
        barcode: barcode,
        shortName: stkname,
        qty: quantity,
        lotNo: lotNo,
        batchNo: batchNo,
        expDate: expDate,
        mfgDate: mfgDate,
        lineNo: nextLineNo, 
      );
    }

    setState(() {
      final updatedItems = [..._grnData.scannedItems, newItem];
      _grnData = _grnData.copyWith(
        scannedItems: updatedItems,
        currentSeqNumber: _grnData.currentSeqNumber + 1,
        canPrintBarcode: true,
      );
      _barcodeController.clear();
      _showAddItemSection = false; // Hide the BarcodeSection after adding
      _showFloatingButton = true; // Ensure floating button is visible
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Added: $barcode (Qty: $quantity)\nLot No: $lotNo, Batch No: $batchNo'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteItem(int index) {
    final item = _grnData.scannedItems[index];
    setState(() {
      final updatedItems = [..._grnData.scannedItems];
      updatedItems.removeAt(index);
      _grnData = _grnData.copyWith(scannedItems: updatedItems);

      // Show the BarcodeSection again if no items are left
      if (updatedItems.isEmpty) {
        _showAddItemSection = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ${item.barcode} deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _editQuantity(int index) {
    final item = _grnData.scannedItems[index];
    showDialog(
      context: context,
      builder: (context) => EditQuantityDialog(
        item: item,
        onUpdateQuantity: _updateQuantity,
      ),
    );
  }

  void _updateQuantity(int seq, int newQty) {
    setState(() {
      final updatedItems = _grnData.scannedItems.map((item) {
        return item.seq == seq ? item.copyWith(qty: newQty) : item;
      }).toList();
      _grnData = _grnData.copyWith(scannedItems: updatedItems);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated quantity to $newQty'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _printBarcodeLabel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print Barcode Label pressed')),
    );
  }

  void _finalSave() {
    if (_grnData.scannedItems.isEmpty) {
      _showErrorDialog('No items to save. Please scan at least one item.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SaveConfirmationDialog(
        itemCount: _grnData.scannedItems.length,
        totalQuantity: _grnData.totalQuantity,
        onConfirm: () {
          Navigator.pop(context); // Close GRN page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GRN saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _addItem(String barcode, String quantity, String lotNo, String batchNo,
      String expDate, String mfgDate, int seqNo) {
    // Check if item with same stock code already exists
    int existingIndex =
        _grnData.scannedItems.indexWhere((item) => item.barcode == barcode);

    if (existingIndex != -1) {
      // Item exists, create new item with same line number but incremented seq
      final existingItem = _grnData.scannedItems[existingIndex];

      // Find the highest seq number for this stock code
      int maxSeq = _grnData.scannedItems
          .where((item) => item.barcode == barcode)
          .map((item) => item.seq)
          .reduce((max, seq) => seq > max ? seq : max);

      final newItem = GRNItem(
        seq: maxSeq + 1, // Increment sequence number
        barcode: barcode,
        shortName: 'stkshortname', // Placeholder short name
        qty: int.parse(quantity),
        lotNo: lotNo,
        batchNo: batchNo,
        expDate: DateTime.tryParse(expDate) ?? DateTime.now(),
        mfgDate: DateTime.tryParse(mfgDate) ?? DateTime.now(),
        lineNo: existingItem.lineNo, // Keep same line number
      );

      setState(() {
        _grnData.scannedItems.add(newItem);
      });
    } else {
      // New stock code, create with new line number
      final newItem = GRNItem(
        seq: 1, // Start sequence from 1 for new stock code
        barcode: barcode,
        shortName: 'stkshortname', // Placeholder short name
        qty: int.parse(quantity),
        lotNo: lotNo,
        batchNo: batchNo,
        expDate: DateTime.tryParse(expDate) ?? DateTime.now(),
        mfgDate: DateTime.tryParse(mfgDate) ?? DateTime.now(),
        lineNo: _grnData.scannedItems.length + 1, // New line number
      );

      setState(() {
        _grnData.scannedItems.add(newItem);
      });
    }

    _barcodeController.clear();
    setState(() {
      _showAddItemSection = false;
    });
  }
}
