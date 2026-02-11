import 'package:flutter/material.dart';
import 'models/outstanding_stock_models.dart';

import 'constants/grn_constants.dart';
import 'widgets/outstanding_stock_widgets.dart';
import 'dialogs/poql.dart';
import 'dialogs/outstanding_stock_dialogs.dart';
import 'services/outstanding_stock_service.dart';

class OutstandingStockPage extends StatefulWidget {
  final String poNumber;
  final String supplier;
  final String date;
  final String refNo;

  const OutstandingStockPage({
    super.key,
    required this.poNumber,
    required this.supplier,
    required this.date,
    required this.refNo,
  });

  @override
  State<OutstandingStockPage> createState() => _OutstandingStockPageState();
}

class _OutstandingStockPageState extends State<OutstandingStockPage> {
  final OutstandingStockService _service = OutstandingStockService();
  late OutstandingStockState _state;

  @override
  void initState() {
    super.initState();
    _state = OutstandingStockState(
      isLoading: false,
      items: [],
      errorMessage: null,
      poDetails: PODetails(
        poNumber: widget.poNumber,
        supplier: widget.supplier,
        date: widget.date,
        refNo: widget.refNo,
      ),
    );
    _fetchOutstandingStock();
  }

  Future<void> _fetchOutstandingStock() async {
    setState(() {
      _state = _state.copyWith(isLoading: true, errorMessage: null);
    });

    try {
      final items = await _service.fetchOutstandingStock(widget.poNumber);
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          items: items,
        );
      });
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      });
    }
  }

  void _processReceive(
      OutstandingStockItem item, int quantity, String uom) async {
    OutstandingStockDialogs.showProcessingSnackBar(context);

    try {
      await _service.processReceiveStock(
        item: item,
        quantity: quantity,
        uom: uom,
        poNumber: widget.poNumber,
      );

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          OutstandingStockDialogs.showSuccessSnackBar(
            context,
            item,
            quantity,
            uom,
          );
        }
      });

      // Update outstanding quantities
      final updatedItems = _service.updateOutstandingQuantities(
        currentItems: _state.items,
        receivedItem: item,
        receivedQuantity: quantity,
      );

      setState(() {
        _state = _state.copyWith(items: updatedItems);
      });

      // Refresh data after successful processing
      Future.delayed(Duration(seconds: 3), () {
        _fetchOutstandingStock();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing receive: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GRNConstants.primaryBlue,
      appBar: AppBar(
        backgroundColor: GRNConstants.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PO Line Item',
          style: GRNConstants.headerStyle,
        ),
        actions: [
          if (_state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          
        ],
      ),
      body: Column(
        children: [
          OutstandingStockWidgets.buildHeaderCard(widget.poNumber),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: GRNConstants.backgroundGray,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _fetchOutstandingStock,
                color: GRNConstants.primaryBlue,
                backgroundColor: Colors.white,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_state.isLoading) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: OutstandingStockWidgets.buildLoadingState(),
      );
    }

    if (_state.errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: OutstandingStockWidgets.buildErrorState(
          message: _state.errorMessage!,
          onRetry: _fetchOutstandingStock,
        ),
      );
    }

    if (_state.items.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: OutstandingStockWidgets.buildEmptyState(),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _state.items.length,
      itemBuilder: (context, index) {
        final item = _state.items[index];
        return OutstandingStockWidgets.buildStockCard(
          item: item,
          onTap: () => _showStockDetailsDialog(item),
        );
      },
    );
  }

  void _showStockDetailsDialog(OutstandingStockItem item) {
    StockDetailsDialog.showStockDetailsDialog(
      context: context,
      item: item,
      onConfirm: (packingSize, putawayWH, lotNumber, batchNumber) {
        // Handle the confirmation logic here
        print('Packing Size: $packingSize');
        print('Putaway WH: $putawayWH');
        print('Lot Number: $lotNumber');
        print('Batch Number: $batchNumber');
      },
    );
  }

  void _showReceiveDialog(OutstandingStockItem item) {
    OutstandingStockDialogs.showReceiveStockDialog(
      context: context,
      item: item,
      onReceive: _processReceive,
    );
  }
}

class OutstandingStockState {
  final bool isLoading;
  final List<OutstandingStockItem> items;
  final String? errorMessage; // Add this field
  final PODetails poDetails;

  OutstandingStockState({
    required this.isLoading,
    required this.items,
    this.errorMessage, // Initialize it here
    required this.poDetails,
  });

  OutstandingStockState copyWith({
    bool? isLoading,
    List<OutstandingStockItem>? items,
    String? errorMessage, 
    PODetails? poDetails,
  }) {
    return OutstandingStockState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage, // Copy the errorMessage
      poDetails: poDetails ?? this.poDetails,
    );
  }
}
