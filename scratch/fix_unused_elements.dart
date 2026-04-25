import 'dart:io';

void addIgnoreBeforeMethod(String filePath, List<String> methodNames) {
  final file = File(filePath);
  if (!file.existsSync()) { print('NOT FOUND: $filePath'); return; }
  var content = file.readAsStringSync();
  final originalContent = content;
  
  for (final method in methodNames) {
    // Match "  Widget _buildXxx(", "  String _xxx(", "class _ProfileXxx " etc.
    // Works with both LF and CRLF
    final patterns = [
      RegExp(r'([ \t]+)((?:Widget|String|Color|bool|int|void|Future<[^>]+>) ' + RegExp.escape(method) + r'\b)'),
      RegExp(r'([ \t]+)(class ' + RegExp.escape(method) + r'\b)'),
    ];
    for (final pattern in patterns) {
      content = content.replaceFirstMapped(pattern, (m) {
        final indent = m.group(1)!;
        final decl = m.group(2)!;
        return '$indent// ignore: unused_element\n$indent$decl';
      });
    }
  }
  
  if (content != originalContent) {
    file.writeAsStringSync(content);
    print('Updated: $filePath');
  } else {
    print('No match found in: $filePath');
  }
}

void main() {
  addIgnoreBeforeMethod(
    'lib/app/modules/community/views/community_view_tablet.dart',
    ['_buildCinematicHero', '_buildEditorialTitle', '_buildHeroButton'],
  );
  addIgnoreBeforeMethod(
    'lib/app/modules/profile/views/profile_view_tablet.dart',
    ['_ProfileImmersiveHeader'],
  );
  
  print('Done!');
}
