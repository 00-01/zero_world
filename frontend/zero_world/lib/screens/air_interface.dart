import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Air Interface - The breathing UI
/// 
/// Philosophy: UI as natural as breathing
/// - Invisible by default
/// - Appears on demand (hotkey/gesture/voice)
/// - Breathing animations
/// - Auto-dismisses after use
///
/// Design Philosophy (Brightness = Importance):
/// - Brighter colors (#FFFFFF) = More important
/// - Darker colors (#000000) = Less important
/// - Background: #000000 (pure black)
/// - Chat bubble: #FFFFFF (pure white) - MOST IMPORTANT
/// - Text in chat bubble: #000000 (pure black) - High contrast
/// - Input field: Dark gray (#1A1A1A) - Less important
/// - Icons/hints: Medium gray (#666666) - Least important
class AirInterface extends StatefulWidget {
  const AirInterface({super.key});

  @override
  State<AirInterface> createState() => _AirInterfaceState();
}

class _AirInterfaceState extends State<AirInterface>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isVisible = false;
  bool _isProcessing = false;
  String? _result;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation controller (4 seconds cycle)
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Listen for global hotkey (Cmd/Ctrl + Space)
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _queryController.dispose();
    _focusNode.dispose();
    _autoDismissTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Cmd/Ctrl + Space to summon
      if (event.logicalKey == LogicalKeyboardKey.space &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        _summon();
        return true;
      }
      // Escape to dismiss
      if (event.logicalKey == LogicalKeyboardKey.escape && _isVisible) {
        _dismiss();
        return true;
      }
    }
    return false;
  }

  void _summon() {
    setState(() {
      _isVisible = true;
      _result = null;
    });
    
    // Inhale animation
    _breathController.forward();
    
    // Focus on input
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _dismiss() {
    // Exhale animation
    _breathController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _queryController.clear();
          _result = null;
        });
      }
    });
  }

  Future<void> _handleQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    // Breathing animation while processing
    _breathController.repeat(reverse: true);

    try {
      // TODO: Call AI Mediator service
      // For now, simulate response
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _result = _generateMockResponse(query);
        _isProcessing = false;
      });

      // Stop breathing
      _breathController.stop();
      _breathController.value = 1.0;

      // Auto-dismiss after 5 seconds
      _autoDismissTimer?.cancel();
      _autoDismissTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _result != null) {
          _dismiss();
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error: Unable to process query';
        _isProcessing = false;
      });
      _breathController.stop();
    }
  }

  String _generateMockResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('weather')) {
      return '🌤️ Current weather: 22°C, Sunny\nTokyo, Japan\nFeels like 21°C • Humidity: 45%';
    } else if (lowerQuery.contains('time')) {
      return '🕐 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}\n${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    } else if (lowerQuery.contains('data') || lowerQuery.contains('search')) {
      return '🔍 Found 1,245 results across:\n• Google: 850 results\n• Wikipedia: 145 articles\n• Academic: 250 papers\n\nTop result: Data access patterns...';
    } else {
      return '💡 I found information about "$query"\n\nSources: Wikipedia, Google, Academic papers\nConfidence: 95%\n\n[View detailed results]';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        color: const Color(0xFF000000), // Pure black background - RULE: #000000
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent dismissing when tapping content
            child: AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_breathController.value * 0.2),
                  child: Opacity(
                    opacity: _breathController.value,
                    child: child,
                  ),
                );
              },
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: 600,
      constraints: BoxConstraints(
        maxHeight: _result != null ? 400 : 80,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputField(),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark gray - less important than result
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isProcessing
              ? const Color(0xFF666666) // Medium gray when processing
              : const Color(0xFF333333), // Dark gray border
          width: _isProcessing ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.air,
            color: Color(0xFF666666), // Medium gray - less important
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _queryController,
              focusNode: _focusNode,
              enabled: !_isProcessing,
              style: const TextStyle(
                color: Color(0xFFCCCCCC), // Light gray text - readable but not prominent
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Ask anything... (Cmd+Space)',
                hintStyle: TextStyle(
                  color: Color(0xFF555555), // Dark gray hint - less important
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: _handleQuery,
            ),
          ),
          if (_isProcessing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFF666666), // Medium gray
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.mic,
                color: Color(0xFF666666), // Medium gray - less important
              ),
              onPressed: () {
                // TODO: Implement voice input
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice input coming soon...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Voice input',
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Pure white - MOST IMPORTANT (chat bubble)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEEEEEE), // Very light gray border
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _result ?? '',
                  style: const TextStyle(
                    color: Color(0xFF000000), // Pure black text in white bubble - RULE
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF666666), // Medium gray - less important
                  size: 20,
                ),
                onPressed: _dismiss,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _result ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {
                  // TODO: Implement share
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.open_in_new,
                label: 'Details',
                onPressed: () {
                  // TODO: Show detailed view
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF666666), // Medium gray - less important than main content
        side: const BorderSide(
          color: Color(0xFFCCCCCC), // Light gray border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Floating Action Button to summon Air Interface
class AirSummonButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AirSummonButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: const Color(0xFF333333), // Dark gray - less important
        icon: const Icon(Icons.air, color: Color(0xFFCCCCCC)), // Light gray icon
        label: const Text(
          'Cmd+Space',
          style: TextStyle(
            color: Color(0xFFCCCCCC), // Light gray text
            fontWeight: FontWeight.w300,
          ),
        ),
        elevation: 8,
      ),
    );
  }
}
