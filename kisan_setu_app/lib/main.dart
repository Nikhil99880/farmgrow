import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/link_aadhaar_screen.dart';
import 'screens/bank_dbt_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/nearby_mandis_screen.dart';
import 'screens/smart_slot_booking_screen.dart';
import 'screens/gate_qr_token_screen.dart';
import 'screens/live_queue_tracker_screen.dart';
import 'screens/quality_weighing_screen.dart';
import 'screens/my_payments_screen.dart';
import 'screens/kisan_suvidha_screen.dart';
import 'screens/help_center_screen.dart';

void main() {
  runApp(const KisanSetuMasterApp());
}

class KisanSetuMasterApp extends StatelessWidget {
  const KisanSetuMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisan Setu | किसान सेतु',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFF57F17),
          surface: const Color(0xFFF9FBF9),
        ),
      ),
      home: const MasterAppNavigator(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// MASTER APP NAVIGATOR (LINEAR 13-SCREEN FLOW & DIRECT SWITCHER)
/// ---------------------------------------------------------------------------
class MasterAppNavigator extends StatefulWidget {
  const MasterAppNavigator({super.key});

  @override
  State<MasterAppNavigator> createState() => _MasterAppNavigatorState();
}

class _MasterAppNavigatorState extends State<MasterAppNavigator> {
  int _currentStepIndex = 0; // Starts strictly at Screen 1: Login

  void _goToIndex(int index) {
    setState(() {
      _currentStepIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStepIndex) {
      case 0:
        return LoginScreen(onSendOtp: () => _goToIndex(1));
      case 1:
        return OtpVerificationScreen(
          onVerified: () => _goToIndex(2),
          onBack: () => _goToIndex(0),
        );
      case 2:
        return LinkAadhaarScreen(
          onVerified: () => _goToIndex(3),
          onBack: () => _goToIndex(1),
        );
      case 3:
        return BankDbtSetupScreen(
          onComplete: () => _goToIndex(4),
          onBack: () => _goToIndex(2),
        );
      case 4:
        return DashboardScreen(
          onNavigate: (route) {
            if (route == 'screen_mandis') _goToIndex(5);
            if (route == 'screen_booking') _goToIndex(6);
            if (route == 'screen_tracker') _goToIndex(8);
            if (route == 'screen_quality') _goToIndex(9);
            if (route == 'screen_payments') _goToIndex(10);
            if (route == 'screen_suvidha') _goToIndex(11);
            if (route == 'screen_help') _goToIndex(12);
          },
        );
      case 5:
        return NearbyMandisScreen(
          onBookSlot: (_) => _goToIndex(6),
          onBack: () => _goToIndex(4),
        );
      case 6:
        return SmartSlotBookingScreen(
          onConfirmBooking: () => _goToIndex(7),
          onBack: () => _goToIndex(4),
        );
      case 7:
        return GateQrTokenScreen(
          onTrackQueue: () => _goToIndex(8),
          onBack: () => _goToIndex(6),
        );
      case 8:
        return LiveQueueTrackerScreen(
          onGoToQuality: () => _goToIndex(9),
          onBack: () => _goToIndex(4),
        );
      case 9:
        return QualityWeighingScreen(
          onGoToPayments: () => _goToIndex(10),
          onBack: () => _goToIndex(8),
        );
      case 10:
        return MyPaymentsScreen(
          onGoToSuvidha: () => _goToIndex(11),
          onBack: () => _goToIndex(4),
        );
      case 11:
        return KisanSuvidhaScreen(
          onGoToHelp: () => _goToIndex(12),
          onBack: () => _goToIndex(4),
        );
      case 12:
        return HelpCenterScreen(
          onGoToDashboard: () => _goToIndex(4),
          onBack: () => _goToIndex(4),
        );
      default:
        return DashboardScreen(onNavigate: (_) {});
    }
  }
}
