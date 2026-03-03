import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../GRN/barcode_scanner.dart';
import 'models/location_transfer_models.dart';
import 'services/location_transfer_service.dart';
import 'widgets/location_transfer_widgets.dart';
import 'dialogs/location_transfer_dialogs.dart';
import '../../../constants/wms_constant.dart';

class LocationTransferPage extends StatefulWidget {
  const LocationTransferPage({super.key});

  @override
  State<LocationTransferPage> createState() => _LocationTransferPageState();
}

class _LocationTransferPageState extends State<LocationTransferPage> {
  // Controllers
  final TextEditingController _forkliftController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _forkliftFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _stockFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();

  late LocationTransferData _transferData;
  String _carrierLabel = 'Carrier';

  @override
  void initState() {
    super.initState();
    _transferData = LocationTransferData();

    // Add focus listeners to auto-update steps
    _forkliftFocus.addListener(_onForkliftFocusChanged);
    _locationFocus.addListener(_onLocationFocusChanged);
    _stockFocus.addListener(_onStockFocusChanged);
    _quantityFocus.addListener(_onQuantityFocusChanged);

    // Add listener for manual text input
    _forkliftController.addListener(_onForkliftTextChanged);

    // Auto-focus the first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
    });
  }

  // Add this method to determine carrier type based on code
  String _getCarrierType(String code) {
    if (code.isEmpty) return 'Carrier';

    if (code.toLowerCase().startsWith('f') ||
        code.toLowerCase().contains('fork') ||
        code.toLowerCase().contains('fl')) {
      return 'Forklift';
    } else if (code.toLowerCase().startsWith('t') ||
        code.toLowerCase().contains('troll') ||
        code.toLowerCase().contains('tr')) {
      return 'Trolley';
    }
    return 'Carrier'; // Default fallback
  }

  void _onForkliftTextChanged() {
    setState(() {
      _carrierLabel = _getCarrierType(_forkliftController.text);
    });
  }

  @override
  void dispose() {
    // Remove focus listeners
    _forkliftFocus.removeListener(_onForkliftFocusChanged);
    _locationFocus.removeListener(_onLocationFocusChanged);
    _stockFocus.removeListener(_onStockFocusChanged);
    _quantityFocus.removeListener(_onQuantityFocusChanged);

    _forkliftController.dispose();
    _locationController.dispose();
    _stockController.dispose();
    _quantityController.dispose();
    _forkliftFocus.dispose();
    _locationFocus.dispose();
    _stockFocus.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _transferData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
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
      title: const Text('Load Transfer', style: GRNConstants.headerStyle),
      actions: [
        if (_transferData.currentStep > 0)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetTransfer,
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Progress Steps
        ProgressStepsWidget(
          currentStep: _transferData.currentStep,
          forkliftCode: _transferData.forkliftCode,
          stockItems: _transferData.stockItems,
          sourceLocationCode: _transferData.sourceLocationCode,
          step0Label: _carrierLabel,
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scan Input Fields
                _buildScanInputs(),

                const SizedBox(height: 24),

                // Error Message
                if (_transferData.errorMessage != null) _buildErrorCard(),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanInputs() {
    return Column(
      children: [
        // Forklift Input
        ScanInputWidget(
          controller: _forkliftController,
          focusNode: _forkliftFocus,
          label:
              _carrierLabel, // Use dynamic label instead of 'Forklift/Trolley Code'
          icon: Icons.forklift,
          isActive: true,
          isCompleted: false,
          value: _transferData.forkliftCode,
          onScan: _onForkliftScanned,
          onBarcodePressed: () => _openBarcodeScanner('forklift'),
        ),

        const SizedBox(height: 16),

        // Combined Stock Code and Quantity Input
        _buildCombinedStockInput(),

        const SizedBox(height: 16),

        // Stock Items List
        if (_transferData.stockItems.isNotEmpty) _buildStockItemsList(),

        const SizedBox(height: 16),

        // Source Location Input
        ScanInputWidget(
          controller: _locationController,
          focusNode: _locationFocus,
          label: 'Source Location',
          icon: Icons.source,
          isActive: true,
          isCompleted: false,
          value: _transferData.sourceLocationCode,
          onScan: _onLocationScanned,
          onBarcodePressed: () => _openBarcodeScanner('location'),
        ),
      ],
    );
  }

  Widget _buildCombinedStockInput() {
    // Check if either stock or quantity field is focused
    final bool isStockFocused = _stockFocus.hasFocus;
    final bool isQuantityFocused = _quantityFocus.hasFocus;
    final bool isAnyFieldFocused = isStockFocused || isQuantityFocused;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAnyFieldFocused
            ? GRNConstants.primaryBlue.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isAnyFieldFocused ? GRNConstants.primaryBlue : Colors.grey[300]!,
          width: isAnyFieldFocused ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAnyFieldFocused
                      ? GRNConstants.primaryBlue
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isAnyFieldFocused
                      ? GRNConstants.primaryBlue
                      : Colors.grey[600],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _openBarcodeScanner('stock'),
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: isAnyFieldFocused
                      ? GRNConstants.primaryBlue
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stock Code Input
          TextFormField(
            controller: _stockController,
            focusNode: _stockFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Scan, type, or select item',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              floatingLabelStyle: const TextStyle(
                color: GRNConstants.primaryBlue,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GRNConstants.primaryBlue),
              ),
            ),
            onFieldSubmitted: (value) {
              _quantityFocus.requestFocus();
            },
          ),
          const SizedBox(height: 12),
          // Quantity Input
          TextFormField(
            controller: _quantityController,
            focusNode: _quantityFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Enter quantity to transfer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              floatingLabelStyle: const TextStyle(
                color: GRNConstants.primaryBlue,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GRNConstants.primaryBlue),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(
                    right: 4.0), // Padding at the right edge
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_return),
                      color: GRNConstants.primaryBlue,
                      onPressed: () {
                        _addStockItem();
                      },
                    ),
                  ],
                ),
              ),
            ),
            onFieldSubmitted: (value) {
              _addStockItem();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStockItemsList() {
    return GestureDetector(
      onTap: () {
        if (_transferData.stockItems.isEmpty) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blue rounded top with title and close button
                  Container(
                    decoration: const BoxDecoration(
                      color: GRNConstants.primaryBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Item Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Item list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _transferData.stockItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _transferData.stockItems[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.stockCode,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    if (item.itemName != null &&
                                        item.itemName!.isNotEmpty)
                                      Row(
                                        children: [
                                          Text(
                                            'Stock Name: ', // Label
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight
                                                  .bold, // Bold for the label
                                            ),
                                          ),
                                          Text(
                                            item.itemName!, // Value
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight
                                                  .normal, // Normal weight for the value
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 4),
                                    // Show lot number if it's a lot item
                                    if ((item.lotNo != null &&
                                            item.lotNo!.isNotEmpty) ||
                                        (item.lotBatch != null &&
                                            item.lotBatch!.isNotEmpty) ||
                                        (item.lotSeq != null &&
                                            item.lotSeq!.isNotEmpty))
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.lotNo != null &&
                                              item.lotNo!.isNotEmpty)
                                             
                                            Row(
                                              children: [
                                                Text(
                                                  'Lot No: ', // Label
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .bold, // Bold for the label
                                                  ),
                                                ),
                                                Text(
                                                  item.lotNo!, // Value
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .normal, // Normal weight for the value
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (item.lotBatch != null &&
                                              item.lotBatch!.isNotEmpty)
                                                   const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Lot Batch: ', // Label
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .bold, // Bold for the label
                                                  ),
                                                ),
                                                Text(
                                                  item.lotBatch!, // Value
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .normal, // Normal weight for the value
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (item.lotSeq != null &&
                                              item.lotSeq!.isNotEmpty)
                                                   const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Lot Seq: ', // Label
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .bold, // Bold for the label
                                                  ),
                                                ),
                                                Text(
                                                  item.lotSeq!, // Value
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight
                                                        .normal, // Normal weight for the value
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),

                                    const SizedBox(height:4 ),
                                    Row(
                                      children: [
                                        Text(
                                          'Quantity: ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                              '${item.quantity.toStringAsFixed(0)} PCS',
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: GRNConstants.red),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _removeStockItem(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the label here
            Text(
              'Total Items Scan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.list_alt, color: GRNConstants.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '${_transferData.stockItems.length} item(s) | Total Quantity: ${_transferData.stockItems.fold(0.0, (sum, item) => sum + item.quantity)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GRNConstants.primaryBlue,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _transferData.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Submit Button
        Expanded(
          child: ElevatedButton(
            onPressed: _transferData.canSubmit ? _submitTransfer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: GRNConstants.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(GRNConstants.defaultBorderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _transferData.canSubmit ? Icons.send : Icons.arrow_forward,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _transferData.canSubmit ? 'Confirm Transfer' : 'Continue',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Focus change handlers
  void _onForkliftFocusChanged() {
    if (!_forkliftFocus.hasFocus &&
        _forkliftController.text.trim().isNotEmpty) {
      _onForkliftScanned(_forkliftController.text);
    }
  }

  void _onLocationFocusChanged() {
    if (!_locationFocus.hasFocus &&
        _locationController.text.trim().isNotEmpty) {
      _onLocationScanned(_locationController.text);
    }
  }

  void _onStockFocusChanged() {
    setState(() {}); // Always rebuild when focus changes
    if (!_stockFocus.hasFocus && _stockController.text.trim().isNotEmpty) {
      _onStockScanned(_stockController.text);
    }
  }

  void _onQuantityFocusChanged() {
    setState(() {}); // Always rebuild when focus changes
    if (!_quantityFocus.hasFocus &&
        _quantityController.text.trim().isNotEmpty) {
      final quantity = double.tryParse(_quantityController.text.trim());
      if (quantity != null) {
        setState(() {
          _transferData = _transferData.copyWith(
            clearErrorMessage: true,
          );
        });
      }
    }
  }

  void _onForkliftScanned(String code) {
    if (code.trim().isEmpty) return;

    // Update the label based on the scanned code
    setState(() {
      _carrierLabel = _getCarrierType(code.trim());
      _transferData = _transferData.copyWith(
        forkliftCode: code.trim(),
        currentStep: 1,
        clearErrorMessage: true,
      );
    });

    _forkliftController.text = code.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockFocus.requestFocus();
    });
  }

  void _onLocationScanned(String code) {
    if (code.trim().isEmpty) return;

    setState(() {
      _transferData = _transferData.copyWith(
        sourceLocationCode: code.trim(),
        clearErrorMessage: true,
      );
    });

    _locationController.text = code.trim();
  }

  void _onStockScanned(String code) {
    if (code.trim().isEmpty) return;

    _stockController.text = code.trim();

    // Set default quantity to 1
    if (_quantityController.text.trim().isEmpty) {
      _quantityController.text = '1';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quantityFocus.requestFocus();
      // Select all text so user can easily replace the default value
      _quantityController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _quantityController.text.length,
      );
    });
  }

  void _addStockItem() {
    final stockCode = _stockController.text.trim();
    final quantityText = _quantityController.text.trim();

    if (stockCode.isEmpty || quantityText.isEmpty) {
      setState(() {
        _transferData = _transferData.copyWith(
          errorMessage: 'Please enter both stock code and quantity',
        );
      });

      return;
    }

    final quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      setState(() {
        _transferData = _transferData.copyWith(
          errorMessage: 'Please enter a valid quantity',
        );
      });
      return;
    }

    // Check if stock code already exists
    if (_transferData.stockItems.any((item) => item.stockCode == stockCode)) {
      setState(() {
        _transferData = _transferData.copyWith(
          errorMessage: 'Stock code already added',
        );
      });
      return;
    }

    final newItem = StockItem(
      stockCode: stockCode,
      quantity: quantity,
      lotNo: 'LOT2024001',
      lotBatch: 'BATCH01',
      lotSeq: 'SEQ001',
      itemName: 'Sample Item Name',
    );
    setState(() {
      _transferData = _transferData.copyWith(
        stockItems: [..._transferData.stockItems, newItem],
        currentStep:
            _transferData.stockItems.isEmpty ? 2 : _transferData.currentStep,
        clearErrorMessage: true,
      );
    });

    // Auto-focus source location if this is the first stock item
    if (_transferData.stockItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _locationFocus.requestFocus();
      });
    }

    // Clear inputs and focus back to stock for next item
    _stockController.clear();
    _quantityController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockFocus.requestFocus();
    });
  }

  void _removeStockItem(int index) {
    setState(() {
      final newStockItems = List<StockItem>.from(_transferData.stockItems);
      newStockItems.removeAt(index);

      _transferData = _transferData.copyWith(
        stockItems: newStockItems,
        currentStep: newStockItems.isEmpty ? 1 : _transferData.currentStep,
        clearErrorMessage: true,
      );
    });
  }

  Future<void> _openBarcodeScanner(String type) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      switch (type) {
        case 'forklift':
          _onForkliftScanned(result);
          break;
        case 'location':
          _onLocationScanned(result);
          break;
        case 'stock':
          _onStockScanned(result);
          break;
      }
    }
  }

  Future<void> _submitTransfer() async {
    if (!_transferData.canSubmit) return;

    setState(() {
      _transferData = _transferData.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      );
    });

    final request = LocationTransferRequest(
      forkliftCode: _transferData.forkliftCode!,
      stockItems: _transferData.stockItems,
      sourceLocationCode: _transferData.sourceLocationCode,
    );

    try {
      // Use mock service for testing, replace with real service
      final response =
          await LocationTransferService.submitTransferMock(request);

      setState(() {
        _transferData = _transferData.copyWith(
          isLoading: false,
          lastResponse: response,
        );
      });

      if (response.success) {
        _showSuccessDialog(response);
      } else {
        setState(() {
          _transferData = _transferData.copyWith(
            errorMessage: response.message,
          );
        });
      }
    } catch (e) {
      setState(() {
        _transferData = _transferData.copyWith(
          isLoading: false,
          errorMessage: 'Failed to submit transfer: $e',
        );
      });
    }
  }

  void _showSuccessDialog(LocationTransferResponse response) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        response: response,
        transferData: _transferData,
        onNewTransfer: _resetTransfer,
      ),
    );
  }

  void _resetTransfer() {
    setState(() {
      _transferData = LocationTransferData();
      _carrierLabel = 'Carrier'; // Reset label to default
    });

    _forkliftController.clear();
    _locationController.clear();
    _stockController.clear();
    _quantityController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
    });
  }
}
