import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/home/presentation/mobile/pages/home_page_mobile.dart';
import 'package:mandalar_x/features/home/presentation/tablet/home_page_tablet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _updater = ShorebirdUpdater();
  Timer? _timer;
  bool _showUpdateBanner = false;

  @override
  void initState() {
    super.initState();
    _startUpdateChecker();
  }

  void _startUpdateChecker() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    if (!kReleaseMode) return;
    
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update();
        if (mounted) {
          setState(() => _showUpdateBanner = true);
        }
      }
    } catch (e) {
      debugPrint('Shorebird update failed: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartApp() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_showUpdateBanner) {
      return Scaffold(
        body: Container(
          color: Colors.orange,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.system_update, size: 64, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  '🆕 Mandalar X Update!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'New version downloaded. Restart to update your food delivery app.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: _restartApp,
                  child: const Text('Restart App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppResponsive(
      mobile: HomePageMobile(),
      tablet: HomePageTablet(),
      desktop: HomePageTablet(),
    );
  }
}
