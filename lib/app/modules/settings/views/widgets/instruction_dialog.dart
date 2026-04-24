import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../layout/controllers/layout_controller.dart';

class InstructionDialog extends StatefulWidget {
  const InstructionDialog({super.key});

  static void show() {
    Get.dialog(
      const InstructionDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.8),
    );
  }

  @override
  State<InstructionDialog> createState() => _InstructionDialogState();
}

class _InstructionDialogState extends State<InstructionDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'guide_wallet_title',
      'desc': 'guide_wallet_desc',
      'icon': 'account_balance_wallet_rounded',
    },
    {
      'title': 'guide_social_title',
      'desc': 'guide_social_desc',
      'icon': 'hub_rounded',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: lc.backgroundColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: lc.primaryColor.withValues(alpha: 0.2),
              blurRadius: 40,
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'user_guide'.tr.toUpperCase(),
                    style: TextStyle(
                      color: lc.primaryColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, color: lc.subtextColor),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: lc.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(slide['icon']!),
                            size: 80,
                            color: lc.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title']!.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: lc.textColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['desc']!.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: lc.subtextColor,
                            fontSize: 16,
                            height: 1.5,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_slides.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? lc.primaryColor
                              : lc.subtextColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutQuart);
                      } else {
                        Get.back();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: lc.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: lc.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        _currentPage < _slides.length - 1 ? 'next'.tr : 'done'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'brush_rounded':
        return Icons.brush_rounded;
      case 'account_balance_wallet_rounded':
        return Icons.account_balance_wallet_rounded;
      case 'hub_rounded':
        return Icons.hub_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
