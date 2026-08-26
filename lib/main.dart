import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_storage.dart';
import 'package:mandalar_x/features/splash/presentation/splash_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

const String oneSignalAppId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await Supabase.initialize(
    url: '',
    anonKey:
        '',
  );

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    OneSignal.Notifications.requestPermission(false);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(oneSignalAppId);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null &&
          (data.event == AuthChangeEvent.initialSession ||
              data.event == AuthChangeEvent.signedIn)) {
        saveOneSignalIdAfterLogin();
      }
    });

    final permissionGranted = await OneSignal.Notifications.requestPermission(
      true,
    );

    debugPrint('Notification permission granted: $permissionGranted');
  }

  AppStorage.init();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> saveOneSignalIdAfterLogin() async {
  if (kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS)) {
    return;
  }

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    debugPrint('No logged-in user');
    return;
  }

  final oneSignalId = await OneSignal.User.getOnesignalId();
  if (oneSignalId == null) {
    debugPrint('OneSignal ID not ready yet');
    return;
  }

  await OneSignal.login(user.id);

  await Supabase.instance.client.from('user_devices').upsert({
    'user_id': user.id,
    'player_id': oneSignalId,
    'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    'updated_at': DateTime.now().toIso8601String(),
  });

  debugPrint('OneSignal ID saved: $oneSignalId');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Mandalay',
      home: RootWrapper(),
    );
  }
}

class RootWrapper extends StatefulWidget {
  const RootWrapper({super.key});

  @override
  State<RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends State<RootWrapper> {
  DateTime? _lastBackPressed;
  static const _exitTimeout = Duration(seconds: 2);

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > _exitTimeout) {
      _lastBackPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit the app'),
          duration: _exitTimeout,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(onWillPop: _onWillPop, child: SplashPage());
  }
}
