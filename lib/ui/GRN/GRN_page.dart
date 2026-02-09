import 'package:flutter/material.dart';
import 'add_grn_page.dart';
import 'models/grn_list_models.dart';
import 'constants/grn_list_constants.dart';
import 'constants/grn_constants.dart';
import 'widgets/grn_list_widgets.dart';
import 'services/grn_service.dart';

class GRNPage extends StatefulWidget {
  const GRNPage({super.key});

  @override
  State<GRNPage> createState() => _GRNPageState();
} 

class _GRNPageState extends State<GRNPage> {
  // Controllers
  final TextEditingController _dropdownSearchController = TextEditingController();
  final TextEditingController _poNumberController = TextEditingController();
  final TextEditingController _invoiceNumberController = TextEditingController();

  // State
  late GRNState _state;

  @override
  void initState() {
    super.initState();
    _state = GRNState(
      records: [],
      filters: GRNFilters(
        selectedAPCode: 'Supplier',
        selectedDate: 'Date',
        poNumber: '',
        invoiceNumber: '',
      ),
      isLoading: false,
      dropdownSearchQuery: '',
    );
    _poNumberController.addListener(_checkDoNumberInput);
    _fetchGrnData();
  }

  @override
  void dispose() {
    _poNumberController.removeListener(_checkDoNumberInput);
    _dropdownSearchController.dispose();
    _poNumberController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GRNConstants.primaryBlue,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          GRNFilterSection(
            filters: _state.filters,
            uniqueAPCodes: _state.uniqueAPCodes,
            uniqueDates: _state.uniqueDates,
            dropdownSearchQuery: _state.dropdownSearchQuery,
            poNumberController: _poNumberController,
            invoiceNumberController: _invoiceNumberController,
            dropdownSearchController: _dropdownSearchController,
            onAPCodeChanged: _onAPCodeChanged,
            onDateChanged: _onDateChanged,
            onSearchQueryChanged: _onSearchQueryChanged,
            onSelectCustomDate: _selectCustomDate,
          ),
          Expanded(
            child: GRNDataTable(
              records: _state.filteredRecords,
              isLoading: _state.isLoading,
              onRefresh: _fetchGrnData,
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
      title: const Text('Receiving', style: GRNConstants.headerStyle),
      centerTitle: true,
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
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: GRNConstants.primaryBlue,
      onPressed: () {
        if (_poNumberController.text.trim().isEmpty) {
          _showErrorSnackBar('Please enter a valid DO Number');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddGRNPage(
            poNumberController: _poNumberController,
            invoiceNumberController: _invoiceNumberController,
          ),
          ),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // Event Handlers
  void _checkDoNumberInput() {
    setState(() {
      _state = _state.copyWith(
        filters: _state.filters.copyWith(
          poNumber: _poNumberController.text.trim(),
        ),
      );
    });
  }

  void _onAPCodeChanged(String? apCode) {
    setState(() {
      _state = _state.copyWith(
        filters: _state.filters.copyWith(selectedAPCode: apCode),
        dropdownSearchQuery: '',
      );
      _dropdownSearchController.clear();
    });
  }

  void _onDateChanged(String date) {
    setState(() {
      _state = _state.copyWith(
        filters: _state.filters.copyWith(selectedDate: date),
      );
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _state = _state.copyWith(dropdownSearchQuery: query);
    });
  }

  Future<void> _selectCustomDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _state.filters.selectedCustomDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: GRNConstants.primaryBlue,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: GRNConstants.primaryBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          _state = _state.copyWith(
            filters: _state.filters.copyWith(
              selectedCustomDate: picked,
              selectedDate: '${picked.day}/${picked.month}/${picked.year}',
            ),
          );
        });
      }
    } catch (e) {
    
      _showErrorSnackBar('Error opening date picker');
    }
  }

  // Data Operations
  Future<void> _fetchGrnData() async {
    setState(() {
      _state = _state.copyWith(isLoading: true);
    });

    try {
      final records = await GRNService.fetchGrnData();
      setState(() {
        _state = _state.copyWith(
          records: records,
          isLoading: false,
        );
      });

      _showSuccessSnackBar('Refreshed ${records.length} GRN records');
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          records: GRNService.getMockData(),
          isLoading: false,
        );
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // Helper Methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
