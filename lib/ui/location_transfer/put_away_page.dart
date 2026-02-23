import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../GRN/barcode_scanner.dart';
import 'models/location_transfer_models.dart';
import 'services/location_transfer_service.dart';
import 'widgets/location_transfer_widgets.dart';
import 'dialogs/location_transfer_dialogs.dart';
import '../../../constants/wms_constant.dart';

class PutAwayPage extends StatefulWidget {
  const PutAwayPage({super.key});

  @override
  State<PutAwayPage> createState() => _PutAwayPageState();
}

class _PutAwayPageState extends State<PutAwayPage> {
  // Controllers
  final TextEditingController _forkliftController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Focus nodes
  final FocusNode _forkliftFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _stockFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();

  // State
  late LocationTransferData _transferData;

  @override
  void initState() {
    super.initState();
    _transferData = LocationTransferData();

    // Add focus listeners to auto-update steps
    _forkliftFocus.addListener(_onForkliftFocusChanged);
    _locationFocus.addListener(_onLocationFocusChanged);
    _stockFocus.addListener(_onStockFocusChanged);
    _quantityFocus.addListener(_onQuantityFocusChanged);

    // Auto-focus the first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
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
      title: const Text('PUT AWAY', style: GRNConstants.headerStyle),
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
          locationCode: _transferData.destinationLocationCode,
          stockCode: _transferData.stockCode,
          quantity: _transferData.quantity,
          step0Label: 'Stock Location',

          step1Label: 'Production Location',
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Scan Input Fields
                _buildScanInputs(),

                const SizedBox(height: 24),

                // Summary Card
                if (_transferData.forkliftCode != null ||
                    _transferData.destinationLocationCode != null ||
                    _transferData.stockCode != null)
                  _buildSummaryCard(),

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
          label: 'Stock Location',
          hint: 'Scan or enter stock location code',
          icon: Icons.local_shipping,
          isActive: true,
          isCompleted: _transferData.forkliftCode != null,
          value: _transferData.forkliftCode,
          onScan: _onForkliftScanned,
          onBarcodePressed: () => _openBarcodeScanner('forklift'),
        ),

        const SizedBox(height: 16),

        // Location Input
        ScanInputWidget(
          controller: _locationController,
          focusNode: _locationFocus,
          label: 'Production Location',
          hint: 'Scan or enter production location code',
          icon: Icons.location_on,
          isActive: true,
          isCompleted: _transferData.destinationLocationCode != null,
          value: _transferData.destinationLocationCode,
          onScan: _onLocationScanned,
          onBarcodePressed: () => _openBarcodeScanner('location'),
        ),

        const SizedBox(height: 16),

        // Stock Input
        ScanInputWidget(
          controller: _stockController,
          focusNode: _stockFocus,
          label: 'Stock Code',
          hint: 'Scan or enter stock code',
          icon: Icons.inventory,
          isActive: true,
          isCompleted: _transferData.stockCode != null,
          value: _transferData.stockCode,
          onScan: _onStockScanned,
          onBarcodePressed: () => _openBarcodeScanner('stock'),
        ),

        const SizedBox(height: 16),

        // Quantity Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GRNConstants.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GRNConstants.primaryBlue,
              width: 2,
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
                      color: GRNConstants.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.numbers,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: GRNConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocus,
                keyboardType: TextInputType.number,
                enabled: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: GRNConstants.primaryBlue),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _transferData = _transferData.copyWith(
                      quantity:
                          value.isNotEmpty ? double.tryParse(value) : null,
                      clearErrorMessage: true,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: Color(0xFF4A6FA5)),
              SizedBox(width: 8),
              Text(
                'Put Away Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A6FA5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_transferData.forkliftCode != null)
            _buildSummaryRow('Forklift/Trolley:', _transferData.forkliftCode!),
          if (_transferData.destinationLocationCode != null)
            _buildSummaryRow(
                'Destination:', _transferData.destinationLocationCode!),
          if (_transferData.stockCode != null)
            _buildSummaryRow('Stock Code:', _transferData.stockCode!),
          if (_transferData.quantity != null)
            _buildSummaryRow('Quantity:', _transferData.quantity!.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A6FA5),
              ),
            ),
          ),
        ],
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
    // Check if we can submit (using destination location instead of source)
    final canSubmit = _transferData.forkliftCode?.isNotEmpty == true &&
        _transferData.destinationLocationCode?.isNotEmpty == true &&
        _transferData.stockCode?.isNotEmpty == true &&
        _transferData.quantity != null &&
        _transferData.quantity! > 0;

    return Row(
      children: [
        // Submit Button
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit ? _submitPutAway : null,
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
                  canSubmit ? Icons.send : Icons.arrow_forward,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  canSubmit ? 'Submit Put Away' : 'Continue',
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
    if (!_stockFocus.hasFocus && _stockController.text.trim().isNotEmpty) {
      _onStockScanned(_stockController.text);
    }
  }

  void _onQuantityFocusChanged() {
    if (!_quantityFocus.hasFocus &&
        _quantityController.text.trim().isNotEmpty) {
      final quantity = double.tryParse(_quantityController.text.trim());
      if (quantity != null) {
        setState(() {
          _transferData = _transferData.copyWith(
            quantity: quantity,
            clearErrorMessage: true,
          );
        });
      }
    }
  }

  void _onForkliftScanned(String code) {
    if (code.trim().isEmpty) return;

    setState(() {
      _transferData = _transferData.copyWith(
        forkliftCode: code.trim(),
        currentStep: 1,
        clearErrorMessage: true,
      );
    });

    _forkliftController.text = code.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationFocus.requestFocus();
    });
  }

  void _onLocationScanned(String code) {
    if (code.trim().isEmpty) return;

    setState(() {
      _transferData = _transferData.copyWith(
        destinationLocationCode: code.trim(),
        currentStep: 2,
        clearErrorMessage: true,
      );
    });

    _locationController.text = code.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockFocus.requestFocus();
    });
  }

  void _onStockScanned(String code) {
    if (code.trim().isEmpty) return;

    setState(() {
      _transferData = _transferData.copyWith(
        stockCode: code.trim(),
        currentStep: 3,
        clearErrorMessage: true,
      );
    });

    _stockController.text = code.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quantityFocus.requestFocus();
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

  Future<void> _submitPutAway() async {
    if (_transferData.forkliftCode == null ||
        _transferData.destinationLocationCode == null ||
        _transferData.stockCode == null ||
        _transferData.quantity == null) return;

    setState(() {
      _transferData = _transferData.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      );
    });

    final request = LocationTransferRequest(
      forkliftCode: _transferData.forkliftCode!,
      sourceLocationCode: _transferData.destinationLocationCode!,
      stockCode: _transferData.stockCode!,
      quantity: _transferData.quantity ?? 1.0,
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
          errorMessage: 'Failed to submit put away: $e',
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
