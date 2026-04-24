import 'package:flutter/material.dart';


class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? separator;
  final ScrollController? controller;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.separator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        controller: controller,
        padding: padding ?? const EdgeInsets.all(16),
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) {
          return RepaintBoundary(child: itemBuilder(context, index));
        },
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.all(16),
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(child: itemBuilder(context, index));
      },
    );
  }
}


class OptimizedSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const OptimizedSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return RepaintBoundary(child: itemBuilder(context, index));
      }, childCount: itemCount),
    );
  }
}


class OptimizedPageView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final ScrollPhysics? physics;

  const OptimizedPageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(child: itemBuilder(context, index));
      },
    );
  }
}


class OptimizedHorizontalList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const OptimizedHorizontalList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return RepaintBoundary(child: itemBuilder(context, index));
        },
      ),
    );
  }
}
