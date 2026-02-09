import 'package:flutter/material.dart';
import '../models/outstanding_stock_models.dart';
import '../constants/outstanding_stock_constants.dart';
import '../widgets/outstanding_stock_widgets.dart';
import '../constants/grn_constants.dart';
class OutstandingStockDialogs {
  static void showReceiveStockDialog({
    required BuildContext context,
    required OutstandingStockItem item,
    required Function(OutstandingStockItem item, int quantity, String uom)
        onReceive,
  }) {
    final qtyController = TextEditingController();
    final availableUoms = item.availableUoms ?? [item.trxUom];
    String selectedUom = item.trxUom;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      GRNConstants.dialogBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 20, 16, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GRNConstants.primaryBlue,
                            GRNConstants.lightBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              GRNConstants.dialogBorderRadius),
                          topRight: Radius.circular(
                              GRNConstants.dialogBorderRadius),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Quantity Received',
                                        style: GRNConstants
                                            .dialogHeaderStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close,
                                color: Colors.white, size: 20),
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item details card
                            _buildItemDetailsCard(item),
                            SizedBox(height: 20),

                            // Quantity input section
                            Text(
                              'Quantity',
                              style: GRNConstants.formLabelStyle,
                            ),
                            SizedBox(height: 8),
                            OutstandingStockWidgets.buildQuantityInput(
                              controller: qtyController,
                            ),
                            SizedBox(height: 20),

                            // UOM selection
                            if (availableUoms.isNotEmpty) ...[
                              Text(
                                'Unit of Measure',
                                style:
                                    GRNConstants.sectionTitleStyle,
                              ),
                              SizedBox(height: 8),
                              OutstandingStockWidgets.buildUomDropdown(
                                selectedValue: selectedUom,
                                items: availableUoms,
                                onChanged: (value) {
                                  setState(() {
                                    selectedUom = value!;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Action buttons
                    _buildActionButtons(
                      context: context,
                      item: item,
                      qtyController: qtyController,
                      selectedUom: selectedUom,
                      onReceive: onReceive,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildItemDetailsCard(OutstandingStockItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDEE2E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.stkCode,
                style: GRNConstants.stockCodeStyle,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            item.stkNameS,
            style: GRNConstants.sectionTitleStyle,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Outstanding Qty: ',
                style: GRNConstants.sectionTitleStyle,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GRNConstants.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: GRNConstants.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${item.trxStkQty} ${item.trxUom}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GRNConstants.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButtons({
    required BuildContext context,
    required OutstandingStockItem item,
    required TextEditingController qtyController,
    required String selectedUom,
    required Function(OutstandingStockItem item, int quantity, String uom)
        onReceive,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GRNConstants.backgroundGray,
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(GRNConstants.dialogBorderRadius),
          bottomRight:
              Radius.circular(GRNConstants.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          /* 
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF64748B),
                side: BorderSide(
                  color: GRNConstants.borderGray,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
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
          SizedBox(width: 12),*/
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyController.text);
                if (qty == null || qty <= 0) {
                  _showValidationError(
                    context,
                    'Please enter a valid quantity',
                    Icons.error_outline,
                    Colors.red[600]!,
                  );
                  return;
                }

                if (qty > item.trxStkQty) {
                  _showValidationError(
                    context,
                    'Quantity cannot exceed outstanding quantity',
                    Icons.warning_outlined,
                    Colors.orange[600]!,
                  );
                  return;
                }

                Navigator.of(context).pop();
                onReceive(item, qty, selectedUom);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GRNConstants.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showValidationError(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void showProcessingSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Processing receive transaction...'),
          ],
        ),
        backgroundColor: GRNConstants.primaryBlue,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(
    BuildContext context,
    OutstandingStockItem item,
    int quantity,
    String uom,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Received Successfully!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${quantity} ${uom} of ${item.stkCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
