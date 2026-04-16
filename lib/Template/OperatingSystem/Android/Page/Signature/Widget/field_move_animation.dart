import 'package:flutter/material.dart';

class FieldMoveAnimation extends StatefulWidget {
  const FieldMoveAnimation({super.key});

  @override
  State<FieldMoveAnimation> createState() => _FieldMoveAnimationState();
}

class _FieldMoveAnimationState extends State<FieldMoveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animation sequences
  late Animation<double> _handOpacity;
  late Animation<Offset> _handPosition;
  late Animation<double> _fieldScale;
  late Animation<Offset> _fieldPosition;
  late Animation<double> _scrollOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _setupAnimations();
  }

  void _setupAnimations() {
    // 0.0 - 0.2: Hand appearing and moving to field
    // 0.2 - 0.3: Scaling (Long press simulation)
    // 0.3 - 0.5: Dragging within page 1
    // 0.5 - 0.8: Dragging to page 2 (with scrolling)
    // 0.8 - 0.9: Dropping and hand fading
    // 0.9 - 1.0: Pause

    _handOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
    ]).animate(_controller);

    _handPosition = TweenSequence([
      // Move to field
      TweenSequenceItem(
        tween: Tween(begin: const Offset(150, 200), end: const Offset(120, 80)),
        weight: 20,
      ),
      // Hold
      TweenSequenceItem(
        tween: ConstantTween(const Offset(120, 80)),
        weight: 10,
      ),
      // Drag within page 1
      TweenSequenceItem(
        tween: Tween(begin: const Offset(120, 80), end: const Offset(60, 120)),
        weight: 20,
      ),
      // Drag to page 2 (absolute coordinates)
      TweenSequenceItem(
        tween: Tween(begin: const Offset(60, 120), end: const Offset(100, 280)),
        weight: 30,
      ),
      // drop
      TweenSequenceItem(
        tween: ConstantTween(const Offset(100, 280)),
        weight: 20,
      ),
    ]).animate(_controller);

    _fieldPosition = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(const Offset(120, 80)),
        weight: 30,
      ),
      // Drag within page
      TweenSequenceItem(
        tween: Tween(begin: const Offset(120, 80), end: const Offset(60, 120)),
        weight: 20,
      ),
      // Drag to page 2
      TweenSequenceItem(
        tween: Tween(begin: const Offset(60, 120), end: const Offset(100, 280)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(const Offset(100, 280)),
        weight: 20,
      ),
    ]).animate(_controller);

    _fieldScale = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.15), weight: 50),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 10),
    ]).animate(_controller);

    _scrollOffset = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 50),
      // Scroll down as we drag to page 2
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 160.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(160.0), weight: 20),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Simulated Pages
              Positioned(
                top: 20 - _scrollOffset.value,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _buildSimulatedPage('Page 1', cs),
                    const SizedBox(height: 12),
                    _buildSimulatedPage('Page 2', cs),
                  ],
                ),
              ),

              // The Field
              Positioned(
                left: _fieldPosition.value.dx,
                top: _fieldPosition.value.dy - _scrollOffset.value,
                child: Transform.scale(
                  scale: _fieldScale.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.draw, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Sign',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // The Hand/Indicator
              Positioned(
                left: _handPosition.value.dx + 25,
                top: _handPosition.value.dy + 15 - _scrollOffset.value,
                child: Opacity(
                  opacity: _handOpacity.value,
                  child: _buildHand(cs),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSimulatedPage(String label, ColorScheme cs) {
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Simulated lines
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80, height: 6, color: cs.surfaceContainerHigh),
                const SizedBox(height: 8),
                Container(width: 110, height: 4, color: cs.surfaceContainer),
                const SizedBox(height: 4),
                Container(width: 110, height: 4, color: cs.surfaceContainer),
                const SizedBox(height: 4),
                Container(width: 90, height: 4, color: cs.surfaceContainer),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 8, color: cs.outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHand(ColorScheme cs) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(child: Icon(Icons.touch_app, color: cs.primary, size: 24)),
    );
  }
}
