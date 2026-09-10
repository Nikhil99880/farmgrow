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
/// SCREEN 6: NEARBY MANDIS SCREEN
/// ---------------------------------------------------------------------------
class NearbyMandisScreen extends StatefulWidget {
  final Function(String mandiName)? onBookSlot;
  final VoidCallback? onBack;

  const NearbyMandisScreen({super.key, this.onBookSlot, this.onBack});

  @override
  State<NearbyMandisScreen> createState() => _NearbyMandisScreenState();
}

class _NearbyMandisScreenState extends State<NearbyMandisScreen> {
  final _searchController = TextEditingController();
  String _filterDistrict = 'All';
  bool _isHindi = false;

  final List<Map<String, dynamic>> _mandis = [
    {
      'name': 'Karnal Grain Market Hub',
      'hindiName': 'करनाल अनाज मंडी हब',
      'distance': '5.2 km away',
      'wait': '~15 mins wait',
      'waitColor': Color(0xFF2E7D32),
      'capacity': '45% Full',
      'capacityProgress': 0.45,
      'isRecommended': true,
      'address': 'Near GT Road, Karnal District',
    },
    {
      'name': 'Nilokheri Mandi Center',
      'hindiName': 'नीलोखेड़ी मंडी केंद्र',
      'distance': '12.8 km away',
      'wait': '45 mins wait',
      'waitColor': Color(0xFFF57F17),
      'capacity': '78% Full',
      'capacityProgress': 0.78,
      'isRecommended': false,
      'address': 'Station Road, Nilokheri',
    },
    {
      'name': 'Gharaunda Procurement Center',
      'hindiName': 'घरौंडा खरीद केंद्र',
      'distance': '18.4 km away',
      'wait': '> 2 hrs wait',
      'waitColor': Color(0xFFC62828),
      'capacity': '95% Full',
      'capacityProgress': 0.95,
      'isRecommended': false,
      'address': 'Sector 4, Gharaunda',
    },
    {
      'name': 'Sonipat Main Anaj Mandi',
      'hindiName': 'सोनीपत मुख्य अनाज मंडी',
      'distance': '22.0 km away',
      'wait': '25 mins wait',
      'waitColor': Color(0xFF2E7D32),
      'capacity': '52% Full',
      'capacityProgress': 0.52,
      'isRecommended': false,
      'address': 'Mandi Road, Sonipat',
    },
  ];

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
          _isHindi ? 'नज़दीकी मंडियां' : 'Nearby Mandis',
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
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _isHindi ? 'मंडी या जिले के नाम से खोजें...' : 'Search by mandi name or district...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryEmerald),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All Mandis', 'Shortest Wait', '< 10 km', 'High Capacity'].map((f) {
                    final isSel = f == 'All Mandis';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(f, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textDark, fontSize: 11)),
                        backgroundColor: isSel ? AppColors.primaryEmerald : Colors.white,
                        side: BorderSide(color: isSel ? AppColors.primaryEmerald : AppColors.borderSubtle),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Mandi Cards List
              ..._mandis.map((mandi) => _buildMandiCard(mandi)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMandiCard(Map<String, dynamic> mandi) {
    final isRec = mandi['isRecommended'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRec ? const Color(0xFFF1F8E9) : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isRec ? AppColors.primaryEmerald : AppColors.borderSubtle,
          width: isRec ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRec)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.amberGold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: AppColors.textDark),
                  SizedBox(width: 4),
                  Text(
                    'RECOMMENDED • FASTEST ENTRY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHindi ? mandi['hindiName'] : mandi['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mandi['address'],
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions, color: AppColors.primaryEmerald),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening Google Maps route to ${mandi['name']}...')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Metrics Badges
                Row(
                  children: [
                    // Distance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.primaryEmerald),
                          const SizedBox(width: 4),
                          Text(mandi['distance'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Wait Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mandi['waitColor'] as Color),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: mandi['waitColor'] as Color),
                          const SizedBox(width: 4),
                          Text(
                            mandi['wait'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: mandi['waitColor'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Capacity Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isHindi ? 'यार्ड क्षमता' : 'Yard Capacity',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                        Text(
                          mandi['capacity'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: mandi['capacityProgress'] as double,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFECEFF1),
                        valueColor: AlwaysStoppedAnimation<Color>(mandi['waitColor'] as Color),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book Slot Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onBookSlot != null) {
                        widget.onBookSlot!(mandi['name']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isHindi ? 'इस केंद्र पर स्लॉट बुक करें' : 'Book Slot at this Mandi',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
