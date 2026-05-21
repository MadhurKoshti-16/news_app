import 'package:flutter/material.dart';

class AnimatedNewsTicker extends StatefulWidget {
  const AnimatedNewsTicker({
    super.key,
    required this.headlines,
    this.speed = 60.0,
    this.textStyle,
    this.backgroundColor,
    this.separatorText = '   •   ',
  });

  final List<String> headlines;

  final double speed;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final String separatorText;

  @override
  State<AnimatedNewsTicker> createState() => _AnimatedNewsTickerState();
}

class _AnimatedNewsTickerState extends State<AnimatedNewsTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _fullText = '';

  @override
  void initState() {
    super.initState();
    _buildFullText();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
  }

  @override
  void didUpdateWidget(AnimatedNewsTicker old) {
    super.didUpdateWidget(old);
    if (old.headlines != widget.headlines) {
      _buildFullText();
      _startAnimation();
    }
  }

  void _buildFullText() {
    if (widget.headlines.isEmpty) {
      _fullText = '';
      return;
    }
    _fullText =
        widget.headlines.join(widget.separatorText) + widget.separatorText;
  }

  TextStyle _resolvedStyle(BuildContext context) {
    return widget.textStyle ??
        Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        );
  }

  double _measureTextWidth(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: _fullText, style: _resolvedStyle(context)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  void _startAnimation() {
    if (!mounted || _fullText.isEmpty) return;
    final textWidth = _measureTextWidth(context);
    if (textWidth <= 0) return;

    final seconds = textWidth / widget.speed;
    _controller.duration = Duration(milliseconds: (seconds * 1000).round());
    _controller
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headlines.isEmpty) return const SizedBox.shrink();

    final bgColor =
        widget.backgroundColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    final style = _resolvedStyle(context);
    final badgeColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 36,
      child: ColoredBox(
        color: bgColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: badgeColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    'LIVE',
                    style: style.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _TickerPainter(
                        text: _fullText,
                        style: style,
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  _TickerPainter({
    required this.text,
    required this.style,
    required this.progress,
  });

  final String text;
  final TextStyle style;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Measure the text
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textWidth = tp.width;
    if (textWidth <= 0) return;

    // Scroll from right-to-left.
    // At progress=0 text starts at the right edge (x = size.width).
    // At progress=1 it has scrolled left by one full text width.
    final startX = size.width - progress * textWidth;

    tp.paint(canvas, Offset(startX, (size.height - tp.height) / 2));
    tp.paint(canvas, Offset(startX + textWidth, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_TickerPainter old) =>
      old.progress != progress || old.text != text;
}
