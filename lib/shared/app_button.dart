import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_fonts.dart';

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color labelColor;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.labelColor,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int activeDot = (_animation.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedOpacity(
                opacity: i <= activeDot ? 1 : 0.2,
                duration: const Duration(milliseconds: 250),
                child: Text('.', style: AppFontStyle.subtitle.copyWith(color: Colors.white)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        disabledBackgroundColor: widget.backgroundColor,
        foregroundColor: widget.labelColor,
        textStyle: TextStyle(
          fontFamily: "Poppins",
          fontSize: AppFonts.body,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: widget.isLoading ? null : widget.onTap,
      child: widget.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loading', style: AppFontStyle.subtitle.copyWith(
                   color: AppColors.appBackground
                )),
                _buildAnimatedDots(widget.labelColor),
              ],
            )
          : Text(widget.title, style: AppFontStyle.subtitle),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_fonts.dart';

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color labelColor;
  final bool isLoading;
  final LoadingStyle loadingStyle; // Add this enum

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.labelColor,
    this.isLoading = false,
    this.loadingStyle = LoadingStyle.cooking, // Default style
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

// Define different loading styles
enum LoadingStyle {
  cooking,
  delivering,
  processing,
  preparing,
  custom,
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<String> _loadingMessages;
  int _messageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Initialize loading messages based on style
    _loadingMessages = _getLoadingMessages(widget.loadingStyle);
    
    // Start cycling through messages
    if (widget.isLoading) {
      _startMessageCycle();
    }
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !oldWidget.isLoading) {
      // Loading started
      _loadingMessages = _getLoadingMessages(widget.loadingStyle);
      _messageIndex = 0;
      _startMessageCycle();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      // Loading stopped
      _stopMessageCycle();
    } else if (widget.loadingStyle != oldWidget.loadingStyle && widget.isLoading) {
      // Loading style changed
      _loadingMessages = _getLoadingMessages(widget.loadingStyle);
      _messageIndex = 0;
    }
  }

  List<String> _getLoadingMessages(LoadingStyle style) {
    switch (style) {
      case LoadingStyle.cooking:
        return [
          'Spicing things up 🌶️',
          'Chopping veggies 🥕',
          'Sizzling in the pan 🔥',
          'Adding secret sauce 🤫',
          'Almost ready! 🍽️'
        ];
      case LoadingStyle.delivering:
        return [
          'Finding fastest route 🗺️',
          'Rider on the way 🏍️',
          'Navigating traffic 🚦',
          'Almost at your door 🚪',
          'Delivery incoming! 📦'
        ];
      case LoadingStyle.processing:
        return [
          'Processing order ⚡',
          'Confirming details 📝',
          'Getting everything ready 🛒',
          'Finalizing your order ✅',
          'Almost done! ✨'
        ];
      case LoadingStyle.preparing:
        return [
          'Preparing your feast 👨‍🍳',
          'Mixing ingredients 🥣',
          'Heating things up 🔥',
          'Adding finishing touches ✨',
          'Packaging with care 🎁'
        ];
      case LoadingStyle.custom:
        return ['Loading...'];
    }
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  void _stopMessageCycle() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopMessageCycle();
    super.dispose();
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int activeDot = (_animation.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedOpacity(
                opacity: i <= activeDot ? 1 : 0.2,
                duration: const Duration(milliseconds: 250),
                child: Text('.', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        disabledBackgroundColor: widget.backgroundColor,
        foregroundColor: widget.labelColor,
        textStyle: TextStyle(
          fontFamily: "Poppins",
          fontSize: AppFonts.body,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: widget.isLoading ? null : widget.onTap,
      child: widget.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadingMessages[_messageIndex],
                  style: AppFontStyle.subtitle.copyWith(
                    color: widget.labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                _buildAnimatedDots(widget.labelColor),
              ],
            )
          : Text(widget.title, style: AppFontStyle.subtitle),
    );
  }
}

*/