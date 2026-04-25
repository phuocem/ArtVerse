import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:artverse/app/data/models/resource_model.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/marketplace/controllers/marketplace_controller.dart';
import 'package:artverse/app/widgets/common/studio_common_widgets.dart';

class MarketplaceCard extends GetView<MarketplaceController> {
  final ResourceModel resource;
  final LayoutController lc;

  const MarketplaceCard({
    super.key,
    required this.resource,
    required this.lc,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isOwned = controller.ownedAssetIds.contains(resource.id);
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.downloadResource(resource),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: lc.textColor10, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: GlassCard(
              borderRadius: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: (resource.isLottie && resource.lottieUrl != null) ? null : DecorationImage(
                              image: resource.thumbnailUrl.startsWith('assets/') 
                                ? AssetImage(resource.thumbnailUrl) as ImageProvider
                                : NetworkImage(resource.thumbnailUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: (resource.isLottie && resource.lottieUrl != null)
                            ? Center(child: Lottie.network(resource.lottieUrl!, fit: BoxFit.contain, height: 140))
                            : null,
                        ),
                      ),
                      Positioned(
                        top: 16, right: 16,
                        child: _assetBadge(resource.type.toUpperCase(), isOwned ? Colors.amber : lc.textColor.withValues(alpha: 0.1), lc),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resource.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: lc.textColor, letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Text('By ${resource.authorName}', style: TextStyle(fontSize: 13, color: lc.subtextColor, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _statLabel(MdiIcons.downloadOutline, '${resource.downloadsCount}', lc),
                            const SizedBox(width: 16),
                            _statLabel(MdiIcons.shimmer, 'STUDIO', lc),
                            const Spacer(),
                            _cardActionBtn(isOwned, lc),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _statLabel(IconData icon, String val, LayoutController lc) => Row(
    children: [
      Icon(icon, size: 14, color: lc.textColor30),
      const SizedBox(width: 6),
      Text(val, style: TextStyle(fontSize: 12, color: lc.textColor30, fontWeight: FontWeight.w800)),
    ],
  );

  Widget _cardActionBtn(bool isOwned, LayoutController lc) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: isOwned ? lc.primaryColor15 : lc.textColor05,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isOwned ? lc.primaryColor : lc.textColor10, width: 1),
    ),
    child: Icon(isOwned ? MdiIcons.sendVariant : MdiIcons.download, size: 20, color: isOwned ? lc.primaryColor : lc.textColor),
  );

  Widget _assetBadge(String label, Color color, LayoutController lc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
  );
}
