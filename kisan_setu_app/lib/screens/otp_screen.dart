import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../state/app_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Default mock OTP
    const mockCode = '123456';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = mockCode[i];
    }
  }

  void _startTimer() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      AppState().login();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full 6-digit OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Kisan Setu',
        showBackButton: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open,
                    size: 40,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Subtitle
                Text(
                  'Verify OTP',
                  style: AppTypography.headlineLarge(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'We have sent an OTP to',
                  style: AppTypography.bodyLarge(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  '+91 ${AppState().userMobile}',
                  style: AppTypography.headlineSmall(color: AppColors.onSurface),
                ),
                const SizedBox(height: 32),

                // 6-digit boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTypography.headlineLarge(color: AppColors.primary),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.outline, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.secondaryContainer, width: 2.5),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Resend timer
                Text(
                  "Didn't receive the code?",
                  style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _countdown == 0 ? _startTimer : null,
                  child: Text(
                    _countdown > 0
                        ? 'Resend OTP (00:${_countdown.toString().padLeft(2, '0')})'
                        : 'Resend OTP / पुनः भेजें',
                    style: AppTypography.labelLarge(
                      color: _countdown == 0 ? AppColors.primary : AppColors.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Verify Button
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify & Login / पुष्टि करें',
                        style: AppTypography.labelLarge(color: AppColors.onPrimaryContainer),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/onboarding/aadhaar'),
                  child: Text(
                    'First time? Setup Aadhaar & DBT / पहली बार? आधार जोड़ें',
                    style: AppTypography.labelMedium(color: AppColors.primary),
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
