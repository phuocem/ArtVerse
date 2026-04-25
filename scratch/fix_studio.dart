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
        
        // 1. Fix STUDIO corruption
        final replacements = {
          'STUDIOject': 'project',
          'STUDIOfile': 'profile',
          'STUDIOgress': 'progress',
          'STUDIOmpt': 'prompt',
          'STUDIOcessed': 'processed',
          'STUDIOjected': 'projected',
          'path_STUDIOvider': 'path_provider',
        };
        
        replacements.forEach((key, value) {
          content = content.replaceAll(key, value);
        });
        
        // 2. Fix Case for Classes and Types
        content = content.replaceAll('Get.find<profileController>', 'Get.find<ProfileController>');
        content = content.replaceAll('Rxn<profileController>', 'Rxn<ProfileController>');
        content = content.replaceAll('Get.find<projectController>', 'Get.find<ProjectController>');
        content = content.replaceAll('class profileController', 'class ProfileController');
        content = content.replaceAll('class projectController', 'class ProjectController');
        
        // 3. Fix camelCase variables
        content = content.replaceAll('currentprojectId', 'currentProjectId');
        content = content.replaceAll('currentprojectName', 'currentProjectName');
        content = content.replaceAll('parentprojectId', 'parentProjectId');
        content = content.replaceAll('saveprojectToHive', 'saveProjectToHive');
        content = content.replaceAll('loadproject', 'loadProject');
        content = content.replaceAll('DrawprojectModel', 'DrawProjectModel');
        content = content.replaceAll('drawprojectBox', 'drawProjectBox');
        content = content.replaceAll('projectsaved', 'projectSaved');
        content = content.replaceAll('projectSelected', 'projectSelected');

        // 4. Fix withOpacity deprecation
        // Regex: .withOpacity(value) -> .withValues(alpha: value)
        final opacityRegex = RegExp(r'\.withOpacity\((.*?)\)');
        content = content.replaceAllMapped(opacityRegex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });

        if (content != originalContent) {
          file.writeAsStringSync(content);
          print('Updated ${file.path}');
        }
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }
  });
}
