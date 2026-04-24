import 'package:flutter/material.dart';


class CachedWidget extends StatelessWidget {
  final Widget child;
  final bool addRepaintBoundary;

  const CachedWidget({
    super.key,
    required this.child,
    this.addRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (addRepaintBoundary) {
      return RepaintBoundary(child: child);
    }
    return child;
  }
}


mixin AutomaticKeepAliveWidget<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
  }
}
