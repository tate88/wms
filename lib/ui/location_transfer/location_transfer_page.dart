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

    // Auto-focus the first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
    });
  }

  @override
  void dispose() {
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
      title: const Text('Location Transfer', style: GRNConstants.headerStyle),
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
          locationCode: _transferData.sourceLocationCode,
          stockCode: _transferData.stockCode,
          quantity: _transferData.quantity,
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Step Card
                _buildCurrentStepCard(),

                const SizedBox(height: 24),

                // Scan Input Fields
                _buildScanInputs(),

                const SizedBox(height: 24),

                // Summary Card
                if (_transferData.forkliftCode != null ||
                    _transferData.sourceLocationCode != null ||
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

  Widget _buildCurrentStepCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStepColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStepColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStepColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStepIcon(),
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
                  _transferData.currentStepTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getStepColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transferData.currentStepHint,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStepColor().withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanInputs() {
    return Column(
      children: [
        // Forklift Input
        ScanInputWidget(
          controller: _forkliftController,
          focusNode: _forkliftFocus,
          label: 'Forklift/Trolley Code',
          hint: 'Scan or enter forklift code',
          icon: Icons.local_shipping,
          isActive: _transferData.currentStep == 0,
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
          label: 'Source Location',
          hint: 'Scan or enter location code',
          icon: Icons.location_on,
          isActive: _transferData.currentStep == 1,
          isCompleted: _transferData.sourceLocationCode != null,
          value: _transferData.sourceLocationCode,
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
          isActive: _transferData.currentStep == 2,
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
            color: _transferData.currentStep == 3
                ? GRNConstants.primaryBlue.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _transferData.currentStep == 3
                  ? GRNConstants.primaryBlue
                  : Colors.grey.withOpacity(0.3),
              width: _transferData.currentStep == 3 ? 2 : 1,
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
                      color: _transferData.currentStep == 3
                          ? GRNConstants.primaryBlue
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.numbers,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _transferData.currentStep == 3
                          ? GRNConstants.primaryBlue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocus,
                keyboardType: TextInputType.number,
                enabled: _transferData.currentStep == 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: GRNConstants.primaryBlue),
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
                onFieldSubmitted: (value) {
                  // When user presses Enter, submit if all data is complete
                  if (_transferData.canSubmit) {
                    _submitTransfer();
                  }
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
                'Transfer Summary',
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
          if (_transferData.sourceLocationCode != null)
            _buildSummaryRow(
                'Source Location:', _transferData.sourceLocationCode!),
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
    return Row(
      children: [
        // Back Button
        if (_transferData.currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _goBack,
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
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

        if (_transferData.currentStep > 0) const SizedBox(width: 12),

        // Submit/Next Button
        Expanded(
          flex: _transferData.currentStep > 0 ? 2 : 1,
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
                  _transferData.canSubmit ? 'Submit Transfer' : 'Continue',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStepColor() {
    switch (_transferData.currentStep) {
      case 0:
        return GRNConstants.primaryBlue;
      case 1:
        return GRNConstants.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStepIcon() {
    switch (_transferData.currentStep) {
      case 0:
        return Icons.local_shipping;
      case 1:
        return Icons.location_on;
      case 2:
        return Icons.inventory;
      case 3:
        return Icons.numbers;
      default:
        return Icons.info;
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
        sourceLocationCode: code.trim(),
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

  void _goBack() {
    if (_transferData.currentStep > 0) {
      setState(() {
        final newStep = _transferData.currentStep - 1;
        _transferData = _transferData.copyWith(
          currentStep: newStep,
          clearErrorMessage: true,
        );

        // Clear the appropriate field
        if (newStep == 0) {
          _transferData = _transferData.copyWith(
            sourceLocationCode: null,
            stockCode: null,
            quantity: null,
          );
          _locationController.clear();
          _stockController.clear();
          _quantityController.clear();
        } else if (newStep == 1) {
          _transferData = _transferData.copyWith(
            stockCode: null,
            quantity: null,
          );
          _stockController.clear();
          _quantityController.clear();
        } else if (newStep == 2) {
          _transferData = _transferData.copyWith(quantity: null);
          _quantityController.clear();
        }
      });

      // Focus appropriate field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (_transferData.currentStep) {
          case 0:
            _forkliftFocus.requestFocus();
            break;
          case 1:
            _locationFocus.requestFocus();
            break;
          case 2:
            _stockFocus.requestFocus();
            break;
          case 3:
            _quantityFocus.requestFocus();
            break;
        }
      });
    }
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
      sourceLocationCode: _transferData.sourceLocationCode!,
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
