import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../theme/app_colors.dart';

class PatternInput extends StatefulWidget {
  const PatternInput({
    required this.onCompleted,
    super.key,
    this.enabled = true,
    this.size = 280,
  });

  final ValueChanged<List<int>> onCompleted;
  final bool enabled;
  final double size;

  @override
  State<PatternInput> createState() => _PatternInputState();
}

class _PatternInputState extends State<PatternInput> {
  final List<int> _selected = [];
  Offset? _pointer;

  List<Offset> _centers(Size size) => [
    for (var row = 0; row < 3; row++)
      for (var column = 0; column < 3; column++)
        Offset(
          size.width * (.18 + column * .32),
          size.height * (.18 + row * .32),
        ),
  ];

  void _update(Offset position, Size size) {
    if (!widget.enabled) {
      return;
    }
    final centers = _centers(size);
    var changed = false;
    for (var index = 0; index < centers.length; index++) {
      if (!_selected.contains(index) &&
          (centers[index] - position).distance <= size.width * .105) {
        _selected.add(index);
        changed = true;
        break;
      }
    }
    setState(() {
      _pointer = position;
      if (changed) {
        Feedback.forTap(context);
      }
    });
  }

  void _finish() {
    if (!widget.enabled) {
      return;
    }
    final completed = List<int>.unmodifiable(_selected);
    setState(() => _pointer = null);
    if (completed.isNotEmpty) {
      widget.onCompleted(completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.patternLockDescription,
      child: SizedBox.square(
        dimension: widget.size,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) => _update(details.localPosition, size),
              onPanUpdate: (details) => _update(details.localPosition, size),
              onPanEnd: (_) => _finish(),
              child: CustomPaint(
                painter: _PatternPainter(
                  centers: _centers(size),
                  selected: _selected,
                  pointer: _pointer,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({
    required this.centers,
    required this.selected,
    required this.pointer,
  });

  final List<Offset> centers;
  final List<int> selected;
  final Offset? pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (selected.isNotEmpty) {
      final path = Path()
        ..moveTo(centers[selected.first].dx, centers[selected.first].dy);
      for (final index in selected.skip(1)) {
        path.lineTo(centers[index].dx, centers[index].dy);
      }
      if (pointer != null) {
        path.lineTo(pointer!.dx, pointer!.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (var index = 0; index < centers.length; index++) {
      final isSelected = selected.contains(index);
      canvas.drawCircle(
        centers[index],
        isSelected ? 18 : 14,
        Paint()
          ..color = isSelected ? AppColors.cyan : AppColors.surfaceHighest
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        centers[index],
        isSelected ? 18 : 14,
        Paint()
          ..color = isSelected ? AppColors.cyan : AppColors.outline
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.pointer != pointer ||
      oldDelegate.selected.length != selected.length;
}
