import 'package:flutter/material.dart';
import '../GRN/constants/grn_constants.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String? currentLot;
  final String? currentBatch;
  final int? currentSeq;
  final String? currentPackSize;

  const BarcodeScannerPage({
    super.key,
    this.currentLot,
    this.currentBatch,
    this.currentSeq,
    this.currentPackSize,
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  // Modern color palette - solid colors only

  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);

  bool _isScanning = false;
  bool _flashOn = false;
  String? _scannedCode;
  final List<String> _scanHistory = [];

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _onBarcodeScanned(String code) {
    setState(() {
      _scannedCode = code;
      _scanHistory.insert(0, code);
      _isScanning = false;
    });

    // Validate barcode format: LOT | BATCH | SEQ | PACKSIZE
    final parts = code.split('|').map((e) => e.trim()).toList();
    
    if (parts.length == 4) {
      // Valid barcode format
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✓ Valid barcode scanned: $code"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate back with scanned data after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, {
            'lot': parts[0],
            'batch': parts[1],
            'seq': parts[2],
            'packSize': parts[3],
            'isValid': true,
          });
        }
      });
    } else {
      // Invalid barcode format
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠ Invalid barcode format"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: warningYellow,
        ),
      );
    }
  }

  void _simulateScan() {
    // Simulate scanning with actual current values
    final lot = widget.currentLot ?? "LOT2024001";
    final batch = widget.currentBatch ?? "BATCH456";
    final seq = (widget.currentSeq ?? 1).toString().padLeft(4, '0');
    final packSize = widget.currentPackSize ?? "100pcs";
    
    final demoCode = "$lot | $batch | $seq | $packSize";
    _onBarcodeScanned(demoCode);
  }

  void _clearHistory() {
    setState(() {
      _scanHistory.clear();
      _scannedCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: GRNConstants.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          "Scan code",
           style: GRNConstants.headerStyle,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: _scanHistory.isEmpty ? null : _showHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Camera View (Simulated)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: _isScanning
                        ? _buildScanningOverlay()
                        : _buildIdleState(),
                  ),
                ),

                // Flash Toggle Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: _buildFlashButton(),
                ),

                // Scan Frame
                if (_isScanning) _buildScanFrame(),
              ],
            ),
          ),

          // Bottom Information Panel
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _buildBottomPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated scanning indicator
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          builder: (context, double value, child) {
            return Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: GRNConstants.primaryBlue.withOpacity(0.5),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Scanning line
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 240 * value - 2,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: GRNConstants.primaryBlue,
                        boxShadow: [
                          BoxShadow(
                            color: GRNConstants.primaryBlue.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          onEnd: () {
            if (_isScanning) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 24),
        const Text(
          "Align barcode within frame",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Scanning...",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GRNConstants.primaryBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.qr_code_scanner_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Barcode or QR code",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
       
      ],
    );
  }

  Widget _buildScanFrame() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: GRNConstants.primaryBlue,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Corner indicators
            _buildCornerIndicator(Alignment.topLeft),
            _buildCornerIndicator(Alignment.topRight),
            _buildCornerIndicator(Alignment.bottomLeft),
            _buildCornerIndicator(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleFlash,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _flashOn ? warningYellow : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Last Scanned Result
          if (_scannedCode != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: GRNConstants.primaryBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: GRNConstants.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Last Scanned",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _scannedCode!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Copy to clipboard functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("✓ Copied to clipboard"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: successGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        color: GRNConstants.primaryBlue,
                        tooltip: "Copy",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Scan Statistics
          Row(
            children: [
            
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time_rounded,
                  label: "Status",
                  value: _isScanning ? "Active" : "Ready",
                  valueColor: _isScanning ? successGreen : textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scan Button
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isScanning ? _simulateScan : _toggleScanning,
              icon: Icon(
                _isScanning ? Icons.stop_rounded : Icons.qr_code_scanner_rounded,
                size: 24,
              ),
              label: Text(
                _isScanning ? "Stop Scanning" : "Start Scanning",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _isScanning ? errorRed : GRNConstants.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (_isScanning) ...[
            const SizedBox(height: 12),
            // Demo: Simulate scan button (remove in production)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _simulateScan,
                icon: const Icon(Icons.camera_rounded, size: 20),
                label: const Text(
                  "Simulate Scan (Demo)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textSecondary,
                  side: const BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],

          if (_scanHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                "Clear History",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: errorRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GRNConstants.primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
                      "Scan History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${_scanHistory.length} items",
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // History List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scanHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    return Container(
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: GRNConstants.primaryBlue,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _scanHistory[i],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "Scan #${_scanHistory.length - i}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: GRNConstants.primaryBlue,
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("✓ Copied to clipboard"),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: successGreen,
                              ),
                            );
                          },
                        ),
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

  static const Color errorRed = Color(0xFFEF4444);
}