import 'package:flutter/material.dart';
import '../GRN/constants/grn_constants.dart';
import 'barcode_scanner.dart';

class BarcodePrintDetailsPage extends StatefulWidget {
  final String stockShortName;
  final String lot;
  final String batch;
  final int startSeq;
  final String packSize;

  const BarcodePrintDetailsPage({
    super.key,
    required this.stockShortName,
    required this.lot,
    required this.batch,
    this.startSeq = 1,
    required this.packSize,
  });

  @override
  State<BarcodePrintDetailsPage> createState() =>
      _BarcodePrintDetailsPageState();
}

class PrintJob {
  final String lot;
  final String batch;
  final int seq;
  final String packSize;
  final DateTime time;

  const PrintJob({
    required this.lot,
    required this.batch,
    required this.seq,
    required this.packSize,
    required this.time,
  });

  String get seqText => seq.toString().padLeft(4, '0');
  String get payload => "$lot | $batch | $seqText | $packSize";
}

class _BarcodePrintDetailsPageState extends State<BarcodePrintDetailsPage> {
  late final TextEditingController _lotCtrl;
  late final TextEditingController _batchCtrl;
  late final TextEditingController _packSizeCtrl;
  late int _seq;
  bool _printerConnected = true;
  final List<PrintJob> _history = [];

  // Modern color palette - solid colors only

  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _lotCtrl = TextEditingController(text: widget.lot);
    _batchCtrl = TextEditingController(text: widget.batch);
    _packSizeCtrl = TextEditingController(text: widget.packSize);
    _seq = widget.startSeq;
  }

  @override
  void dispose() {
    _lotCtrl.dispose();
    _batchCtrl.dispose();
    _packSizeCtrl.dispose();
    super.dispose();
  }

  String get _seqText => _seq.toString().padLeft(4, '0');
  String get _previewText =>
      "${widget.stockShortName}\n$_seqText | ${_packSizeCtrl.text.trim()}";
  Future<void> _sendToPrinter(String payload) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  Future<void> onPrint() async {
    final lot = _lotCtrl.text.trim();
    final batch = _batchCtrl.text.trim();
    final packSize = _packSizeCtrl.text.trim();

    if (lot.isEmpty || batch.isEmpty || packSize.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("All fields are required"),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: errorRed,
          ),
        );
      }
      return;
    }

    final payload =
        "$lot | $batch | ${_seq.toString().padLeft(4, '0')} | $packSize";

    await _sendToPrinter(payload);

    // DO NOT add to history here - only add when scanned

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✓ Printed: $payload"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: successGreen,
        ),
      );
    }
  }

  Future<void> onReprint(PrintJob job) async {
    await _sendToPrinter(job.payload);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ Reprinted: ${job.payload}"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: successGreen,
      ),
    );
  }

  void openReprintPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: GRNConstants.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Print History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_history.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No print history available",
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    shrinkWrap: true,
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final job = _history[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: GRNConstants.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.payload,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  //const SizedBox(height: 4),
                                  // Text(
                                  //   job.time
                                  //       .toLocal()
                                  //       .toString()
                                  //       .substring(0, 19),
                                  //   style: const TextStyle(
                                  //     fontSize: 13,
                                  //     color: textSecondary,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _printerConnected
                                  ? () async {
                                      Navigator.pop(ctx);
                                      await onReprint(job);
                                    }
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: GRNConstants.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Reprint",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
  }

  void _showPackSizeEditDialog() {
    final TextEditingController tempController =
        TextEditingController(text: _packSizeCtrl.text);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(GRNConstants.dialogBorderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Set the dialog content background to white
              borderRadius:
                  BorderRadius.circular(GRNConstants.dialogBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GRNConstants.primaryBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(GRNConstants.dialogBorderRadius),
                      topRight:
                          Radius.circular(GRNConstants.dialogBorderRadius),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Edit Pack Size',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pack Size",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: tempController,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g., 100pcs, 50kg",
                          hintStyle: TextStyle(
                            color: textSecondary.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white, // Set background to white
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                GRNConstants.defaultBorderRadius),
                            borderSide: const BorderSide(
                              color: GRNConstants.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer with buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, // Set footer background to white
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
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (tempController.text.trim().isNotEmpty) {
                              setState(() {
                                _packSizeCtrl.text = tempController.text.trim();
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "✓ Pack size updated to: ${tempController.text.trim()}",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: successGreen,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GRNConstants.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  GRNConstants.defaultBorderRadius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCompleteSave() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Complete Session",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to complete this barcode printing session?",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Scanned:",
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        "${_history.length} items",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current Seq:",
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        _seqText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: successGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Save data to database/API here
      // Example: await saveToDatabase(_history, _seq);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("✓ Saved ${_history.length} scanned items successfully!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate back or reset
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, {
          'saved': true,
          'totalScanned': _history.length,
          'finalSeq': _seq,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
          backgroundColor: GRNConstants.primaryBlue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Print Label',
            style: GRNConstants.headerStyle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarcodeScannerPage(
                      currentLot: _lotCtrl.text,
                      currentBatch: _batchCtrl.text,
                      currentSeq: _seq,
                      currentPackSize: _packSizeCtrl.text,
                    ),
                  ),
                );

                // Handle scanned result
                if (result != null && result is Map<String, dynamic>) {
                  if (result['isValid'] == true) {
                    // Extract sequence number and validate
                    try {
                      final scannedSeq = int.parse(result['seq']);
                      final expectedSeq = _seq;

                      // Check if scanned sequence matches expected sequence
                      if (scannedSeq != expectedSeq) {
                        // Sequence mismatch - show error
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.error_outline_rounded,
                                      color: errorRed,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "Invalid Seq No",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${result['lot']};${result['batch']};${result['seq']};${result['packSize']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_rounded,
                                          color: errorRed,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Invalid Seq No. Please scan Seq No ${expectedSeq.toString().padLeft(4, '0')}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: errorRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Scanned: ${scannedSeq.toString().padLeft(4, '0')}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Expected: ${expectedSeq.toString().padLeft(4, '0')}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: GRNConstants.primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        // Sequence matches - proceed with update
                        final nextSeq = scannedSeq + 1;

                        // Create job for history
                        final job = PrintJob(
                          lot: result['lot'],
                          batch: result['batch'],
                          seq: scannedSeq,
                          packSize: result['packSize'],
                          time: DateTime.now(),
                        );

                        setState(() {
                          _seq = nextSeq;
                          _history.insert(
                              0, job); // Add to history only when scanned
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "✓ Scanned: ${result['seq']} → Next: ${nextSeq.toString().padLeft(4, '0')}"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: successGreen,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("⚠ Failed to parse sequence number"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: errorRed,
                          ),
                        );
                      }
                    }
                  }
                }
              },
            )
          ]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Card
              _ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelPreviewBox(text: _previewText),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.visibility_rounded,
                            color: GRNConstants.primaryBlue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Preview Label",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // // Lot Number
              // const Text(
              //   "Lot Number",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //     color: textPrimary,
              //     letterSpacing: 0.2,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // TextField(
              //   controller: _lotCtrl,
              //   readOnly: true,
              //   style: const TextStyle(
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //     color: textPrimary,
              //   ),
              //   decoration: InputDecoration(
              //     hintText: "Enter lot number",
              //     hintStyle: TextStyle(
              //       color: textSecondary.withOpacity(0.5),
              //       fontWeight: FontWeight.w400,
              //     ),
              //     filled: true,
              //     fillColor: background,
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //     disabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // // Batch Number
              // const Text(
              //   "Batch Number",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //     color: textPrimary,
              //     letterSpacing: 0.2,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // TextField(
              //   controller: _batchCtrl,
              //   readOnly: true,
              //   style: const TextStyle(
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //     color: textPrimary,
              //   ),
              //   decoration: InputDecoration(
              //     hintText: "Enter batch number",
              //     hintStyle: TextStyle(
              //       color: textSecondary.withOpacity(0.5),
              //       fontWeight: FontWeight.w400,
              //     ),
              //     filled: true,
              //     fillColor: background,
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //     disabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(14),
              //       borderSide: const BorderSide(color: borderColor, width: 1.5),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // Sequence Number
              Text(
                "Seq No",
                style: GRNConstants.sectionTitleStyle,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tag_rounded,
                        color: GRNConstants.primaryBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _seqText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pack Size
              Row(
                children: [
                  Text(
                    "Pack Size",
                    style: GRNConstants.sectionTitleStyle,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showPackSizeEditDialog(),
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: GRNConstants.primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _packSizeCtrl.text.isEmpty
                              ? "Not set"
                              : _packSizeCtrl.text,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _packSizeCtrl.text.isEmpty
                                ? textSecondary.withValues(alpha: 0.5)
                                : textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_rounded,
                        color: GRNConstants.primaryBlue,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Printer Status
              _ModernCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _printerConnected
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.print_rounded,
                        color: _printerConnected
                            ? const Color.fromARGB(255, 12, 104, 73)
                            : errorRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Printer Status",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _printerConnected ? "Connected" : "Disconnected",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _printerConnected
                                  ? const Color.fromARGB(255, 12, 104, 73)
                                  : errorRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_history.length} items in history",
                            style: const TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _printerConnected,
                      onChanged: (v) => setState(() => _printerConnected = v),
                      activeColor: GRNConstants.primaryBlue,
                      activeTrackColor: lightBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Final Save Button (only show if there's history)
                if (_history.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _onCompleteSave,
                      icon: const Icon(Icons.check_circle_rounded, size: 22),
                      label: Text(
                        "Final Save (${_history.length} scanned)",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: successGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Print Barcode Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _printerConnected ? onPrint : null,
                    icon: const Icon(Icons.print_rounded, size: 22),
                    label: const Text(
                      "Print Barcode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: GRNConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: borderColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Reprint from History Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: (_history.isEmpty) ? null : openReprintPicker,
                    icon: const Icon(Icons.history_rounded, size: 22),
                    label: const Text(
                      "Reprint from History",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GRNConstants.primaryBlue,
                      side: const BorderSide(
                          color: GRNConstants.primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Card Widget
class _ModernCard extends StatelessWidget {
  final Widget child;
  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _BarcodePrintDetailsPageState.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _BarcodePrintDetailsPageState.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

// Label Preview Box
class _LabelPreviewBox extends StatelessWidget {
  final String text;
  const _LabelPreviewBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _BarcodePrintDetailsPageState.lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GRNConstants.primaryBlue.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: GRNConstants.primaryBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
