import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ---------------------------------------------------------------------------
/// THEME TOKENS (HIGH-CONTRAST DARK THEME + NEON GREEN ACCENTS)
/// ---------------------------------------------------------------------------
class AppDarkColors {
  static const Color background = Color(0xFF0A0F1D);       // Deep Navy/Black
  static const Color cardSurface = Color(0xFF161F30);      // Elevated Dark Slate
  static const Color cardSurfaceInner = Color(0xFF0F1623); // Inner Input Fill
  static const Color primaryNeon = Color(0xFF00E676);       // Bright Neon Green
  static const Color primaryNeonDark = Color(0xFF00C853);
  static const Color accentCyan = Color(0xFF00F5D4);        // Bright Teal
  static const Color textLight = Color(0xFFFFFFFF);        // Crisp White
  static const Color textMuted = Color(0xFF94A3B8);        // Slate Gray
  static const Color borderStroke = Color(0xFF25334D);      // Subtle Border
  static const Color errorRed = Color(0xFFFF5252);
}

/// ---------------------------------------------------------------------------
/// SCREEN 1: LOGIN SCREEN (LINEAR BLINKIT-STYLE MOBILE-ONLY VIEW)
/// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  final VoidCallback? onProceedToOtp;

  const LoginScreen({super.key, this.onProceedToOtp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '9876543210');
  bool _isHindi = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.onProceedToOtp != null) {
        widget.onProceedToOtp!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppDarkColors.primaryNeon,
            content: Text(
              _isHindi
                  ? 'ओटीपी मोबाइल नंबर +91 ${_phoneController.text} पर भेजा जा रहा है...'
                  : 'Dispatching OTP to +91 ${_phoneController.text}...',
              style: const TextStyle(
                color: Color(0xFF0A0F1D),
                fontWeight: FontWeight.w900,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDarkColors.background,
      appBar: AppBar(
        backgroundColor: AppDarkColors.cardSurface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppDarkColors.primaryNeon.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppDarkColors.primaryNeon, width: 1.5),
              ),
              child: const Icon(
                Icons.agriculture,
                color: AppDarkColors.primaryNeon,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KISAN SETU',
                  style: TextStyle(
                    color: AppDarkColors.primaryNeon,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _isHindi ? 'चरण 1 / 8: पंजीकरण' : 'Step 1 of 8: Registration',
                  style: const TextStyle(
                    color: AppDarkColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher Toggle
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16, color: AppDarkColors.primaryNeon),
              label: Text(
                _isHindi ? 'English' : 'हिन्दी',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppDarkColors.primaryNeon,
                ),
              ),
              backgroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: AppDarkColors.primaryNeon, width: 1.2),
              onPressed: () {
                setState(() {
                  _isHindi = !_isHindi;
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content Area (Centered Card Layout)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Top Glowing Hero Emblem
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppDarkColors.cardSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppDarkColors.primaryNeon, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppDarkColors.primaryNeon.withOpacity(0.3),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: AppDarkColors.primaryNeon,
                            size: 42,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Main Titles
                      Text(
                        _isHindi ? 'किसान लॉगिन' : 'Farmer Login',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppDarkColors.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isHindi
                            ? 'मंडी टोकन और भुगतान के लिए 10 अंकों का मोबाइल नंबर दर्ज करें'
                            : 'Enter your registered 10-digit mobile number',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppDarkColors.textMuted,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Centered Dark Input Card (Completely replacing white empty space)
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppDarkColors.cardSurface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppDarkColors.borderStroke, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  color: AppDarkColors.primaryNeon,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isHindi ? 'मोबाइल नंबर दर्ज करें' : 'MOBILE NUMBER',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: AppDarkColors.primaryNeon,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Mobile Number Input Box with Flag & Prefix
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: AppDarkColors.primaryNeon,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '98765 43210',
                                hintStyle: TextStyle(
                                  color: AppDarkColors.textMuted.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: AppDarkColors.borderStroke, width: 1.5),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                      SizedBox(width: 6),
                                      Text(
                                        '+91',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: AppDarkColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                filled: true,
                                fillColor: AppDarkColors.cardSurfaceInner,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: AppDarkColors.borderStroke, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: AppDarkColors.primaryNeon, width: 2.2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: AppDarkColors.errorRed, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length != 10) {
                                  return _isHindi
                                      ? 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें'
                                      : 'Enter valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Security Reassurance Note
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppDarkColors.cardSurfaceInner,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppDarkColors.borderStroke),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user,
                                    size: 18,
                                    color: AppDarkColors.primaryNeon,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _isHindi
                                          ? 'सुरक्षित प्रमाणीकरण के लिए 6 अंकों का ओटीपी एसएमएस भेजा जाएगा।'
                                          : 'A 6-digit OTP will be dispatched via SMS for fast login.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppDarkColors.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Government DBT Platform Assurance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield, color: AppDarkColors.primaryNeon, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _isHindi
                                ? 'सरकारी एमएसपी एवं डीबीटी सुरक्षित पोर्टल'
                                : 'Government DBT & Mandi Secured Platform',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppDarkColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Giant Primary Sticky Bottom Button (Blinkit-Style Linear Progression)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppDarkColors.cardSurface,
                border: Border(
                  top: BorderSide(color: AppDarkColors.borderStroke, width: 1.5),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDarkColors.primaryNeon,
                    foregroundColor: const Color(0xFF0A0F1D),
                    elevation: 6,
                    shadowColor: AppDarkColors.primaryNeon.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isHindi
                            ? 'ओटीपी सत्यापन के लिए आगे बढ़ें'
                            : 'PROCEED TO OTP VERIFICATION',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 24, weight: 800),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
