import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/draw/draw_project_model.dart';
import '../../../data/models/draw/frame_model.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/services/database_service.dart';
import '../../home/controllers/home_controller.dart';

class DraftInfo {
  final String id;
  final String name;
  DraftInfo(this.id, this.name);
}

class MarketplaceController extends GetxController {
  final isLoading = true.obs;
  final categories = <String>['All', 'Palettes', 'Linearts', 'Remix Projects'].obs;
  final selectedCategory = 'all'.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
    _filterResources();
  }

  void _filterResources() {
    if (selectedCategory.value == 'all') {
      filteredResources.assignAll(allResources);
    } else {
      filteredResources.assignAll(
        allResources.where((r) => r.type == selectedCategory.value).toList(),
      );
    }
  }

  final allResources = <ResourceModel>[].obs;
  final filteredResources = <ResourceModel>[].obs;
  final ownedAssetIds = <String>{}.obs;

  final uploadTitleController = TextEditingController();
  final uploadDescController = TextEditingController();
  final uploadType = 'palette'.obs;
  final uploadThumbnailPath = ''.obs;
  final uploadPaletteColors = <Color>[].obs;
  final uploadSelectedProjectId = ''.obs;
  final isUploading = false.obs;
  final localDrafts = <DraftInfo>[].obs;
  
  
  final totalRevenue = 0.0.obs;
  final commissionRevenue = 0.0.obs;
  final resourceRevenue = 0.0.obs;
  final tipRevenue = 0.0.obs;
  final revenueHistory = <Map<String, dynamic>>[].obs;
  
  
  final activeCommissions = <Map<String, dynamic>>[].obs;
  final commissionStatus = 'open'.obs; 

  @override
  void onInit() {
    super.onInit();
    _loadOwnedAssets();
    _fetchResources();
    _loadLocalDrafts();
  }

  void _loadOwnedAssets() {
    final db = Get.find<DatabaseService>();
    final owned = db.settingsBox.get('owned_market_assets', defaultValue: <dynamic>[]);
    if (owned is List) {
      ownedAssetIds.assignAll(owned.map((e) => e.toString()).toSet());
    }
  }

  void _loadLocalDrafts() {
    final db = Get.find<DatabaseService>();
    final projects = db.drawProjectBox.values.toList();
    localDrafts.value = projects.map((p) => DraftInfo(p.id, p.name)).toList();
  }

  Future<void> pickUploadThumbnail() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      uploadThumbnailPath.value = file.path;
    }
  }

  Future<void> submitUpload() async {
    if (uploadTitleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return;
    }
    if (uploadThumbnailPath.isEmpty) {
      Get.snackbar('Error', 'Please select a preview image');
      return;
    }
    if (uploadType.value == 'palette' && uploadPaletteColors.isEmpty) {
      Get.snackbar('Error', 'Please add at least one color');
      return;
    }
    if (uploadType.value != 'palette' && uploadSelectedProjectId.isEmpty) {
      Get.snackbar('Error', 'Please select a local draft to upload');
      return;
    }

    isUploading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final authorId = user?.id ?? 'anonymous';
      final authorName = user?.userMetadata?['full_name'] ?? 'Anonymous Artist';

      final thumbPath = 'marketplace_thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('marketplace').upload(
        thumbPath,
        File(uploadThumbnailPath.value),
      );
      final thumbnailUrl = supabase.storage.from('marketplace').getPublicUrl(thumbPath);

      String? fileUrl;
      List<String>? hexColors;

      if (uploadType.value == 'palette') {
        hexColors =
            uploadPaletteColors
                .map(
                  (c) =>
                      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                )
                .toList();
      } else {
        final db = Get.find<DatabaseService>();
        final project = db.drawProjectBox.get(uploadSelectedProjectId.value);
        if (project != null) {
          final jsonString = jsonEncode(project.toJson());
          final jsonBytes = utf8.encode(jsonString);
          final filePath = 'marketplace_projects/${DateTime.now().millisecondsSinceEpoch}.json';
          await supabase.storage.from('marketplace').uploadBinary(
            filePath,
            Uint8List.fromList(jsonBytes),
            fileOptions: const FileOptions(contentType: 'application/json'),
          );
          fileUrl = supabase.storage.from('marketplace').getPublicUrl(filePath);
        }
      }

      final newResource = ResourceModel(
        id: '',
        name: uploadTitleController.text.trim(),
        type: uploadType.value,
        description: uploadDescController.text.trim(),
        authorId: authorId,
        authorName: authorName,
        thumbnailUrl: thumbnailUrl,
        fileUrl: fileUrl,
        colors: hexColors,
        downloadsCount: 0,
        createdAt: DateTime.now(),
      );

      final uploadData = newResource.toJson();
      uploadData.remove('id');
      await supabase.from('resources').insert(uploadData);

      uploadTitleController.clear();
      uploadDescController.clear();
      uploadThumbnailPath.value = '';
      uploadPaletteColors.clear();
      uploadSelectedProjectId.value = '';

      Get.back();
      Get.snackbar('Success', 'Resource published successfully!');
      _fetchResources();
    } catch (e) {
      Get.snackbar('Error', 'Upload failed: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> fetchRevenueData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      
      totalRevenue.value = 1250.0;
      commissionRevenue.value = 850.0;
      resourceRevenue.value = 400.0;
      revenueHistory.value = [
        {'month': 'Jan', 'amount': 200.0},
        {'month': 'Feb', 'amount': 450.0},
        {'month': 'Mar', 'amount': 600.0},
      ];
    } catch (e) {}
  }

  Future<void> updateCommissionStatus(String status) async {
    commissionStatus.value = status;
    
  }

  Future<void> _fetchResources() async {
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('resources').select().order('created_at', ascending: false);

      allResources.value = data.map((doc) {
        return ResourceModel.fromJson(doc);
      }).toList();

      filterResources(selectedCategory.value);
    } finally {
      isLoading.value = false;
    }
  }

  void filterResources(String category) {
    selectedCategory.value = category;
    if (category == 'All') {
      filteredResources.value = allResources;
    } else if (category == 'Palettes') {
      filteredResources.value =
          allResources.where((r) => r.type == 'palette').toList();
    } else if (category == 'Linearts') {
      filteredResources.value =
          allResources.where((r) => r.type == 'lineart').toList();
    } else if (category == 'Remix Projects') {
      filteredResources.value =
          allResources.where((r) => r.type == 'remix').toList();
    }
  }

  Future<void> downloadResource(ResourceModel resource) async {
    final resId = resource.id ?? '';

    Get.snackbar(
      'creative_hub'.tr,
      ownedAssetIds.contains(resId) 
          ? 'syncing_asset'.trArgs([resource.name])
          : 'acquiring_asset'.trArgs([resource.name]),
      backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      borderRadius: 16,
    );

    await Future.delayed(const Duration(milliseconds: 800));

    final db = Get.find<DatabaseService>();

    if (!ownedAssetIds.contains(resId) && resId.isNotEmpty) {
      ownedAssetIds.add(resId);
      final list = ownedAssetIds.toList();
      await db.settingsBox.put('owned_market_assets', list);
    }

    _dispatchAssetToModule(resource);
  }

  void _dispatchAssetToModule(ResourceModel resource) async {
    final db = Get.find<DatabaseService>();

    if (resource.type == 'palette' && resource.colors != null) {
      final List<dynamic> savedPalettes = db.settingsBox.get(
        'custom_palettes',
        defaultValue: <dynamic>[],
      );
      bool exists = savedPalettes.any((p) => p['id'] == resource.id);
      if (!exists) {
        savedPalettes.add({
          'id': resource.id,
          'name': resource.name,
          'colors': resource.colors,
        });
        await db.settingsBox.put('custom_palettes', savedPalettes);
      }
      _showSuccessNav('palette_added'.tr, 'studio');
    } 

    else if (resource.type == 'remix' || resource.type == 'lineart') {
      try {
        final String newId = 'market_${resource.id}_${DateTime.now().millisecondsSinceEpoch}';
        final newProject = DrawProjectModel(
          id: newId,
          name: '${resource.name} (${resource.type.tr})',
          updatedAt: DateTime.now(),
          frames: [FrameModel()], 
        );
        await db.drawProjectBox.put(newId, newProject);
        if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadProjects();
        _showSuccessNav('project_saved'.tr, 'studio');
      } catch (e) {
      }
    }

    else if (resource.type == 'brush' || resource.type == 'pen') {
      final List<dynamic> ownedBrushes = db.settingsBox.get('owned_brushes', defaultValue: <dynamic>[]);
      if (!ownedBrushes.any((b) => b['id'] == resource.id)) {
        ownedBrushes.add(resource.toJson());
        await db.settingsBox.put('owned_brushes', ownedBrushes);
      }
      _showSuccessNav('brush_equipped'.tr, 'studio');
    }

    else if (resource.type == 'avatar_frame' || resource.type == 'theme') {

      final List<dynamic> personaGear = db.settingsBox.get('persona_gear', defaultValue: <dynamic>[]);
      if (!personaGear.any((g) => g['id'] == resource.id)) {
        personaGear.add(resource.toJson());
        await db.settingsBox.put('persona_gear', personaGear);
      }
      _showSuccessNav('persona_unlocked'.tr, 'profile');
    }
  }

  void _showSuccessNav(String message, String target) {
    Get.snackbar(
      'Success',
      message,
      mainButton: TextButton(
        onPressed: () {

          if (target == 'studio') {
             Get.back();
          } else {
             Get.back();
          }
        },
        child: Text('go_there'.tr.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      borderRadius: 16,
    );
  }
}
