import '../../../constants/wms_constant.dart';
import '../models/location_transfer_models.dart';
import 'package:flutter/material.dart';

class ProgressStepsWidget extends StatelessWidget {
  final int currentStep;
  final String? forkliftCode;
  final List<StockItem> stockItems;
  final String? sourceLocationCode;
  final String? destinationLocationCode;
  final String? step0Label;
  final String? step1Label;
  final String? step2Label;

  const ProgressStepsWidget({
    super.key,
    required this.currentStep,
    this.forkliftCode,
    this.stockItems = const [],
    this.sourceLocationCode,
    this.destinationLocationCode,
    this.step0Label,
    this.step1Label,
    this.step2Label,
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
          // Steps
          Row(
            children: [
              _buildStepIndicator(
                0,
                step0Label ?? 'Forklift',
                step0Label == 'Carrier'
                    ? Icons.forklift
                    : step0Label == 'Forklift'
                        ? Icons.forklift
                        : step0Label == 'Trolley'
                            ? Icons.forklift
                            : Icons.source,
                forkliftCode,
              ),
              _buildStepConnector(0),
              _buildStepIndicator(
                1,
                step1Label ?? 'Item',
                Icons.inventory,
                stockItems.isNotEmpty ? '${stockItems.length} items' : null,
              ),
              _buildStepConnector(1),
              _buildStepIndicator(
                2,
                step2Label ?? 'Source Location',
                step2Label != null ? Icons.location_on : Icons.source,
                sourceLocationCode,
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
    final bool isCompleted = value?.isNotEmpty == true;
    // For Items step (step 1), only make it active if there are actual items
    final bool isActive =
        step == 1 ? stockItems.isNotEmpty : currentStep >= step;

    return SizedBox(
      width: 70,
      child: Column(
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
              color: isCompleted
                  ? Colors.white
                  : (isActive ? Colors.white : Colors.grey[600]),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? const Color(0xFF4A6FA5) : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    bool isCompleted = false;

    // Check completion based on step number
    if (step == 0) {
      // Connector from Source Location to Items
      isCompleted = forkliftCode?.isNotEmpty == true && stockItems.isNotEmpty;
    } else if (step == 1) {
      // Connector from Items to Destination Location
      isCompleted =
          stockItems.isNotEmpty && sourceLocationCode?.isNotEmpty == true;
    }

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
        return 0.33;
      case 1:
        return 0.66;
      case 2:
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

  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final String? value;
  final Function(String) onScan;
  final VoidCallback? onBarcodePressed;
  final Function(String)? onChanged;

  const ScanInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.onScan,
    this.value,
    this.onBarcodePressed,
    this.onChanged,
  });

  @override
  State<ScanInputWidget> createState() => _ScanInputWidgetState();
}

class _ScanInputWidgetState extends State<ScanInputWidget> {
  @override
  void initState() {
    super.initState();
    // Add focus listener to rebuild when focus changes
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      // This will trigger a rebuild when focus changes
    });
  }

  @override
  void didUpdateWidget(ScanInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update listener if focusNode changed
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }

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
                color: widget.isActive ? Colors.white : Colors.grey[600],
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
          ],
        ),

        const SizedBox(height: 12),

        // Input Field
        Container(
          decoration: BoxDecoration(
            color: widget.focusNode.hasFocus
                ? GRNConstants.primaryBlue.withOpacity(0.05)
                : widget.isCompleted
                    ? GRNConstants.green.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.focusNode.hasFocus
                  ? GRNConstants.primaryBlue
                  : widget.isCompleted
                      ? GRNConstants.green
                      : Colors.grey[300]!,
              width: widget.focusNode.hasFocus ? 2 : 1,
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
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color:
                    widget.isCompleted ? GRNConstants.green : Colors.grey[500],
                fontWeight:
                    widget.isCompleted ? FontWeight.w500 : FontWeight.normal,
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
      ],
    );
  }
}
