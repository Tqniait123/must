import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:must_invest/core/services/debug_logger.dart';



class DebugFloatingButton extends StatefulWidget {
  final Widget child;
  final bool showInRelease;

  const DebugFloatingButton({Key? key, required this.child, this.showInRelease = false}) : super(key: key);

  @override
  State<DebugFloatingButton> createState() => _DebugFloatingButtonState();
}

class _DebugFloatingButtonState extends State<DebugFloatingButton> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize debug logger
    DebugLogger.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode unless explicitly allowed in release
    if (!widget.showInRelease && !_isDebugMode()) {
      return widget.child;
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ..._buildExpandedButtons(),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "debug_main",
            mini: true,
            backgroundColor: Colors.red.shade600,
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Icon(_isExpanded ? Icons.close : Icons.bug_report, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandedButtons() {
    return [
      // Share Logs Button
      FloatingActionButton(
        heroTag: "debug_share",
        mini: true,
        backgroundColor: Colors.blue.shade600,
        onPressed: _shareLogs,
        child: const Icon(Icons.share, color: Colors.white, size: 16),
      ),
      const SizedBox(height: 8),

      // View Logs Button
      FloatingActionButton(
        heroTag: "debug_view",
        mini: true,
        backgroundColor: Colors.green.shade600,
        onPressed: _viewLogs,
        child: const Icon(Icons.visibility, color: Colors.white, size: 16),
      ),
      const SizedBox(height: 8),

      // Clear Logs Button
      FloatingActionButton(
        heroTag: "debug_clear",
        mini: true,
        backgroundColor: Colors.orange.shade600,
        onPressed: _clearLogs,
        child: const Icon(Icons.clear_all, color: Colors.white, size: 16),
      ),
      const SizedBox(height: 8),

      // Test Biometric Button
      FloatingActionButton(
        heroTag: "debug_test",
        mini: true,
        backgroundColor: Colors.purple.shade600,
        onPressed: _testBiometric,
        child: const Icon(Icons.fingerprint, color: Colors.white, size: 16),
      ),
    ];
  }

  Future<void> _shareLogs() async {
    try {
      await DebugLogger.instance.log('DebugFloatingButton', 'User requested to share logs');
      await DebugLogger.instance.shareLogs();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logs shared successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      await DebugLogger.instance.logError('DebugFloatingButton', 'Failed to share logs', e, null);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share logs: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _viewLogs() async {
    try {
      await DebugLogger.instance.log('DebugFloatingButton', 'User requested to view logs');

      final logs = await DebugLogger.instance.getLogsContent();

      if (mounted) {
        showDialog(context: context, builder: (context) => _LogViewerDialog(logs: logs));
      }
    } catch (e) {
      await DebugLogger.instance.logError('DebugFloatingButton', 'Failed to view logs', e, null);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to view logs: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _clearLogs() async {
    try {
      await DebugLogger.instance.log('DebugFloatingButton', 'User requested to clear logs');

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Clear Logs'),
              content: const Text('Are you sure you want to clear all debug logs?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
              ],
            ),
      );

      if (confirm == true) {
        await DebugLogger.instance.clearLogs();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Logs cleared successfully'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      await DebugLogger.instance.logError('DebugFloatingButton', 'Failed to clear logs', e, null);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to clear logs: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _testBiometric() async {
    try {
      await DebugLogger.instance.log('DebugFloatingButton', 'User requested biometric test');

      // Show test options dialog
      showDialog(context: context, builder: (context) => _BiometricTestDialog());
    } catch (e) {
      await DebugLogger.instance.logError('DebugFloatingButton', 'Failed to show biometric test', e, null);
    }
  }
}

class _LogViewerDialog extends StatefulWidget {
  final String logs;

  const _LogViewerDialog({required this.logs});

  @override
  State<_LogViewerDialog> createState() => _LogViewerDialogState();
}

class _LogViewerDialogState extends State<_LogViewerDialog> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Debug Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.logs));
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Logs copied to clipboard')));
                      },
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    widget.logs.isEmpty ? 'No logs available' : widget.logs,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.vertical_align_top),
                  label: const Text('Top'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.vertical_align_bottom),
                  label: const Text('Bottom'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BiometricTestDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Biometric Test'),
      content: const Text('Choose a biometric test to run:'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _runBiometricStatusTest();
          },
          child: const Text('Status Test'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _runBiometricAuthTest();
          },
          child: const Text('Auth Test'),
        ),
      ],
    );
  }

  Future<void> _runBiometricStatusTest() async {
    try {
      await DebugLogger.instance.log('BiometricTest', 'Starting biometric status test');

      // Import your biometric service here
      // final biometricService = BiometricService2();
      // final status = await biometricService.checkBiometricStatus();

      await DebugLogger.instance.log('BiometricTest', 'Biometric status test completed');
    } catch (e) {
      await DebugLogger.instance.logError('BiometricTest', 'Biometric status test failed', e, null);
    }
  }

  Future<void> _runBiometricAuthTest() async {
    try {
      await DebugLogger.instance.log('BiometricTest', 'Starting biometric auth test');

      // Import your biometric service here
      // final biometricService = BiometricService2();
      // final result = await biometricService.authenticateWithBiometrics(
      //   localizedReason: 'Debug test authentication'
      // );

      await DebugLogger.instance.log('BiometricTest', 'Biometric auth test completed');
    } catch (e) {
      await DebugLogger.instance.logError('BiometricTest', 'Biometric auth test failed', e, null);
    }
  }
}
