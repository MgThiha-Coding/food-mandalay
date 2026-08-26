import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ===============================
// NOTIFIER
// ===============================

final phoneVerificationNotifierProvider =
    NotifierProvider<PhoneVerificationNotifier, PhoneVerificationState>(
      PhoneVerificationNotifier.new,
    );

class PhoneVerificationState {
  final bool isVerified;
  final bool isLoading;
  final String? phone;
  final String? requestId;

  PhoneVerificationState({
    this.isVerified = false,
    this.isLoading = false,
    this.phone,
    this.requestId,
  });

  PhoneVerificationState copyWith({
    bool? isVerified,
    bool? isLoading,
    String? phone,
    String? requestId,
  }) {
    return PhoneVerificationState(
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      requestId: requestId ?? this.requestId,
    );
  }
}

class PhoneVerificationNotifier extends Notifier<PhoneVerificationState> {
  @override
  PhoneVerificationState build() => PhoneVerificationState();

  /// Submit phone number to send OTP
  Future<void> submitPhone(String phone) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://rzwmsfmpgndploztjudb.supabase.co/functions/v1/send-otp',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          phone: phone,
          requestId: data['requestId'],
          isLoading: false,
        );
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to send OTP';
     
        state = state.copyWith(isLoading: false);
        throw Exception(error);
      }
    } catch (e) {
   
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Verify OTP
  Future<void> verifyOtp(String otp) async {
    if (state.requestId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://rzwmsfmpgndploztjudb.supabase.co/functions/v1/verify-otp',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'requestId': state.requestId, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isVerified: true, isLoading: false);
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'OTP verification failed';
        state = state.copyWith(isLoading: false);
        throw Exception(error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void reset() {
    state = PhoneVerificationState();
  }
}

// ===============================
// VERIFY PHONE PAGE
// ===============================

class VerifyPhoneNumber extends ConsumerStatefulWidget {
  final String initialPhone;
  const VerifyPhoneNumber({super.key, required this.initialPhone});

  @override
  ConsumerState<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends ConsumerState<VerifyPhoneNumber> {
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.initialPhone);
  }

  Future<void> _submitPhone() async {
    try {
      await ref
          .read(phoneVerificationNotifierProvider.notifier)
          .submitPhone(phoneController.text.trim());

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const VerifyOtpPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneVerificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Phone")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('Verify your phone number'),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: "09xxxxxxxx"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submitPhone,
              child: Text(state.isLoading ? "Sending..." : "Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// VERIFY OTP PAGE
// ===============================

class VerifyOtpPage extends ConsumerStatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final TextEditingController otpController = TextEditingController();

  Future<void> _verifyOtp() async {
    try {
      await ref
          .read(phoneVerificationNotifierProvider.notifier)
          .verifyOtp(otpController.text.trim());

      // Navigate to Place Order page if verified
      final state = ref.read(phoneVerificationNotifierProvider);
      if (state.isVerified) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const PlaceOrderPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneVerificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter OTP"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isLoading ? null : _verifyOtp,
              child: Text(state.isLoading ? "Verifying..." : "Verify"),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// PLACE ORDER PAGE
// ===============================

class PlaceOrderPage extends StatelessWidget {
  const PlaceOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Place Order")),
      body: const Center(
        child: Text("OTP Verified! Now you can place your order."),
      ),
    );
  }
}
