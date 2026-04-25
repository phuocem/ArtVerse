import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuickCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const QuickCard({super.key, required this.item});

  @override
  State<QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<QuickCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = item['color'] as Color;
    final tag = item['tag'] as String?;
    final tagColor = item['tagColor'] as Color?;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
        child: GestureDetector(
          onTap: item['onTap'] as VoidCallback?,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: _hovered ? color.withValues(alpha: 0.5) : AppColors.border2,
                width: 1.5,
              ),
              boxShadow: _hovered
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ]
                  : [],
            ),
            child: Stack(
              children: [
                if (tag != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (tagColor ?? color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (tagColor ?? color).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          color: tagColor ?? color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (item['iconBg'] as Color? ?? color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['sub'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;

  const HeroStat({
    super.key,
    required this.label,
    required this.value,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Lexend',
                letterSpacing: 0,
              ),
            ),
            if (suffix.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 1),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

