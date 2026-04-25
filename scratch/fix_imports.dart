import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('Directory lib not found');
    return;
  }
  dir.listSync(recursive: true).forEach((file) {
    if (file is File && file.path.endsWith('.dart')) {
      try {
        var content = file.readAsStringSync();
        var originalContent = content;

        final filePath = file.path.replaceAll('\\', '/');

        // ───────────────────────────────────────────────
        // FIX 1: draw_controller.dart – wrong import paths for views/widgets files
        // It sits in: lib/app/modules/draw/controllers/draw_controller.dart
        // So '../views/studio_widgets.dart' resolves to draw/views/studio_widgets.dart (not existing)
        // Correct: '../views/widgets/studio_widgets.dart'
        if (filePath.contains('modules/draw/controllers/draw_controller.dart')) {
          content = content.replaceAll(
            "import '../views/studio_widgets.dart';",
            "import '../views/widgets/studio_widgets.dart';",
          );
          content = content.replaceAll(
            "import '../views/sketcher.dart';",
            "import '../views/widgets/sketcher.dart';",
          );
        }

        // ───────────────────────────────────────────────
        // FIX 2: Files in draw/views/widgets/ import '../controllers/...'
        // They sit at draw/views/widgets/*.dart
        // '../controllers/' resolves to draw/views/controllers/ (WRONG)
        // Correct: '../../controllers/'
        if (filePath.contains('modules/draw/views/widgets/')) {
          content = content.replaceAll(
            "import '../controllers/draw_controller.dart';",
            "import '../../controllers/draw_controller.dart';",
          );
          content = content.replaceAll(
            "import '../controllers/collab_controller.dart';",
            "import '../../controllers/collab_controller.dart';",
          );
          content = content.replaceAll(
            "import '../controllers/ai_draw_controller.dart';",
            "import '../../controllers/ai_draw_controller.dart';",
          );
          // Also fix model imports: '../../../data/models/...' from views/widgets/ goes up 5 levels
          // draw/views/widgets → up 3 = modules → up 4 = app → up 5 = lib
          // '../../../data/models' resolves to: draw/views/data (WRONG)
          // Correct: '../../../../data/models'
          content = content.replaceAll(
            "import '../../../data/models/draw/drawn_line_model.dart';",
            "import '../../../../data/models/draw/drawn_line_model.dart';",
          );
          content = content.replaceAll(
            "import '../../../data/models/draw/layer_model.dart';",
            "import '../../../../data/models/draw/layer_model.dart';",
          );
          content = content.replaceAll(
            "import '../../../data/models/draw/frame_model.dart';",
            "import '../../../../data/models/draw/frame_model.dart';",
          );
          // Also fix layout controller import
          content = content.replaceAll(
            "import '../../layout/controllers/layout_controller.dart';",
            "import '../../../layout/controllers/layout_controller.dart';",
          );
        }

        // ───────────────────────────────────────────────
        // FIX 3: Files in draw/views/dialogs/ import '../controllers/...'
        // They sit at draw/views/dialogs/*.dart
        // '../controllers/' resolves to draw/views/controllers/ (WRONG)
        // Correct: '../../controllers/'
        if (filePath.contains('modules/draw/views/dialogs/')) {
          content = content.replaceAll(
            "import '../controllers/draw_controller.dart';",
            "import '../../controllers/draw_controller.dart';",
          );
          content = content.replaceAll(
            "import '../controllers/ai_draw_controller.dart';",
            "import '../../controllers/ai_draw_controller.dart';",
          );
          content = content.replaceAll(
            "import '../controllers/collab_controller.dart';",
            "import '../../controllers/collab_controller.dart';",
          );
          // Fix model imports from dialogs/ (same as widgets/)
          content = content.replaceAll(
            "import '../../../data/models/draw/drawn_line_model.dart';",
            "import '../../../../data/models/draw/drawn_line_model.dart';",
          );
          content = content.replaceAll(
            "import '../../../data/models/draw/layer_model.dart';",
            "import '../../../../data/models/draw/layer_model.dart';",
          );
          // Fix widgets reference from dialogs/
          content = content.replaceAll(
            "import '../widgets/studio_widgets.dart';",
            "import '../widgets/studio_widgets.dart';",  // This one is correct already
          );
        }

        // ───────────────────────────────────────────────
        // FIX 4: layout_view.dart – 'pro_side_rail.dart' → 'studio_side_rail.dart'
        if (filePath.contains('modules/layout/views/layout_view.dart')) {
          content = content.replaceAll(
            "import 'pro_side_rail.dart';",
            "import 'studio_side_rail.dart';",
          );
          content = content.replaceAll(
            'ProSideRail()',
            'StudioSideRail()',
          );
          content = content.replaceAll(
            'const ProSideRail()',
            'const StudioSideRail()',
          );
        }

        // ───────────────────────────────────────────────
        // FIX 5: home_view.dart – 'widgets/create_project_dialog.dart' → 'dialogs/create_project_dialog.dart'
        if (filePath.contains('modules/home/views/home_view.dart')) {
          content = content.replaceAll(
            "import 'widgets/create_project_dialog.dart';",
            "import 'dialogs/create_project_dialog.dart';",
          );
        }

        // ───────────────────────────────────────────────
        // FIX 6: Remaining STUDIO corruptions that the script may have missed
        // These are specific ones the fix_studio script might not have caught
        content = content.replaceAll('CircularprogressIndicator', 'CircularProgressIndicator');
        content = content.replaceAll('currentprojectToUpload', 'currentProjectToUpload');
        content = content.replaceAll('SketcherFull', 'SketcherFull');  // This was correct already
        
        // Fix ProfileController reference that got lowercased
        content = content.replaceAll(
          'final profileController = Get.find<profileController>()',
          'final profileController = Get.find<ProfileController>()',
        );

        if (content != originalContent) {
          file.writeAsStringSync(content);
          print('Fixed: ${file.path}');
        }
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }
  });
  print('Done!');
}
