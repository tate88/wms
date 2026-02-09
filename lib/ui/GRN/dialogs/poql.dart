import 'package:flutter/material.dart';
import '../models/outstanding_stock_models.dart';
import '../constants/outstanding_stock_constants.dart';
import '../widgets/outstanding_stock_widgets.dart';
import 'package:WMS/ui/GRN/generate_barcode.dart';
import '../constants/grn_constants.dart';

class StockDetailsDialog {
  static void showStockDetailsDialog({
    required BuildContext context,
    required OutstandingStockItem item,
    String? defaultPackingSize,
    String? defaultPutawayWH,
    required Function(String packingSize, String putawayWH, String lotNumber,
            String batchNumber)
        onConfirm,
  }) {
    final packingSizeController =
        TextEditingController(text: defaultPackingSize ?? '');
    final putawayWHController =
        TextEditingController(text: defaultPutawayWH ?? '');
    final lotNumberController = TextEditingController();
    final batchNumberController = TextEditingController();
    final _mfgDateController = TextEditingController();
    final _expDateController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                          child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item Details',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      )),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white, size: 20),
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
                        Text(
                          'Lot No',
                          style: GRNConstants.formLabelStyle,
                        ),

                        SizedBox(height: 8),
                        buildTextInput(
                          controller: lotNumberController,
                        ),
                        SizedBox(height: 20),

                        // Batch Number input
                        Text(
                          'Batch No',
                          style: GRNConstants.formLabelStyle,
                        ),
                        SizedBox(height: 8),
                        buildTextInput(
                          controller: batchNumberController,
                        ),
                        SizedBox(height: 20),

                         Text(
                          'Manufacturing Date',
                          style: GRNConstants.formLabelStyle,
                        ),
                        SizedBox(height: 8),
                       
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
                        SizedBox(height: 20),

                        Text(
                          'Expiry Date',
                          style: GRNConstants.formLabelStyle,
                        ),
                        SizedBox(height: 8),
                        
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
                        SizedBox(height: 20),

                        // Packing Size input
                        Text(
                          'Pack Size',
                          style: GRNConstants.formLabelStyle,
                        ),
                        SizedBox(height: 8),
                        buildTextInput(
                          controller: packingSizeController,
                        ),
                        SizedBox(height: 20),

                        Text(
                          'Putaway Warehouse',
                          style: GRNConstants.formLabelStyle,
                        ),
                        SizedBox(height: 8),
                        buildTextInput(
                          controller: putawayWHController,
                        ),
                        SizedBox(height: 20),

                       
                      ],
                    ),
                  ),
                ),

                // Action buttons
                _buildStockDetailsActionButtons(
                  context: context,
                  packingSizeController: packingSizeController,
                  putawayWHController: putawayWHController,
                  lotNumberController: lotNumberController,
                  batchNumberController: batchNumberController,
                  item: item,
                  onConfirm: onConfirm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  static Widget buildTextInput({
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
                'Outstanding Quantity: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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

  static Widget _buildStockDetailsActionButtons({
    required BuildContext context,
    required TextEditingController packingSizeController,
    required TextEditingController putawayWHController,
    required TextEditingController lotNumberController,
    required TextEditingController batchNumberController,
    required OutstandingStockItem item,
    required Function(
      String packingSize,
      String putawayWH,
      String lotNumber,
      String batchNumber,
    ) onConfirm,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GRNConstants.backgroundGray,
        borderRadius: const BorderRadius.only(
          bottomLeft:
              Radius.circular(GRNConstants.dialogBorderRadius),
          bottomRight:
              Radius.circular(GRNConstants.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                final packingSize = packingSizeController.text.trim();
                final putawayWH = putawayWHController.text.trim();
                final lotNumber = lotNumberController.text.trim();
                final batchNumber = batchNumberController.text.trim();

                Navigator.of(context).pop();

                await Future.sync(() => onConfirm(
                      packingSize,
                      putawayWH,
                      lotNumber,
                      batchNumber,
                    ));

                if (!context.mounted) return;

                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => BarcodePrintDetailsPage(
                      lot: lotNumber,
                      batch: batchNumber,
                      startSeq: 1,
                      packSize: packingSize,
                      stockShortName: item.stkNameS,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GRNConstants.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
}
