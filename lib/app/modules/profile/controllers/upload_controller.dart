import 'dart:io';
import 'dart:convert';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artverse/app/modules/profile/repositories/upload_repository.dart';
import 'package:artverse/app/modules/profile/providers/upload_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:artverse/app/data/models/draw/draw_project_model.dart';
import 'package:artverse/app/data/models/post_model.dart';
import 'package:artverse/app/modules/profile/controllers/profile_controller.dart';

class UploadController extends GetxController {
  final _repository = UploadRepository(UploadProvider());
  final isUploading = false.obs;
  final progress = 0.0.obs;
  final profileController = Get.find<ProfileController>();

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    videoFile.value = null;
    backgroundFile.value = null;
    super.onClose();
  }

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<File?> videoFile = Rx<File?>(null);
  final Rx<File?> backgroundFile = Rx<File?>(null);
  final allowRemix = true.obs;
  DrawProjectModel? currentProjectToUpload;

  Future<void> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null && result.files.isNotEmpty) {
      videoFile.value = File(result.files.single.path!);
    }
  }

  Future<void> pickBackgroundFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      backgroundFile.value = File(result.files.single.path!);
    }
  }

  Future<void> uploadImage(String userId, File imageFile) async {
    isUploading.value = true;
    progress.value = 0.0;
    final imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final storagePath = '$userId/$imageId/image.png';
    try {
      if (!imageFile.existsSync()) {
        throw Exception("Local file not found for upload: ${imageFile.path}");
      }
      int retryCount = 0;
      bool success = false;
      while (retryCount < 3 && !success) {
        try {
          final data = await imageFile.readAsBytes();
          if (data.isEmpty) throw Exception("Image file is empty");
          await _repository.uploadFile(bucket: 'posts', path: storagePath, bytes: data, contentType: 'image/png');
          success = true;
        } catch (e) {
          retryCount++;
          if (retryCount >= 3) rethrow;
          await Future.delayed(Duration(seconds: 1 * retryCount));
        }
      }
      progress.value = 0.9;
      final url = _repository.getFileUrl('posts', storagePath);
      String? projectFileUrl;
      if (allowRemix.value && currentProjectToUpload != null) {
        final projectJson = jsonEncode(currentProjectToUpload!.toJson());
        final projectBytes = utf8.encode(projectJson);
        final projectStoragePath = '$userId/$imageId/project.json';
        await _repository.uploadFile(bucket: 'posts', path: projectStoragePath, bytes: projectBytes, contentType: 'application/json');
        projectFileUrl = _repository.getFileUrl('posts', projectStoragePath);
      }
      final post = PostModel(
        createdAt: DateTime.now(),
        editedAt: DateTime.now(),
        name: nameController.text,
        description: descriptionController.text,
        url: url,
        status: 1,
        userId: userId,
        views: 0,
        thumbnail: url,
        projectFileUrl: projectFileUrl,
      );
      await _repository.publishPost(post);
      progress.value = 1.0;
      isUploading.value = false;
      safeSnackbar('Success', 'Image uploaded!');
    } catch (e) {
      isUploading.value = false;
      safeSnackbar('Error', 'Upload failed: $e');
    }
  }

  Future<void> uploadVideo(String userId) async {
    if (videoFile.value == null || backgroundFile.value == null) {
      safeSnackbar('Missing file', 'Please select .mp4 and .png files');
      return;
    }
    if (userId.isEmpty) {
      safeSnackbar('Error', 'User not logged in');
      return;
    }
    try {
      isUploading.value = true;
      progress.value = 0.1;
      final videoId = "vid_${DateTime.now().millisecondsSinceEpoch}";
      final storagePath = '$userId/$videoId';
      if (!backgroundFile.value!.existsSync()) {
        throw Exception("Background file missing before upload");
      }
      final bgData = await backgroundFile.value!.readAsBytes();
      if (bgData.isEmpty) throw Exception("Background file is empty");
      await _repository.uploadFile(bucket: 'videos', path: '$storagePath/background.png', bytes: bgData, contentType: 'image/png');
      progress.value = 0.2;
      final manifestPath = await _splitMp4ToHLS(videoFile.value!);
      if (manifestPath.isEmpty) {
        throw Exception('FFmpeg HLS conversion failed');
      }
      final manifestFile = File(manifestPath);
      final hlsDir = manifestFile.parent;
      progress.value = 0.4;
      final segmentFiles =
          hlsDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.ts') || f.path.endsWith('.m3u8'))
              .toList();
      for (int i = 0; i < segmentFiles.length; i++) {
        final file = segmentFiles[i];
        final name = p.basename(file.path);
        final contentType =
            name.endsWith('.m3u8')
                ? 'application/vnd.apple.mpegurl'
                : 'video/MP2T';
        if (!file.existsSync()) continue;
        int retryCount = 0;
        bool success = false;
        while (retryCount < 3 && !success) {
          try {
            await _repository.uploadFile(bucket: 'videos', path: '$storagePath/$name', bytes: await file.readAsBytes(), contentType: contentType);
            success = true;
          } catch (e) {
            retryCount++;
            if (retryCount >= 3) rethrow;
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        progress.value = 0.4 + (0.5 * ((i + 1) / segmentFiles.length));
      }
      progress.value = 0.95;
      final url = _repository.getFileUrl('videos', '$storagePath/manifest.m3u8');
      final thumbnail = _repository.getFileUrl('videos', '$storagePath/background.png');
      String? projectFileUrl;
      if (allowRemix.value && currentProjectToUpload != null) {
        final projectJson = jsonEncode(currentProjectToUpload!.toJson());
        final projectBytes = utf8.encode(projectJson);
        final projectStoragePath = '$storagePath/project.json';
        await _repository.uploadFile(bucket: 'videos', path: projectStoragePath, bytes: projectBytes, contentType: 'application/json');
        projectFileUrl = _repository.getFileUrl('videos', projectStoragePath);
      }
      final post = PostModel(
        createdAt: DateTime.now(),
        editedAt: DateTime.now(),
        name: nameController.text.isEmpty ? "New Animation" : nameController.text,
        description: descriptionController.text,
        url: url,
        status: 1,
        userId: userId,
        views: 0,
        thumbnail: thumbnail,
        projectFileUrl: projectFileUrl,
      );
      await _repository.publishPost(post);
      progress.value = 1.0;
      isUploading.value = false;
      safeSnackbar('Success', 'Video uploaded successfully!');
    } catch (e) {
      isUploading.value = false;
      safeSnackbar('Error', 'Upload failed: $e');
    }
  }

  void safeSnackbar(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                '$title: $message',
                style: const TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
      }
    });
  }

  Future<String> _splitMp4ToHLS(File input) async {
    progress.value = 0.2;
    const segmentLength = 4;
    final docDir = await getApplicationDocumentsDirectory();
    final hlsBaseDir = Directory(p.join(docDir.path, 'hls_export'));
    if (hlsBaseDir.existsSync()) {
      await hlsBaseDir.delete(recursive: true);
    }
    await hlsBaseDir.create(recursive: true);
    final outputManifest = p.join(hlsBaseDir.path, 'manifest.m3u8');
    final args = [
      '-i', input.path,
      '-codec', 'copy',
      '-start_number', '0',
      '-hls_time', '$segmentLength',
      '-hls_list_size', '0',
      '-f', 'hls',
      outputManifest,
    ];
    progress.value = 0.3;
    final session = await FFmpegKit.executeWithArguments(args);
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      if (File(outputManifest).existsSync()) {
        return outputManifest;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}
