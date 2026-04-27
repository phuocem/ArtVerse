import 'package:flutter/material.dart';
import 'studio_widgets.dart';

class StudioRulers extends StatelessWidget {
  const StudioRulers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0, left: 20, right: 0,
          child: Container(
            height: 20,
            color: DS.surface,
            child: Row(
              children: List.generate(28, (i) => Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border(right: BorderSide(color: DS.border, width: 0.5))),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 3, bottom: 2),
                  child: Text('${i * 64}', style: TextStyle(color: DS.textFaint, fontSize: 7, fontFamily: 'monospace')),
                ),
              )),
            ),
          ),
        ),
        Positioned(
          top: 20, left: 0, bottom: 0,
          child: Container(
            width: 20,
            color: DS.surface,
            child: Column(
              children: List.generate(18, (i) => Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: DS.border, width: 0.5))),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(top: 2, right: 2),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text('${i * 54}', style: TextStyle(color: DS.textFaint, fontSize: 7, fontFamily: 'monospace')),
                  ),
                ),
              )),
            ),
          ),
        ),
        Positioned(
          top: 0, left: 0,
          child: Container(
            width: 20, height: 20,
            color: DS.surface,
            child: Icon(Icons.crop_free_rounded, size: 10, color: DS.textFaint),
          ),
        ),
      ],
    );
  }
}