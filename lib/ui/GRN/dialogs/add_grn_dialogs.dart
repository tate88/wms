import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../models/grn_models.dart';
import '../constants/grn_constants.dart';

class QuantityInputDialog extends StatefulWidget {
  final String stkcode;
  final String stkname1;
  final bool isLotItem;
  final Function(String barcode, String quantity, String lotNo, String batchNo,
      String expDate, String mfgDate, int seqNo) onAddItem;

  const QuantityInputDialog({
    super.key,
    required this.stkcode,
    required this.stkname1,
    required this.onAddItem,
    required this.isLotItem,
  });

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  late final TextEditingController _quantityController;
  final TextEditingController _lotNoController = TextEditingController();
  final TextEditingController _batchNoController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _mfgDateController = TextEditingController();
  final TextEditingController _seqNoController = TextEditingController();
  final TextEditingController _packSizeController = TextEditingController();
  final TextEditingController _putawayWarehouseController =
      TextEditingController();
  int _step = 0; // 0=Qty screen, 1=Lot/Batch screen (only for lot item)

  // UOM related variables
  String _selectedUOM = 'PCS'; // Default to primary UOM
  final List<Map<String, dynamic>> _availableUOMs = [
    {'code': 'PCS', 'name': 'Pieces', 'isPrimary': true, 'ratio': 1},
    {
      'code': 'BOX',
      'name': 'Box',
      'isPrimary': false,
      'ratio': 20
    }, // 1 BOX = 20 PCS
    {
      'code': 'CTN',
      'name': 'Carton',
      'isPrimary': false,
      'ratio': 100
    }, // 1 CTN = 100 PCS
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');

    // Add listener to update primary UOM display when quantity changes
    _quantityController.addListener(() {
      if (_getSelectedUOMData()['isPrimary'] == false) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _lotNoController.dispose();
    _batchNoController.dispose();
    _expDateController.dispose();
    _mfgDateController.dispose();
    _seqNoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: GRNConstants
                  .primaryBlue, // <-- Change this to your highlight color
              onPrimary: Colors.white, // Text color on the header
              onSurface: Colors.black, // Default text color
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GRNConstants.dialogBorderRadius),
      ),
      child: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GRNConstants.primaryBlue, GRNConstants.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GRNConstants.dialogBorderRadius),
          topRight: Radius.circular(GRNConstants.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
        
        if (_step == 1)
          IconButton(
            onPressed: () {
              setState(() {
                _step = 0; 
              });
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _step == 0 ? 'Item Quantity' : 'Item Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GRNConstants.formLabelStyle,
    );
  }

  Widget _buildContent() {
    final bool isLotItem = widget.isLotItem;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Stock information card (unchanged)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GRNConstants.primaryBlue.withValues(alpha: 0.08),
                  GRNConstants.lightBlue.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GRNConstants.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GRNConstants.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: GRNConstants.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stkcode,
                        style: GRNConstants.stockCodeStyle
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.stkname1,
                          style: GRNConstants.sectionTitleStyle,
                          
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // STEP 0: Qty/UOM/StockQty
          // =========================
          if (!isLotItem || _step == 0) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Quantity'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('UOM'),
                      const SizedBox(height: 4),
                      _buildUOMDropdown(),
                    ],
                  ),
                ),
              ],
            ),

            // Show primary UOM equivalent if storage UOM is selected
            if (_getSelectedUOMData()['isPrimary'] == false) ...[
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 12),
            _label('Stock Quantity'),
            const SizedBox(height: 4),
            _buildStockQtyBox(),
          ],

          // =========================
          // STEP 1: Lot/Batch/Mfg/Exp (only lot item)
          // =========================
          if (isLotItem && _step == 1) ...[
            _label('Lot No'),
            const SizedBox(height: 8),
            TextField(
              controller: _lotNoController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _label('Batch No'),
            const SizedBox(height: 8),
            TextField(
              controller: _batchNoController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            _label('Manufacturing Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, _mfgDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _mfgDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label('Expiry Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, _expDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _expDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label('Pack Size'),
            const SizedBox(height: 8),
            TextField(
              controller: _packSizeController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _label('Putaway Warehouse'),
            const SizedBox(height: 8),
            TextField(
              controller: _putawayWarehouseController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildStockQtyBox() {
    final selectedUOM = _getSelectedUOMData();
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    String displayQuantity;
    String displayUOM;

    if (selectedUOM['isPrimary'] == false) {
      final primaryEquivalent = quantity * selectedUOM['ratio'];
      displayQuantity = primaryEquivalent.toString();
      displayUOM = 'PCS';
    } else {
      displayQuantity = '1';
      displayUOM = 'PCS';
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              displayQuantity,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              displayUOM,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isLotItem = widget.isLotItem;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
         
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (isLotItem && _step == 0) {
                  final qty =
                      int.tryParse(_quantityController.text.trim()) ?? 0;
                  if (qty <= 0) return;
                  setState(() => _step = 1);
                  return;
                }
                _handleAddItem();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GRNConstants.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (isLotItem && _step == 0)
                        ? Icons.arrow_forward
                        : Icons.add_circle,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (isLotItem && _step == 0) ? 'Next' : 'Add Item',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddItem() {
    if (widget.isLotItem) {
      if (_lotNoController.text.trim().isEmpty) return;
    }

    widget.onAddItem(
      widget.stkcode,
      _quantityController.text,
      _lotNoController.text,
      _batchNoController.text,
      _expDateController.text,
      _mfgDateController.text,
      int.tryParse(_seqNoController.text) ?? 0,
    );

    Navigator.of(context).pop();
  }

  // New methods for UOM functionality:
  Widget _buildUOMDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUOM,
          isExpanded: true,
          items: _availableUOMs.map((uom) {
            return DropdownMenuItem<String>(
              value: uom['code'],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${uom['code']} - ${uom['name']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedUOM = newValue;
              });
            }
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: const TextStyle(color: Colors.black87),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Map<String, dynamic> _getSelectedUOMData() {
    return _availableUOMs.firstWhere(
      (uom) => uom['code'] == _selectedUOM,
      orElse: () => _availableUOMs.first,
    );
  }
}

class EditQuantityDialog extends StatefulWidget {
  final GRNItem item;
  final Function(int, int) onUpdateQuantity;

  const EditQuantityDialog({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
  });

  @override
  State<EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<EditQuantityDialog> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.item.qty.toString());
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GRNConstants.dialogBorderRadius),
      ),
      child: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GRNConstants.primaryBlue, GRNConstants.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GRNConstants.dialogBorderRadius),
          topRight: Radius.circular(GRNConstants.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Quantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Update the quantity for this item',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Seq: ${widget.item.seq}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock Code: ${widget.item.barcode}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: GRNConstants.accentBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'New Quantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _editController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter new quantity',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF4A6FA5),
                    size: 16,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: GRNConstants.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Update',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpdate() {
    final newQty = int.tryParse(_editController.text) ?? 0;
    if (newQty > 0) {
      widget.onUpdateQuantity(widget.item.seq, newQty);
      Navigator.of(context).pop();
    }
  }
}

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Error'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class SaveConfirmationDialog extends StatelessWidget {
  final int itemCount;
  final int totalQuantity;
  final VoidCallback onConfirm;

  const SaveConfirmationDialog({
    super.key,
    required this.itemCount,
    required this.totalQuantity,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Save'),
      content: Text(
        'Save GRN with $itemCount items?\n\nTotal Quantity: $totalQuantity',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
