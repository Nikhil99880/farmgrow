import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryEmerald = Color(0xFF2E7D32);
  static const Color darkEmerald = Color(0xFF1B5E20);
  static const Color lightEmerald = Color(0xFFE8F5E9);
  static const Color accentAmber = Color(0xFFF57F17);
  static const Color amberGold = Color(0xFFFDD400);
  static const Color amberLight = Color(0xFFFFF9C4);
  static const Color background = Color(0xFFF9FBF9);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textMuted = Color(0xFF55605A);
  static const Color borderSubtle = Color(0xFFCFD8DC);
  static const Color errorRed = Color(0xFFC62828);
}

/// ---------------------------------------------------------------------------
/// SCREEN 9: LIVE QUEUE TRACKER SCREEN
/// ---------------------------------------------------------------------------
class LiveQueueTrackerScreen extends StatefulWidget {
  final VoidCallback? onGoToQuality;
  final VoidCallback? onBack;

  const LiveQueueTrackerScreen({super.key, this.onGoToQuality, this.onBack});

  @override
  State<LiveQueueTrackerScreen> createState() => _LiveQueueTrackerScreenState();
}

class _LiveQueueTrackerScreenState extends State<LiveQueueTrackerScreen> {
  bool _isHindi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkEmerald),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _isHindi ? 'लाइव कतार ट्रैकर' : 'Live Queue Tracker',
          style: const TextStyle(
            color: AppColors.darkEmerald,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16, color: AppColors.primaryEmerald),
              label: Text(_isHindi ? 'EN' : 'हिन्दी', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              backgroundColor: AppColors.amberLight,
              onPressed: () => setState(() => _isHindi = !_isHindi),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Token Header Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primaryEmerald, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.darkEmerald,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isHindi ? 'सक्रिय टोकन आईडी' : 'ACTIVE TOKEN ID',
                                style: const TextStyle(color: Color(0xFFAFEFDD), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '#KP-2026-8492',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amberGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'IN QUEUE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            _isHindi ? 'वर्तमान चरण: मंडी गेट प्रवेश' : 'Current Stage: Mandi Gate Entry',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Sonipat Main Mandi • Gate 2',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Live Metrics (2 Cards)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.directions_car, color: AppColors.primaryEmerald, size: 28),
                          const SizedBox(height: 6),
                          const Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkEmerald)),
                          Text(
                            _isHindi ? 'आगे के वाहन' : 'Vehicles Ahead',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentAmber, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.accentAmber, size: 28),
                          const SizedBox(height: 6),
                          const Text('~15 m', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                          Text(
                            _isHindi ? 'अनुमानित समय' : 'Est. Wait Time',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Vertical Process Pipeline Stepper
              Text(
                _isHindi ? 'प्रक्रिया की स्थिति' : 'Procurement Pipeline Status',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkEmerald),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildPipelineStep(
                      stepNum: '✓',
                      title: _isHindi ? 'स्लॉट पुष्टि' : 'Slot Confirmed',
                      time: '08:30 AM',
                      isCompleted: true,
                      isActive: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: SizedBox(height: 14, child: VerticalDivider(color: AppColors.primaryEmerald, thickness: 2)),
                    ),
                    _buildPipelineStep(
                      stepNum: '▶',
                      title: _isHindi ? 'मंडी गेट प्रवेश' : 'Gate 2 Barrier Entry',
                      time: 'In Progress (प्रगति पर)',
                      isCompleted: false,
                      isActive: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: SizedBox(height: 14, child: VerticalDivider(color: AppColors.borderSubtle, thickness: 2)),
                    ),
                    _buildPipelineStep(
                      stepNum: '3',
                      title: _isHindi ? 'गुणवत्ता एवं नमी परीक्षण' : 'Quality & Moisture Test',
                      time: 'Upcoming (~15 mins)',
                      isCompleted: false,
                      isActive: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: SizedBox(height: 14, child: VerticalDivider(color: AppColors.borderSubtle, thickness: 2)),
                    ),
                    _buildPipelineStep(
                      stepNum: '4',
                      title: _isHindi ? 'इलेक्ट्रॉनिक धर्मकांटा तौल' : 'Electronic Weighbridge (Tare/Gross)',
                      time: 'Upcoming',
                      isCompleted: false,
                      isActive: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Vehicle Registration Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightEmerald,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: AppColors.primaryEmerald, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHindi ? 'पंजीकृत वाहन संख्या' : 'Registered Vehicle',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'PB-10-EH-9821 (Tractor Trolley)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.darkEmerald),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Text('GATE 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Next Action Button: Go to Quality Check
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onGoToQuality != null) {
                      widget.onGoToQuality!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.science, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'गुणवत्ता एवं तौल विवरण देखें' : 'View Quality & Weighing Details',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStep({
    required String stepNum,
    required String title,
    required String time,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color bg = const Color(0xFFECEFF1);
    Color fg = AppColors.textMuted;
    if (isCompleted) {
      bg = AppColors.primaryEmerald;
      fg = Colors.white;
    } else if (isActive) {
      bg = AppColors.accentAmber;
      fg = Colors.white;
    }

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: Text(
              stepNum,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive || isCompleted ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.accentAmber : (isCompleted ? AppColors.textDark : AppColors.textMuted),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.primaryEmerald : (isActive ? AppColors.accentAmber : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
