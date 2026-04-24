import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/draw/draw_project_model.dart';
import '../../../../data/models/draw/frame_model.dart';
import '../../../layout/controllers/layout_controller.dart';

class CreateProjectDialog extends StatelessWidget {
  final dynamic controller;
  final int initialType;
  const CreateProjectDialog({super.key, required this.controller, this.initialType = 0});

  @override
  Widget build(BuildContext context) {
    final selectedType = initialType.obs;
    final selectedPreset = 'HD (16:9)'.obs;
    final selectedColor = Rx<Color>(controller.canvasBackgroundColor.value);
    final layoutController = Get.find<LayoutController>();
    final nameController = TextEditingController(text: 'untitled_project'.tr);

    return Obx(() => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: layoutController.surfaceColor,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.45,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: layoutController.textColor.withValues(alpha: 0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "launch_masterpiece".tr,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Lexend',
                  color: layoutController.textColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "create_new_canvas_desc".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  color: layoutController.subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          color: layoutController.textColor,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter_project_title'.tr,
                          hintStyle: TextStyle(
                            color: layoutController.subtextColor.withValues(alpha: 0.5),
                            fontFamily: 'Lexend',
                          ),
                          filled: true,
                          fillColor: layoutController.textColor.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 24,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: layoutController.textColor.withValues(alpha: 0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: layoutController.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeCard(
                              title: "illustration".tr,
                              icon: Icons.brush_rounded,
                              isSelected: selectedType.value == 0,
                              onTap: () => selectedType.value = 0,
                              layoutController: layoutController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeCard(
                              title: "animations".tr,
                              icon: Icons.movie_creation_rounded,
                              isSelected: selectedType.value == 1,
                              onTap: () => selectedType.value = 1,
                              layoutController: layoutController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPresetGrid(selectedPreset, layoutController),
                      const SizedBox(height: 24),
                      _buildColorPickerRow(selectedColor, layoutController),
                      const SizedBox(height: 24),
                      selectedType.value == 1
                          ? _buildAnimationSettings(
                            context,
                            layoutController,
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildActions(
                context,
                nameController,
                selectedType,
                layoutController,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildAnimationSettings(
    BuildContext context,
    LayoutController layoutController,
  ) {
    return Column(
      children: [
        _buildDropdownTile(
          context: context,
          title: "fps".tr,
          subtitle: "fps_desc".tr,
          valueRx: controller.fps,
          items: controller.fpsOptions,
          layoutController: layoutController,
        ),
        const SizedBox(height: 16),
        _buildDropdownTile(
          context: context,
          title: "onion_skinning".tr,
          subtitle: "onion_skinning_desc".tr,
          valueRx: controller.onionSkin,
          items: controller.onionSkinOptions,
          layoutController: layoutController,
        ),
      ],
    );
  }

  Widget _buildPresetGrid(RxString selected, LayoutController lc) {
    final presets = [
      {'name': 'HD (16:9)', 'icon': Icons.rectangle_outlined},
      {'name': 'Square', 'icon': Icons.crop_square_rounded},
      {'name': '4K Master', 'icon': Icons.high_quality_rounded},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("canvas_preset".tr, lc),
        const SizedBox(height: 12),
        Row(
          children:
              presets.map((p) {
                return Expanded(
                  child: Obx(() {
                    final isSel = selected.value == p['name'];
                    return GestureDetector(
                      onTap: () => selected.value = p['name'] as String,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSel
                                  ? lc.primaryColor.withValues(alpha: 0.1)
                                  : lc.textColor.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? lc.primaryColor : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              p['icon'] as IconData,
                              color: isSel ? lc.primaryColor : lc.subtextColor,
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p['name'] as String,
                              style: TextStyle(
                                color: lc.textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow(Rx<Color> selected, LayoutController lc) {
    final colors = [
      Colors.white,
      const Color(0xFFF3F4F6),
      const Color(0xFFE5E7EB),
      const Color(0xFF1F2937),
      Colors.black,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("initial_canvas_color".tr, lc),
        const SizedBox(height: 12),
        Row(
          children:
              colors.map((col) {
                return Obx(() {
                  final isSel = selected.value == col;
                  return GestureDetector(
                    onTap: () => selected.value = col,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSel
                                  ? lc.primaryColor
                                  : lc.textColor.withValues(alpha: 0.1),
                          width: isSel ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, LayoutController lc) {
    return Text(
      text,
      style: TextStyle(
        color: lc.primaryColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        fontFamily: 'Lexend',
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    TextEditingController nameController,
    RxInt selectedType,
    LayoutController layoutController,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "discard".tr,
              style: TextStyle(
                color: layoutController.subtextColor,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: layoutController.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: layoutController.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  
                  final newProject = DrawProjectModel(
                    id: const Uuid().v4(),
                    name: name,
                    updatedAt: DateTime.now(),
                    frames: [FrameModel()],
                    isAnimation: selectedType.value == 1,
                  );
                  controller.addProject(newProject);
                  Navigator.of(context).pop(newProject);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "start_creating".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required RxInt valueRx,
    required List<int> items,
    required LayoutController layoutController,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: layoutController.textColor.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: layoutController.textColor.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Lexend',
                      color: layoutController.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Lexend',
                      color: layoutController.subtextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: layoutController.textColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: valueRx.value,
                isExpanded: false,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: layoutController.primaryColor,
                ),
                dropdownColor: layoutController.surfaceColor,
                onChanged: (value) => valueRx.value = value!,
                items:
                    items.map((val) {
                      return DropdownMenuItem<int>(
                        value: val,
                        child: Text(
                          val.toString(),
                          style: TextStyle(
                            color: layoutController.textColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required LayoutController layoutController,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? layoutController.primaryColor.withValues(alpha: 0.08)
                  : layoutController.textColor.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected
                    ? layoutController.primaryColor
                    : layoutController.textColor.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: layoutController.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  isSelected
                      ? layoutController.primaryColor
                      : layoutController.subtextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Lexend',
                color:
                    isSelected
                        ? layoutController.textColor
                        : layoutController.subtextColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
