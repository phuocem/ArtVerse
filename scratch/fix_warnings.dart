import 'dart:io';

void removeImport(String filePath, String importLine) {
  final file = File(filePath);
  if (!file.existsSync()) { print('NOT FOUND: $filePath'); return; }
  var content = file.readAsStringSync();
  final before = content;
  // Remove the full import line including newline
  content = content.replaceAll('$importLine\n', '');
  content = content.replaceAll('$importLine\r\n', '');
  if (content != before) {
    file.writeAsStringSync(content);
    print('Fixed import in: $filePath');
  } else {
    print('Import not found in: $filePath  ->  $importLine');
  }
}

void main() {
  const base = 'lib/app';

  // ── Unused imports ──────────────────────────────────────────────────────
  removeImport('$base/modules/draw/views/dialogs/studio_perspective_sheet.dart',
      "import '../../../../data/models/draw/drawn_line_model.dart';");

  removeImport('$base/modules/draw/views/widgets/studio_canvas.dart',
      "import '../../../../data/models/draw/drawn_line_model.dart';");

  removeImport('$base/modules/home/views/widgets/studio_home_widgets.dart',
      "import '../../../../data/models/post_model.dart';");

  removeImport('$base/modules/community/controllers/community_controller.dart',
      "import '../../../core/theme/app_colors.dart';");

  removeImport('$base/modules/wallet/controllers/wallet_controller.dart',
      "import '../../../core/theme/app_colors.dart';");

  removeImport('$base/modules/draw/views/widgets/studio_sidebar_layers.dart',
      "import '../../../layout/controllers/layout_controller.dart';");

  removeImport('$base/modules/draw/views/widgets/studio_sidebar_frames.dart',
      "import '../../../layout/controllers/layout_controller.dart';");

  removeImport('$base/modules/draw/views/widgets/studio_canvas.dart',
      "import '../../../layout/controllers/layout_controller.dart';");

  removeImport('$base/modules/dashboard/views/widgets/dashboard_stats_row.dart',
      "import 'dart:math';");

  removeImport('$base/modules/home/views/widgets/project_card.dart',
      "import 'dart:math' as math;");
  removeImport('$base/modules/home/views/widgets/project_card.dart',
      "import 'dart:math';");

  removeImport('$base/modules/home/views/widgets/project_card.dart',
      "import 'dart:ui';");

  removeImport('$base/modules/profile/views/studio_upgrade_view.dart',
      "import 'dialogs/top_up_dialog.dart';");

  removeImport('$base/modules/home/views/widgets/studio_home_widgets.dart',
      "import 'home_ui_models.dart';");

  removeImport('$base/modules/marketplace/views/widgets/marketplace_card.dart',
      "import 'package:flutter_animate/flutter_animate.dart';");

  removeImport('$base/modules/marketplace/views/widgets/marketplace_hero.dart',
      "import 'package:flutter_animate/flutter_animate.dart';");

  removeImport('$base/modules/profile/views/widgets/profile_header.dart',
      "import 'package:get/get.dart';");

  removeImport('$base/modules/home/views/widgets/project_card.dart',
      "import 'package:lottie/lottie.dart';");

  removeImport('$base/modules/draw/views/draw_view.dart',
      "import 'widgets/studio_rulers.dart';");

  print('\nDone removing unused imports.');
}
