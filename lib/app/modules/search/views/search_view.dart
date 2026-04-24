import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/search_controller.dart' as sc;

class SearchView extends GetView<sc.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: lc.backgroundColor)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSearchBar(lc),
              _buildFilterTabs(lc),
              _buildResults(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),

          Positioned(
            top: 40,
            left: 40,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lc.cardColor.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: lc.glassBorderColor),
                ),
                child: Icon(Icons.close_rounded, color: lc.textColor, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 100, 40, 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: lc.glassColor,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: lc.glassBorderColor),
            boxShadow: [
              BoxShadow(
                color: lc.primaryColor.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: controller.searchController,
            autofocus: true,
            style: TextStyle(
              color: lc.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nghệ sĩ, tác phẩm, tài nguyên...',
              hintStyle: TextStyle(color: lc.subtextColor.withValues(alpha: 0.3)),
              border: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: lc.primaryColor, size: 32),
            ),
            onChanged: controller.updateSearch,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(LayoutController lc) {
    final filters = ['all', 'artists', 'gallery', 'assets'];
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: filters.map((f) {
            return Obx(() {
              final isSelected = controller.selectedFilter.value == f;
              return GestureDetector(
                onTap: () => controller.setFilter(f),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? lc.primaryColor : lc.glassColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    f.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : lc.subtextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResults(LayoutController lc) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: lc.primaryColor)),
        );
      }

      if (controller.searchText.value.isEmpty) {
        return _buildInitialView(lc);
      }

      return SliverList(
        delegate: SliverChildListDelegate([
          if (controller.userResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'artists'))
            _buildSectionHeader("Artists", lc, Icons.person_rounded),
          if (controller.userResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'artists'))
            _buildUsersRow(lc),

          if (controller.postResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'gallery'))
            _buildSectionHeader("Art Gallery", lc, Icons.palette_rounded),
          if (controller.postResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'gallery'))
            _buildArtGrid(lc),

          if (controller.resourceResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'assets'))
            _buildSectionHeader("Studio Assets", lc, Icons.shopping_bag_rounded),
          if (controller.resourceResults.isNotEmpty && (controller.selectedFilter.value == 'all' || controller.selectedFilter.value == 'assets'))
            _buildResourcesList(lc),
        ]),
      );
    });
  }

  Widget _buildInitialView(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.trending.isNotEmpty)
              _buildSectionTitle('TRENDING NOW', lc),
            if (controller.trending.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.trending.map((t) => _buildChip(t, lc, true)).toList(),
              ),
            if (controller.history.isNotEmpty)
              const SizedBox(height: 48),
            if (controller.history.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('RECENT', lc),
                  TextButton(
                    onPressed: controller.clearSearchHistory,
                    child: Text("Clear All", style: TextStyle(color: lc.primaryColor, fontSize: 12)),
                  ),
                ],
              ),
            if (controller.history.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.history.map((h) => _buildChip(h, lc, false)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, LayoutController lc, bool isTrending) {
    return GestureDetector(
      onTap: () => controller.selectTrending(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: lc.cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTrending) Icon(Icons.trending_up_rounded, color: lc.primaryColor, size: 14),
            if (isTrending) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: TextStyle(color: lc.primaryColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10),
      ),
    );
  }

  Widget _buildSectionHeader(String title, LayoutController lc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 24),
      child: Row(
        children: [
          Icon(icon, color: lc.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, fontFamily: 'Lexend'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersRow(LayoutController lc) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        scrollDirection: Axis.horizontal,
        itemCount: controller.userResults.length,
        itemBuilder: (context, index) {
          final user = controller.userResults[index];
          return GestureDetector(
            onTap: () => Get.toNamed('/profile/${user.id}'),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40, 
                    backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtGrid(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.4,
        ),
        itemCount: controller.postResults.length,
        itemBuilder: (context, index) {
          final post = controller.postResults[index];
          return GestureDetector(
            onTap: () => Get.toNamed(post.isVideo ? '/watch/${post.id}' : '/view/${post.id}'),
            child: Container(
              decoration: BoxDecoration(
                color: lc.glassColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: lc.glassBorderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(post.isVideo ? 'assets/video.png' : 'assets/anh.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      post.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourcesList(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: controller.resourceResults.map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: lc.cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.brush_rounded, color: lc.primaryColor),
                const SizedBox(width: 16),
                Expanded(child: Text(r.name, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold))),
                Text(r.type.toUpperCase(), style: TextStyle(color: lc.subtextColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
