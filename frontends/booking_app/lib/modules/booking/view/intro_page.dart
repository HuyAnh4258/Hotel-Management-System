import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const _bannerImages = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&q=80',
    'https://images.unsplash.com/photo-1501117716987-c8e1ecb21012?w=1200&q=80',
  ];

  static const _galleryImages = [
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200&q=80',
    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200&q=80',
    'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200&q=80',
    'https://images.unsplash.com/photo-1560067174-8943bd0d5b34?w=1200&q=80',
  ];

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_bannerController.hasClients) return;

      final nextPage = (_currentBanner + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07111F), Color(0xFF102A5C), Color(0xFF162447)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(context),
                    const SizedBox(height: 28),
                    _buildIntroArticle(),
                    const SizedBox(height: 28),
                    _buildServiceHighlights(),
                    const SizedBox(height: 28),
                    _buildGallerySection(),
                    const SizedBox(height: 28),
                    _buildExperienceSection(),
                    const SizedBox(height: 28),
                    _buildCallToAction(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandBadge(),
            const SizedBox(height: 22),
            const Text(
              'Khách sạn FPT\nNơi kỳ nghỉ bắt đầu',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.08,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tận hưởng không gian lưu trú hiện đại, dịch vụ tận tâm và hệ sinh thái đặt phòng thông minh. FPT Hotel mang đến trải nghiệm nghỉ dưỡng trọn vẹn cho gia đình, cặp đôi, khách công tác và mọi chuyến đi đáng nhớ.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _InfoChip(icon: Icons.star_rounded, text: 'Dịch vụ 5 sao'),
                _InfoChip(
                  icon: Icons.support_agent_rounded,
                  text: 'Hỗ trợ 24/7',
                ),
                _InfoChip(
                  icon: Icons.verified_rounded,
                  text: 'Đặt phòng an toàn',
                ),
              ],
            ),
          ],
        );

        final banner = _AutoBanner(
          controller: _bannerController,
          images: _bannerImages,
          currentIndex: _currentBanner,
          onChanged: (index) => setState(() => _currentBanner = index),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: content),
              const SizedBox(width: 34),
              Expanded(flex: 5, child: banner),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [content, const SizedBox(height: 26), banner],
        );
      },
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Text(
        'FPT HOTEL • PREMIUM BOOKING',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIntroArticle() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(
            eyebrow: 'Câu chuyện thương hiệu',
            title: 'Không gian nghỉ dưỡng được thiết kế cho sự thoải mái',
          ),
          SizedBox(height: 16),
          Text(
            'FPT Hotel được xây dựng với mong muốn tạo ra một điểm dừng chân sang trọng, tiện nghi và gần gũi. Mỗi căn phòng đều được chăm chút từ ánh sáng, màu sắc, nội thất đến các tiện ích đi kèm để khách hàng luôn cảm thấy thư giãn như đang ở nhà nhưng vẫn tận hưởng tiêu chuẩn dịch vụ chuyên nghiệp.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.75,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Từ khoảnh khắc đặt phòng, nhận phòng, sử dụng dịch vụ nhà hàng, spa, đưa đón cho đến khi kết thúc kỳ nghỉ, hệ thống quản lý khách sạn hỗ trợ mọi thao tác nhanh chóng và minh bạch. Đội ngũ nhân viên luôn sẵn sàng lắng nghe, tư vấn và cá nhân hóa trải nghiệm theo nhu cầu của từng khách hàng.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.75,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Dù bạn cần một nơi nghỉ ngơi sau chuyến công tác, một kỳ nghỉ cuối tuần cùng gia đình hay một không gian lãng mạn cho những dịp đặc biệt, FPT Hotel luôn có lựa chọn phù hợp với mức giá rõ ràng, quy trình đặt phòng thuận tiện và nhiều ưu đãi hấp dẫn.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHighlights() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 780;
        final cards = [
          const _HighlightCard(
            icon: Icons.king_bed_rounded,
            title: 'Phòng nghỉ tinh tế',
            text:
                'Giường êm ái, nội thất hiện đại, tầm nhìn thoáng đãng và đầy đủ tiện nghi cho mọi nhu cầu lưu trú.',
          ),
          const _HighlightCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Ẩm thực đa dạng',
            text:
                'Thực đơn phong phú, nguyên liệu chọn lọc và không gian nhà hàng ấm cúng cho bữa ăn trọn vẹn.',
          ),
          const _HighlightCard(
            icon: Icons.room_service_rounded,
            title: 'Dịch vụ tận tâm',
            text:
                'Lễ tân, dọn phòng, tư vấn đặt dịch vụ và hỗ trợ khách hàng hoạt động liên tục mỗi ngày.',
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i != cards.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGallerySection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            eyebrow: 'Không gian nổi bật',
            title: 'Khám phá từng góc trải nghiệm tại FPT Hotel',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 760 ? 4 : 2;

              return GridView.builder(
                itemCount: _galleryImages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: crossAxisCount == 4 ? 0.86 : 0.92,
                ),
                itemBuilder: (context, index) => _GalleryTile(
                  imagePath: _galleryImages[index],
                  title: switch (index) {
                    0 => 'Sảnh đón khách',
                    1 => 'Phòng nghỉ',
                    2 => 'Nhà hàng',
                    _ => 'Tiện ích',
                  },
                  subtitle: switch (index) {
                    0 => 'Sang trọng và chuyên nghiệp',
                    1 => 'Ấm cúng, hiện đại',
                    2 => 'Hương vị tinh tế',
                    _ => 'Thư giãn mỗi ngày',
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        final left = _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SectionTitle(
                eyebrow: 'Vì sao chọn chúng tôi',
                title: 'Một hành trình lưu trú mượt mà từ online đến trực tiếp',
              ),
              SizedBox(height: 16),
              _FeatureRow(
                icon: Icons.mobile_friendly_rounded,
                text:
                    'Đặt phòng nhanh trên hệ thống, theo dõi thông tin rõ ràng và hạn chế tối đa thời gian chờ.',
              ),
              SizedBox(height: 14),
              _FeatureRow(
                icon: Icons.cleaning_services_rounded,
                text:
                    'Không gian luôn được vệ sinh kỹ lưỡng, đảm bảo sự an toàn và thoải mái cho khách hàng.',
              ),
              SizedBox(height: 14),
              _FeatureRow(
                icon: Icons.local_offer_rounded,
                text:
                    'Nhiều gói ưu đãi linh hoạt cho đặt phòng sớm, lưu trú dài ngày và các dịp đặc biệt.',
              ),
            ],
          ),
        );

        final right = _GlassCard(
          child: Column(
            children: const [
              _MetricItem(value: '24/7', label: 'Hỗ trợ khách hàng'),
              Divider(color: Colors.white24, height: 30),
              _MetricItem(value: '98%', label: 'Khách hàng hài lòng'),
              Divider(color: Colors.white24, height: 30),
              _MetricItem(value: '5★', label: 'Tiêu chuẩn phục vụ'),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6, child: left),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: right),
            ],
          );
        }

        return Column(children: [left, const SizedBox(height: 16), right]);
      },
    );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF6D776)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final text = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sẵn sàng bắt đầu kỳ nghỉ của bạn?',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Khám phá phòng trống, dịch vụ khách sạn và ưu đãi mới nhất ngay hôm nay.',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

          final button = SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => Get.offAllNamed('/dashboard'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Khám phá dịch vụ'),
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: 22),
                button,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: button),
            ],
          );
        },
      ),
    );
  }
}

class _AutoBanner extends StatelessWidget {
  const _AutoBanner({
    required this.controller,
    required this.images,
    required this.currentIndex,
    required this.onChanged,
  });

  final PageController controller;
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 36,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipOval(
                child: PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  onPageChanged: onChanged,
                  itemBuilder: (context, index) => Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white.withValues(alpha: 0.12),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white.withValues(alpha: 0.12),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.white70,
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: currentIndex == index ? 28 : 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xFFD4AF37)
                        : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 29),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.white.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white.withValues(alpha: 0.1),
              child: const Icon(
                Icons.image_not_supported_rounded,
                color: Colors.white70,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
