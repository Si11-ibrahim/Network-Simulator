import 'package:flutter/material.dart';

/// A widget that provides an in-context tutorial for a specific UI element
class ElementTutorial extends StatelessWidget {
  /// The key of the UI element to highlight
  final GlobalKey targetKey;

  /// The title of the tutorial
  final String title;

  /// The description text
  final String description;

  /// The position of the tooltip relative to the target element
  final ElementTutorialPosition position;

  /// Optional callback when the tutorial is dismissed
  final VoidCallback? onDismiss;

  const ElementTutorial({
    super.key,
    required this.targetKey,
    required this.title,
    required this.description,
    this.position = ElementTutorialPosition.bottom,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Find the target element's position
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    // Calculate tooltip position
    Offset tooltipPosition;
    AlignmentGeometry alignment;

    switch (position) {
      case ElementTutorialPosition.top:
        tooltipPosition = Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy - 8,
        );
        alignment = Alignment.bottomCenter;
        break;
      case ElementTutorialPosition.bottom:
        tooltipPosition = Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height + 8,
        );
        alignment = Alignment.topCenter;
        break;
      case ElementTutorialPosition.left:
        tooltipPosition = Offset(
          targetPosition.dx - 8,
          targetPosition.dy + targetSize.height / 2,
        );
        alignment = Alignment.centerRight;
        break;
      case ElementTutorialPosition.right:
        tooltipPosition = Offset(
          targetPosition.dx + targetSize.width + 8,
          targetPosition.dy + targetSize.height / 2,
        );
        alignment = Alignment.centerLeft;
        break;
    }

    return Stack(
      children: [
        // Semi-transparent overlay that highlights the target element
        Positioned.fill(
          child: CustomPaint(
            painter: _HighlightPainter(
              targetRect: Rect.fromLTWH(
                targetPosition.dx,
                targetPosition.dy,
                targetSize.width,
                targetSize.height,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Tooltip with tutorial content
        Positioned(
          left: tooltipPosition.dx,
          top: tooltipPosition.dy,
          child: FractionalTranslation(
            translation: _getTranslationOffset(position),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          InkWell(
                            onTap: onDismiss,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onDismiss,
                          child: const Text('Got it'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _getTranslationOffset(ElementTutorialPosition position) {
    switch (position) {
      case ElementTutorialPosition.top:
        return const Offset(-0.5, -1.0);
      case ElementTutorialPosition.bottom:
        return const Offset(-0.5, 0.0);
      case ElementTutorialPosition.left:
        return const Offset(-1.0, -0.5);
      case ElementTutorialPosition.right:
        return const Offset(0.0, -0.5);
    }
  }
}

/// Custom painter that creates a "cut-out" effect to highlight a UI element
class _HighlightPainter extends CustomPainter {
  final Rect targetRect;
  final BorderRadius borderRadius;

  _HighlightPainter({
    required this.targetRect,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create a path that covers the entire screen except for the target element
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndCorners(
        targetRect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw a highlight around the target element
    final highlightPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        targetRect.inflate(4),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        borderRadius != oldDelegate.borderRadius;
  }
}

/// Position of the tutorial tooltip relative to the target element
enum ElementTutorialPosition {
  top,
  bottom,
  left,
  right,
}
