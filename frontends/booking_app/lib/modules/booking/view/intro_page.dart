import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Colour Tokens ────────────────────────────────────────────────────────────
const _kDeep    = Color(0xFF1C0A04);   // nền nâu tối
const _kNavy    = Color(0xFF2D1408);   // nền phụ
const _kGold    = Color(0xFFF97316);   // cam chủ đạo
const _kGoldLight = Color(0xFFFDBA74); // cam nhạt
const _kWhite   = Colors.white;

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  static const _bannerImages = [
    'assets/images/intro1.png',
    'assets/images/intro2.png',
    'assets/images/intro3.png',
  ];

  static const _bannerLabels = [
    'Nghỉ dưỡng sang trọng',
    'Không gian thư thái',
    'Trải nghiệm đỉnh cao',
  ];

  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentIndex + 1) % _bannerImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDeep,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroFullScreen(),
              _buildStatsBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildAboutSection(),
                    const SizedBox(height: 32),
                    _buildServicesGrid(),
                    const SizedBox(height: 32),
                    _buildTestimonial(),
                    const SizedBox(height: 32),
                    _buildCTA(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero: Full-screen banner ────────────────────────────────────────────────
  Widget _buildHeroFullScreen() {
    final screenH = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenH * 0.78,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView images
          PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => Image.asset(
              _bannerImages[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _kNavy),
            ),
          ),

          // Gradient overlay (bottom)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.7, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.60),
                    _kDeep,
                  ],
                ),
              ),
            ),
          ),

          // Top bar: logo + badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _kGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FPT HOTEL',
                        style: TextStyle(
                          color: _kWhite,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _glassPill(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: _kGold, size: 15),
                      SizedBox(width: 5),
                      Text(
                        '5 Sao',
                        style: TextStyle(
                          color: _kWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom content: title + indicator
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slide label
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _bannerLabels[_currentIndex],
                    key: ValueKey(_currentIndex),
                    style: TextStyle(
                      color: _kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Khách sạn FPT\nNơi kỳ nghỉ\nbắt đầu',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Indicator dots
                Row(
                  children: List.generate(_bannerImages.length, (i) {
                    final active = i == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      width: active ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? _kGold
                            : _kWhite.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // CTA button
                GestureDetector(
                  onTap: () => Get.offAllNamed('/dashboard'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kGold, _kGoldLight],
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: _kGold.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Đặt phòng ngay',
                          style: TextStyle(
                            color: Color(0xFF3D1503),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF3D1503),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scroll hint
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _kWhite.withValues(alpha: 0.5),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats bar ──────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      transform: Matrix4.translationValues(0, -30, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGold, _kGoldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(child: _StatItem(value: '500+', label: 'Phòng')),
          _StatDivider(),
          Expanded(child: _StatItem(value: '98%', label: 'Hài lòng')),
          _StatDivider(),
          Expanded(child: _StatItem(value: '24/7', label: 'Hỗ trợ')),
          _StatDivider(),
          Expanded(child: _StatItem(value: '5★', label: 'Chất lượng')),
        ],
      ),
    );
  }

  // ─── About section ──────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('VỀ CHÚNG TÔI'),
          const SizedBox(height: 12),
          const Text(
            'Không gian nghỉ dưỡng\nđược thiết kế cho sự thoải mái',
            style: TextStyle(
              color: _kWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FPT Hotel được xây dựng với mong muốn tạo ra điểm dừng chân sang trọng, tiện nghi và gần gũi. Mỗi căn phòng được chăm chút từ ánh sáng, màu sắc, nội thất đến các tiện ích đi kèm để khách hàng luôn cảm thấy thư giãn như ở nhà nhưng tận hưởng tiêu chuẩn dịch vụ chuyên nghiệp.',
            style: TextStyle(
              color: _kWhite.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          // Feature chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FeatureChip(Icons.wifi_rounded, 'WiFi miễn phí'),
              _FeatureChip(Icons.local_parking_rounded, 'Bãi đỗ xe'),
              _FeatureChip(Icons.pool_rounded, 'Hồ bơi'),
              _FeatureChip(Icons.spa_rounded, 'Spa & Gym'),
              _FeatureChip(Icons.restaurant_rounded, 'Nhà hàng'),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Services grid ──────────────────────────────────────────────────────────
  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('DỊCH VỤ NỔI BẬT'),
        const SizedBox(height: 12),
        const Text(
          'Mọi tiện ích bạn cần',
          style: TextStyle(
            color: _kWhite,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 600 ? 3 : 2;
            const items = [
              _ServiceData(Icons.king_bed_rounded, 'Phòng cao cấp',
                  'Giường êm, nội thất hiện đại, tầm nhìn thoáng đãng.'),
              _ServiceData(Icons.restaurant_menu_rounded, 'Ẩm thực',
                  'Thực đơn phong phú, nguyên liệu tươi ngon mỗi ngày.'),
              _ServiceData(Icons.spa_rounded, 'Spa & Thư giãn',
                  'Liệu trình thư giãn chuyên nghiệp sau mỗi chuyến đi.'),
              _ServiceData(Icons.directions_car_rounded, 'Đưa đón',
                  'Xe sang trọng phục vụ đón tiễn sân bay 24/7.'),
              _ServiceData(Icons.pool_rounded, 'Hồ bơi',
                  'Không gian bơi lội rộng rãi, thoáng mát cả ngày.'),
              _ServiceData(Icons.room_service_rounded, 'Room Service',
                  'Phục vụ tận phòng mọi yêu cầu trong 15 phút.'),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _ServiceCard(data: items[i]),
            );
          },
        ),
      ],
    );
  }

  // ─── Testimonial ────────────────────────────────────────────────────────────
  Widget _buildTestimonial() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: _kGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(28),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            _kGold.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: _kGold, size: 40),
          const SizedBox(height: 12),
          const Text(
            '"Dịch vụ tuyệt vời, phòng sạch sẽ và nhân viên thân thiện. Tôi đã có kỳ nghỉ đáng nhớ nhất trong cuộc đời tại FPT Hotel!"',
            style: TextStyle(
              color: _kWhite,
              fontSize: 16,
              height: 1.75,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _kGold.withValues(alpha: 0.18),
                child: const Text(
                  'AN',
                  style: TextStyle(
                    color: _kGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nguyễn Anh',
                    style: TextStyle(
                      color: _kWhite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Khách hạng VIP • TP.HCM',
                    style: TextStyle(
                      color: _kWhite.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: _kGold,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CTA ────────────────────────────────────────────────────────────────────
  Widget _buildCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGold, _kGoldLight, Color(0xFFFED7AA)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: 0.5),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: Color(0xFF3D1503),
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sẵn sàng cho\nkỳ nghỉ của bạn?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF3D1503),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Khám phá phòng trống và ưu đãi mới nhất\nngay hôm nay.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF111827).withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.offAllNamed('/dashboard'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_rounded,
                    color: _kGold,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Khám phá dịch vụ',
                    style: TextStyle(
                      color: _kWhite,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  Widget _glassPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _kWhite.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _kGold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      );
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF111827).withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: const Color(0xFF111827).withValues(alpha: 0.25),
      );
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _kGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _kGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kGold, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: _kWhite,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceData {
  const _ServiceData(this.icon, this.title, this.desc);
  final IconData icon;
  final String title, desc;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.data});
  final _ServiceData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kGold, _kGoldLight],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: const Color(0xFF111827), size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: const TextStyle(
              color: _kWhite,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.desc,
            style: TextStyle(
              color: _kWhite.withValues(alpha: 0.6),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
