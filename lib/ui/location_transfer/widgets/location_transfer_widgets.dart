import '../../../constants/wms_constant.dart';
import 'package:flutter/material.dart';

class ProgressStepsWidget extends StatelessWidget {
  final int currentStep;
  final String? forkliftCode;
  final String? locationCode;
  final String? stockCode;
  final double? quantity;

  const ProgressStepsWidget({
    super.key,
    required this.currentStep,
    this.forkliftCode,
    this.locationCode,
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
                'Location',
                Icons.location_on,
                locationCode,
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

class ScanInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final String? value;
  final Function(String) onScan;
  final VoidCallback? onBarcodePressed;

  const ScanInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.onScan,
    this.value,
    this.onBarcodePressed,
  });

  @override
  State<ScanInputWidget> createState() => _ScanInputWidgetState();
}

class _ScanInputWidgetState extends State<ScanInputWidget> {
  @override
  void didUpdateWidget(ScanInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller text when value changes
    if (widget.value != oldWidget.value && widget.value != null) {
      widget.controller.text = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with status indicator
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? GRNConstants.green
                    : widget.isActive
                        ? GRNConstants.primaryBlue
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive 
                    ? Colors.white
                    : Colors.grey[600],
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isActive || widget.isCompleted
                    ? Colors.black87
                    : Colors.grey[600],
              ),
            ),
            if (widget.isCompleted) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GRNConstants.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: GRNConstants.green.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: GRNConstants.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Scanned',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: GRNConstants.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Input Field
        Container(
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? GRNConstants.green.withOpacity(0.05)
                : widget.isActive
                    ? GRNConstants.primaryBlue.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isCompleted
                  ? GRNConstants.green
                  : widget.isActive
                      ? GRNConstants.primaryBlue
                      : Colors.grey[300]!,
              width: widget.isActive ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.isActive,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onScan(value.trim());
              }
            },
            decoration: InputDecoration(
              hintText: widget.isCompleted ? widget.value : widget.hint,
              hintStyle: TextStyle(
                color:
                    widget.isCompleted ? GRNConstants.green : Colors.grey[500],
                fontWeight:
                    widget.isCompleted ? FontWeight.w500 : FontWeight.normal,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: widget.isCompleted
                    ? GRNConstants.green
                    : widget.isActive
                        ? GRNConstants.primaryBlue
                        : Colors.grey[400],
              ),
              suffixIcon: widget.isCompleted
                  ? const Icon(Icons.check_circle, color: GRNConstants.green)
                  : widget.isActive && widget.onBarcodePressed != null
                      ? IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          color: const Color(0xFF4A6FA5),
                          onPressed: widget.onBarcodePressed,
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.isCompleted
                  ? GRNConstants.green
                  : widget.isActive
                      ? Colors.black87
                      : Colors.grey[600],
            ),
            readOnly: widget.isCompleted,
          ),
        ),

        // Helper text for active step
        if (widget.isActive && !widget.isCompleted) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scan barcode or type manually and press Enter',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
