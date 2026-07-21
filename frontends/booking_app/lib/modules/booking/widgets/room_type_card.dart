import 'package:flutter/material.dart';

class RoomTypeCard extends StatelessWidget {
  const RoomTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
    this.priceLabel,
    this.availableCount,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;
  final String? priceLabel;
  final int? availableCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 92,
                  height: 76,
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(scheme),
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(scheme),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (availableCount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(
                            alpha: 0.56,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$availableCount phòng trống',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    if (priceLabel != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          priceLabel!,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(82, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Chọn'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.primary.withValues(alpha: 0.10),
      child: Icon(Icons.hotel_rounded, size: 48, color: scheme.primary),
    );
  }
}
