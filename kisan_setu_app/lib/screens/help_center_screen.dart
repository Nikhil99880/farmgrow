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
/// SCREEN 13: HELP CENTER & KRISHI SAHAYAK CHAT SCREEN
/// ---------------------------------------------------------------------------
class HelpCenterScreen extends StatefulWidget {
  final VoidCallback? onGoToDashboard;
  final VoidCallback? onBack;

  const HelpCenterScreen({super.key, this.onGoToDashboard, this.onBack});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'नमस्ते राम सिंह जी! मैं आपका कृषि सहायक हूँ। आप मंडी स्लॉट, न्यूनतम समर्थन मूल्य (MSP) या भुगतान के बारे में कुछ भी पूछ सकते हैं।',
    },
  ];

  String _selectedLang = 'Hindi';
  bool _isHindi = true;

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _chatController.clear();
    });

    // Simulated Smart Assistant Response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        String reply = 'आपकी गेहूं खरीद का टोकन #42 मान्य है। मंडी गेट 2 पर 12 वाहन आगे हैं।';
        if (text.toLowerCase().contains('payment') || text.contains('भुगतान') || text.contains('रुपया')) {
          reply = 'आपका ₹45,000 का डीबीटी भुगतान एसबीआई खाते में सफलतापूर्वक जमा कर दिया गया है।';
        } else if (text.toLowerCase().contains('msp') || text.contains('भाव') || text.contains('रेट')) {
          reply = 'इस रबी मौसम के लिए गेहूं का न्यूनतम समर्थन मूल्य (MSP) ₹2,425/क्विंटल है।';
        }
        _messages.add({'sender': 'bot', 'text': reply});
      });
    });
  }

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
          _isHindi ? 'सहायता केंद्र एवं सहायक' : 'Help Center & Sahayak',
          style: const TextStyle(
            color: AppColors.darkEmerald,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Multilingual Support Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select App Language / भाषा चुनें:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      children: ['हिन्दी', 'English', 'ਪੰਜਾਬੀ', 'मराठी'].map((lang) {
                        final isSel = _selectedLang == lang;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLang = lang;
                                  _isHindi = lang == 'हिन्दी';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSel ? AppColors.primaryEmerald : Colors.white,
                                foregroundColor: isSel ? Colors.white : AppColors.textDark,
                                elevation: 0,
                                side: BorderSide(color: isSel ? AppColors.primaryEmerald : AppColors.borderSubtle),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text(lang, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Toll-Free Helpline Direct Call
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dialing Kisan Call Center 1800-180-1551...')),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.amberGold,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentAmber, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.call, color: AppColors.textDark, size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '24/7 Farmer Helpline (Toll-Free)',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark),
                            ),
                            Text(
                              '1800-180-1551 (टोल फ्री सहायता नंबर)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.phone_forwarded, color: AppColors.textDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. AI Krishi Sahayak Interactive Chat Box
              Text(
                _isHindi ? 'कृषि सहायक AI चैट' : 'Chat with Krishi Sahayak AI',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkEmerald),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Chat Messages Scroll Container
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(14),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isBot = msg['sender'] == 'bot';
                          return Align(
                            alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: isBot ? AppColors.lightEmerald : AppColors.darkEmerald,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg['text']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isBot ? AppColors.textDark : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Chat Input Bar
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: _isHindi ? 'अपना सवाल यहाँ टाइप करें...' : 'Ask your query in English/Hindi...',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: AppColors.primaryEmerald),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Return to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onGoToDashboard != null) {
                      widget.onGoToDashboard!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'मुख्य डैशबोर्ड पर लौटें' : 'Return to Main Dashboard',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
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
}
