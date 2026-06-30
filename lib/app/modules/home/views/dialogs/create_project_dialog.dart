import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
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
            color: layoutController.primaryColor.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
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
                          prefixIcon: Icon(
                            Icons.drive_file_rename_outline_rounded,
                            color: layoutController.primaryColor.withValues(alpha: 0.6),
                            size: 18,
                          ),
                          hintText: 'enter_project_title'.tr,
                          hintStyle: TextStyle(
                            color: layoutController.subtextColor.withValues(alpha: 0.5),
                            fontFamily: 'Lexend',
                          ),
                          filled: true,
                          fillColor: layoutController.textColor.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
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
                            child: _TypeCard(
                              title: "illustration".tr,
                              icon: Icons.brush_rounded,
                              isSelected: selectedType.value == 0,
                              onTap: () => selectedType.value = 0,
                              layoutController: layoutController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
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
          children: presets.map((p) {
            return Expanded(
              child: Obx(() {
                final isSel = selected.value == p['name'];
                return _PresetButton(
                  name: p['name'] as String,
                  icon: p['icon'] as IconData,
                  isSelected: isSel,
                  onTap: () => selected.value = p['name'] as String,
                  layoutController: lc,
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
          children: colors.map((col) {
            return Obx(() {
              final isSel = selected.value == col;
              return _ColorDot(
                color: col,
                isSelected: isSel,
                onTap: () => selected.value = col,
                layoutController: lc,
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
          child: _DialogCancelBtn(
            onTap: () => Navigator.of(context).pop(),
            layoutController: layoutController,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _DialogCreateBtn(
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
            layoutController: layoutController,
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
                items: items.map((val) {
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
}

class _TypeCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final LayoutController layoutController;

  const _TypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.layoutController,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = widget.layoutController;
    final isSelected = widget.isSelected;
    final activeColor = lc.primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.08)
                  : (_isHovered
                      ? lc.textColor.withValues(alpha: 0.04)
                      : lc.textColor.withValues(alpha: 0.02)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : (_isHovered
                        ? activeColor.withValues(alpha: 0.3)
                        : lc.textColor.withValues(alpha: 0.08)),
                width: isSelected ? 2 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 32,
                    color: isSelected ? activeColor : lc.subtextColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? lc.textColor : lc.subtextColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatefulWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final LayoutController layoutController;

  const _PresetButton({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.layoutController,
  });

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = widget.layoutController;
    final isSel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSel
                  ? lc.primaryColor.withValues(alpha: 0.1)
                  : (_isHovered
                      ? lc.textColor.withValues(alpha: 0.06)
                      : lc.textColor.withValues(alpha: 0.02)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSel
                    ? lc.primaryColor
                    : (_isHovered
                        ? lc.primaryColor.withValues(alpha: 0.3)
                        : Colors.transparent),
                width: 1.2,
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: lc.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  color: isSel ? lc.primaryColor : lc.subtextColor.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: lc.textColor,
                    fontSize: 10,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final LayoutController layoutController;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.layoutController,
  });

  @override
  State<_ColorDot> createState() => _ColorDotState();
}

class _ColorDotState extends State<_ColorDot> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = widget.layoutController;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.15 : (_isHovered ? 1.08 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isSelected
                    ? lc.primaryColor
                    : lc.textColor.withValues(alpha: 0.15),
                width: widget.isSelected ? 3 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: lc.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogCancelBtn extends StatefulWidget {
  final VoidCallback onTap;
  final LayoutController layoutController;
  const _DialogCancelBtn({required this.onTap, required this.layoutController});

  @override
  State<_DialogCancelBtn> createState() => _DialogCancelBtnState();
}

class _DialogCancelBtnState extends State<_DialogCancelBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: _isHovered ? widget.layoutController.textColor.withValues(alpha: 0.04) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          "discard".tr,
          style: TextStyle(
            color: widget.layoutController.subtextColor,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }
}

class _DialogCreateBtn extends StatefulWidget {
  final VoidCallback onTap;
  final LayoutController layoutController;
  const _DialogCreateBtn({required this.onTap, required this.layoutController});

  @override
  State<_DialogCreateBtn> createState() => _DialogCreateBtnState();
}

class _DialogCreateBtnState extends State<_DialogCreateBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = widget.layoutController;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            gradient: lc.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: lc.primaryColor.withValues(alpha: _isHovered ? 0.45 : 0.25),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
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
    );
  }
}
