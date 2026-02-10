import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../GRN/barcode_scanner.dart';
import 'models/location_transfer_models.dart';
import 'services/location_transfer_service.dart';
import 'widgets/location_transfer_widgets.dart';
import 'dialogs/location_transfer_dialogs.dart';
import '../../constants/wms_constant.dart';

class LocationToPage extends StatefulWidget {
  const LocationToPage({super.key});

  @override
  State<LocationToPage> createState() => _LocationToPageState();
}

class _LocationToPageState extends State<LocationToPage> {
  // Controllers
  final TextEditingController _forkliftController = TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Focus nodes
  final FocusNode _forkliftFocus = FocusNode();
  final FocusNode _destinationLocationFocus = FocusNode();
  final FocusNode _stockFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();

  // State
  late LocationToData _transferData;

  @override
  void initState() {
    super.initState();
    _transferData = LocationToData();

    // Auto-focus the first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _forkliftController.dispose();
    _destinationLocationController.dispose();
    _stockController.dispose();
    _quantityController.dispose();
    _forkliftFocus.dispose();
    _destinationLocationFocus.dispose();
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
      title:
          const Text('Location Transfer To', style: GRNConstants.headerStyle),
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
        LocationToProgressStepsWidget(
          currentStep: _transferData.currentStep,
          forkliftCode: _transferData.forkliftCode,
          destinationLocationCode: _transferData.destinationLocationCode,
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

        // Destination Location Input
        ScanInputWidget(
          controller: _destinationLocationController,
          focusNode: _destinationLocationFocus,
          label: 'Destination Location',
          hint: 'Scan or enter destination location code',
          icon: Icons.place,
          isActive: _transferData.currentStep == 1,
          isCompleted: _transferData.destinationLocationCode != null,
          value: _transferData.destinationLocationCode,
          onScan: _onDestinationLocationScanned,
          onBarcodePressed: () => _openBarcodeScanner('destination'),
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
          if (_transferData.destinationLocationCode != null)
            _buildSummaryRow('Destination Location:',
                _transferData.destinationLocationCode!),
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
            width: 140,
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
        return Icons.place;
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
      _destinationLocationFocus.requestFocus();
    });
  }

  void _onDestinationLocationScanned(String code) {
    if (code.trim().isEmpty) return;

    setState(() {
      _transferData = _transferData.copyWith(
        destinationLocationCode: code.trim(),
        currentStep: 2,
        clearErrorMessage: true,
      );
    });

    _destinationLocationController.text = code.trim();

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
            destinationLocationCode: null,
            stockCode: null,
            quantity: null,
          );
          _destinationLocationController.clear();
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
            _destinationLocationFocus.requestFocus();
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
        case 'destination':
          _onDestinationLocationScanned(result);
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

    final request = LocationToRequest(
      forkliftCode: _transferData.forkliftCode!,
      destinationLocationCode: _transferData.destinationLocationCode!,
      stockCode: _transferData.stockCode!,
      quantity: _transferData.quantity ?? 1.0,
    );

    try {
      // Use mock service for testing, replace with real service
      final response =
          await LocationTransferService.submitTransferToMock(request);

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
      builder: (context) => LocationToSuccessDialog(
        response: response,
        transferData: _transferData,
        onNewTransfer: _resetTransfer,
      ),
    );
  }

  void _resetTransfer() {
    setState(() {
      _transferData = LocationToData();
    });

    _forkliftController.clear();
    _destinationLocationController.clear();
    _stockController.clear();
    _quantityController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forkliftFocus.requestFocus();
    });
  }
}

// Location To Data Model
class LocationToData {
  final String? forkliftCode;
  final String? destinationLocationCode;
  final String? stockCode;
  final double? quantity;
  final int
      currentStep; // 0=Forklift, 1=Destination Location, 2=Stock Code, 3=Quantity
  final bool isLoading;
  final String? errorMessage;
  final LocationTransferResponse? lastResponse;

  LocationToData({
    this.forkliftCode,
    this.destinationLocationCode,
    this.stockCode,
    this.quantity,
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lastResponse,
  });

  LocationToData copyWith({
    String? forkliftCode,
    String? destinationLocationCode,
    String? stockCode,
    double? quantity,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
    LocationTransferResponse? lastResponse,
    bool clearErrorMessage = false,
  }) {
    return LocationToData(
      forkliftCode: forkliftCode ?? this.forkliftCode,
      destinationLocationCode:
          destinationLocationCode ?? this.destinationLocationCode,
      stockCode: stockCode ?? this.stockCode,
      quantity: quantity ?? this.quantity,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  bool get canSubmit {
    return forkliftCode?.isNotEmpty == true &&
        destinationLocationCode?.isNotEmpty == true &&
        stockCode?.isNotEmpty == true &&
        quantity != null &&
        quantity! > 0;
  }

  String get currentStepTitle {
    switch (currentStep) {
      case 0:
        return 'Select Forklift/Trolley';
      case 1:
        return 'Scan Destination Location';
      case 2:
        return 'Scan Stock Code';
      case 3:
        return 'Enter Quantity';
      default:
        return 'Unknown Step';
    }
  }

  String get currentStepHint {
    switch (currentStep) {
      case 0:
        return 'Choose forklift or trolley for transfer';
      case 1:
        return 'Scan or enter destination location code';
      case 2:
        return 'Scan stock barcode to transfer';
      case 3:
        return 'Enter the quantity to transfer';
      default:
        return '';
    }
  }
}

// Location To Request Model
class LocationToRequest {
  final String forkliftCode;
  final String destinationLocationCode;
  final String stockCode;
  final double quantity;

  LocationToRequest({
    required this.forkliftCode,
    required this.destinationLocationCode,
    required this.stockCode,
    this.quantity = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'forkliftCode': forkliftCode,
      'destinationLocationCode': destinationLocationCode,
      'stockCode': stockCode,
      'quantity': quantity,
    };
  }

  factory LocationToRequest.fromMap(Map<String, dynamic> map) {
    return LocationToRequest(
      forkliftCode: map['forkliftCode'] ?? '',
      destinationLocationCode: map['destinationLocationCode'] ?? '',
      stockCode: map['stockCode'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 1.0,
    );
  }
}

// Progress Steps Widget for Location To
class LocationToProgressStepsWidget extends StatelessWidget {
  final int currentStep;
  final String? forkliftCode;
  final String? destinationLocationCode;
  final String? stockCode;
  final double? quantity;

  const LocationToProgressStepsWidget({
    super.key,
    required this.currentStep,
    this.forkliftCode,
    this.destinationLocationCode,
    this.stockCode,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _getProgress(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FA5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Steps
          Row(
            children: [
              _buildStepIndicator(
                0,
                'Forklift',
                Icons.local_shipping,
                forkliftCode,
              ),
              _buildStepConnector(0),
              _buildStepIndicator(
                1,
                'Destination',
                Icons.place,
                destinationLocationCode,
              ),
              _buildStepConnector(1),
              _buildStepIndicator(
                2,
                'Stock',
                Icons.inventory,
                stockCode,
              ),
              _buildStepConnector(2),
              _buildStepIndicator(
                3,
                'Quantity',
                Icons.numbers,
                quantity?.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    IconData icon,
    String? value,
  ) {
    final bool isActive = currentStep >= step;
    final bool isCompleted = value?.isNotEmpty == true;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? GRNConstants.green
                : isActive
                    ? GRNConstants.primaryBlue
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF4A6FA5) : Colors.grey[600],
          ),
        ),
        if (value?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 80),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GRNConstants.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GRNConstants.green.withOpacity(0.3)),
            ),
            child: Text(
              value!,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: GRNConstants.green,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final bool isCompleted = currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
        color: isCompleted ? GRNConstants.green : Colors.grey[300],
      ),
    );
  }

  double _getProgress() {
    switch (currentStep) {
      case 0:
        return 0.25;
      case 1:
        return 0.5;
      case 2:
        return 0.75;
      case 3:
        return 1.0;
      default:
        return 0.0;
    }
  }
}

// Success Dialog for Location To
class LocationToSuccessDialog extends StatelessWidget {
  final LocationTransferResponse response;
  final LocationToData transferData;
  final VoidCallback onNewTransfer;

  const LocationToSuccessDialog({
    super.key,
    required this.response,
    required this.transferData,
    required this.onNewTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: GRNConstants.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: GRNConstants.green,
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Success Title
            const Text(
              'Transfer Completed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Success Message
            Text(
              response.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // Transfer Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Forklift:', transferData.forkliftCode ?? ''),
                  _buildDetailRow('Destination:',
                      transferData.destinationLocationCode ?? ''),
                  _buildDetailRow('Stock Code:', transferData.stockCode ?? ''),
                  _buildDetailRow(
                      'Quantity:', transferData.quantity?.toString() ?? ''),
                  if (response.transferId != null)
                    _buildDetailRow('Transaction ID:', response.transferId!),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNewTransfer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GRNConstants.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'New Transfer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
}
