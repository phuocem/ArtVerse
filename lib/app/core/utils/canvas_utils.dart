import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

class CanvasUtils {
  
  
  static void floodFill({
    required Uint32List pixels,
    required int width,
    required int height,
    required int startX,
    required int startY,
    required int newColor,
  }) {
    if (startX < 0 || startX >= width || startY < 0 || startY >= height) return;
    
    final int targetColor = pixels[startY * width + startX];
    if (targetColor == newColor) return;

    final Queue<int> queue = Queue<int>();
    queue.add(startY * width + startX);

    while (queue.isNotEmpty) {
      final int idx = queue.removeFirst();
      if (pixels[idx] != targetColor) continue;

      
      pixels[idx] = newColor;

      final int x = idx % width;
      final int y = idx ~/ width;

      
      if (x > 0) queue.add(idx - 1);
      if (x < width - 1) queue.add(idx + 1);
      if (y > 0) queue.add(idx - width);
      if (y < height - 1) queue.add(idx + width);
    }
  }

  
  static Future<Uint32List?> getImagePixels(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;
    return byteData.buffer.asUint32List();
  }
  
  
  static Future<ui.Image> pixelsToImage(Uint32List pixels, int width, int height) async {
    final completer = ui.ImmutableBuffer.fromUint8List(pixels.buffer.asUint8List());
    final codec = await ui.instantiateImageCodec(pixels.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
