import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mandalar_x/features/wrapper/wrapper_page.dart';

class OrderFlowDemoPage extends StatefulWidget {
  final int initialStep;
  const OrderFlowDemoPage({super.key, this.initialStep = 0});

  @override
  State<OrderFlowDemoPage> createState() => _OrderFlowDemoPageState();
}

class _OrderFlowDemoPageState extends State<OrderFlowDemoPage>
    with TickerProviderStateMixin {
  final List<String> stages = ["Processing", "Preparing", "Rider", "Delivered"];
  int currentStage = 0;
  late Timer timer;

  // Animation controllers
  late AnimationController processingController;
  late AnimationController preparingController;
  late AnimationController riderController;
  late AnimationController deliveredController;

  @override
  void initState() {
    super.initState();
    currentStage = widget.initialStep;

    // Initialize controllers
    processingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    preparingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    riderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    deliveredController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Start stage progression
    Future.delayed(const Duration(milliseconds: 500), startStageTimer);
  }

  void startStageTimer() {
    timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (currentStage < stages.length - 1) {
        setState(() {
          currentStage++;
        });

        // Trigger stage-specific animation
        if (currentStage == 1) {
          preparingController.repeat(reverse: true);
        } else if (currentStage == 2) {
          riderController.repeat();
        } else if (currentStage == 3) {
          deliveredController.forward();
          Future.delayed(const Duration(milliseconds: 500), () {
            Fluttertoast.showToast(
              msg: "Order Delivered Successfully!",
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16,
            );

            Future.delayed(const Duration(seconds: 3), () {
              // Navigate to WrapperPage and remove all previous routes
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const WrapperPage(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
                (route) => false, // This removes all previous routes
              );
            });
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Rest of your code remains the same...
  @override
  void dispose() {
    timer.cancel();
    processingController.dispose();
    preparingController.dispose();
    riderController.dispose();
    deliveredController.dispose();
    super.dispose();
  }

  Widget buildStep(int index) {
    bool isActive = index <= currentStage;

    Widget child;
    switch (index) {
      case 0: // Processing - spinning loader
        child = RotationTransition(
          turns: processingController,
          child: const Icon(
            Icons.hourglass_bottom,
            color: Colors.white,
            size: 28,
          ),
        );
        break;
      case 1: // Preparing - bouncing pan
        child = AnimatedBuilder(
          animation: preparingController,
          builder: (context, _) {
            double bounce = (preparingController.value - 0.5).abs() * 10;
            return Transform.translate(
              offset: Offset(0, -bounce),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 28,
              ),
            );
          },
        );
        break;
      case 2: // Rider - moving motorcycle
        child = AnimatedBuilder(
          animation: riderController,
          builder: (context, _) {
            double move = riderController.value * 20;
            return Transform.translate(
              offset: Offset(move, 0),
              child: const Icon(
                Icons.motorcycle,
                color: Colors.white,
                size: 28,
              ),
            );
          },
        );
        break;
      case 3: // Delivered - checkmark animation
        child = ScaleTransition(
          scale: deliveredController,
          child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        );
        break;
      default:
        child = const Icon(Icons.help, color: Colors.white, size: 28);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          // ignore: deprecated_member_use
          backgroundColor: isActive ? Colors.red : Colors.grey.withOpacity(0.3),
          child: child,
        ),
        const SizedBox(height: 6),
        Text(
          stages[index],
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget buildConnector(int index) {
    bool isActive = currentStage > index;
    return Expanded(
      child: Container(
        height: 4,
        color: isActive ? Colors.red : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Tracker
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(stages.length * 2 - 1, (index) {
                  if (index.isEven) {
                    return buildStep(index ~/ 2);
                  } else {
                    return buildConnector(index ~/ 2);
                  }
                }),
              ),
              const SizedBox(height: 80),
              // Big animation center (optional for extra focus)
              SizedBox(
                height: 180,
                child: Center(child: buildStep(currentStage)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}