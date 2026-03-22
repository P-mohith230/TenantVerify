import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:project/theme.dart';

/// Floating particles background animation
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final Widget? child;

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.particleColor = AppColors.neonGreen,
    this.child,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _particles = List.generate(widget.particleCount, (_) => _createParticle());
  }

  Particle _createParticle() => Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.1,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.particleColor,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class Particle {
  double x, y, size, speed, opacity;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final y = (particle.y + progress * particle.speed) % 1.0;
      final x = particle.x + math.sin(progress * math.pi * 2 + particle.y * 10) * 0.02;
      
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// Typewriter text animation effect
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration startDelay;
  final bool showCursor;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 50),
    this.startDelay = Duration.zero,
    this.showCursor = true,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
      vsync: this,
    );

    _charCount = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    Future.delayed(widget.startDelay, () {
      if (mounted) {
        _controller.forward().then((_) => widget.onComplete?.call());
      }
    });

    // Cursor blink
    if (widget.showCursor) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() => _showCursor = !_showCursor);
          return true;
        }
        return false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _charCount.value);
        final cursor = widget.showCursor && _showCursor ? '▌' : ' ';
        return Text(
          '$displayText$cursor',
          style: widget.style,
        );
      },
    );
  }
}

/// Animated gradient border container
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;
  final List<Color>? colors;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = AppRadius.lg,
    this.duration = const Duration(seconds: 3),
    this.colors,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AppColors.neonGreen,
          AppColors.electricBlue,
          AppColors.cyberPurple,
          AppColors.neonGreen,
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _controller.value,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            colors: colors,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final gradient = SweepGradient(
      colors: colors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Pulsing glow effect
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minGlow;
  final double maxGlow;
  final Duration duration;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.neonGreen,
    this.minGlow = 10,
    this.maxGlow = 30,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: widget.minGlow,
      end: widget.maxGlow,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.5),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 4,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Staggered fade-in animation for lists
class StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * widget.delay.inMilliseconds), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Scale on hover effect
class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.03,
    this.duration = const Duration(milliseconds: 200),
    this.onTap,
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = AppRadius.md,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(-0.5 + 2 * _controller.value, 0),
              colors: [
                AppColors.surfaceLight,
                AppColors.surfaceLighter,
                AppColors.surfaceLight,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rotating blockchain nodes animation
class BlockchainNodes extends StatefulWidget {
  final double size;
  final int nodeCount;
  final Duration duration;

  const BlockchainNodes({
    super.key,
    this.size = 200,
    this.nodeCount = 6,
    this.duration = const Duration(seconds: 15),
  });

  @override
  State<BlockchainNodes> createState() => _BlockchainNodesState();
}

class _BlockchainNodesState extends State<BlockchainNodes>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateController, _pulseController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BlockchainNodesPainter(
              rotation: _rotateController.value,
              pulse: _pulseController.value,
              nodeCount: widget.nodeCount,
            ),
          ),
        );
      },
    );
  }
}

class _BlockchainNodesPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final int nodeCount;

  _BlockchainNodesPainter({
    required this.rotation,
    required this.pulse,
    required this.nodeCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw connection lines
    final linePaint = Paint()
      ..color = AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * pulse)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw outer ring
    final ringPaint = Paint()
      ..color = AppColors.electricBlue.withValues(alpha: 0.2 + 0.1 * pulse)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw nodes and connections
    final nodePositions = <Offset>[];
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i * 2 * math.pi / nodeCount) + (rotation * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      nodePositions.add(Offset(x, y));
    }

    // Draw connections between nodes
    for (int i = 0; i < nodeCount; i++) {
      for (int j = i + 1; j < nodeCount; j++) {
        canvas.drawLine(nodePositions[i], nodePositions[j], linePaint);
      }
    }

    // Draw nodes
    for (int i = 0; i < nodeCount; i++) {
      final pos = nodePositions[i];
      
      // Glow effect
      final glowPaint = Paint()
        ..color = AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 5 * pulse);
      canvas.drawCircle(pos, 8, glowPaint);

      // Node
      final nodePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.neonGreen, AppColors.electricBlue],
        ).createShader(Rect.fromCircle(center: pos, radius: 8));
      canvas.drawCircle(pos, 6, nodePaint);

      // Inner circle
      final innerPaint = Paint()..color = AppColors.background;
      canvas.drawCircle(pos, 3, innerPaint);
    }

    // Draw center node
    final centerGlowPaint = Paint()
      ..color = AppColors.neonGreen.withValues(alpha: 0.5 + 0.3 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + 10 * pulse);
    canvas.drawCircle(center, 20, centerGlowPaint);

    final centerGradient = Paint()
      ..shader = AppColors.neonGradient.createShader(
        Rect.fromCircle(center: center, radius: 18),
      );
    canvas.drawCircle(center, 18, centerGradient);

    // Shield icon simulation
    final iconPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(center.dx, center.dy - 8)
      ..lineTo(center.dx + 7, center.dy - 4)
      ..lineTo(center.dx + 7, center.dy + 4)
      ..quadraticBezierTo(center.dx + 7, center.dy + 8, center.dx, center.dy + 10)
      ..quadraticBezierTo(center.dx - 7, center.dy + 8, center.dx - 7, center.dy + 4)
      ..lineTo(center.dx - 7, center.dy - 4)
      ..close();
    
    canvas.drawPath(path, iconPaint);
  }

  @override
  bool shouldRepaint(_BlockchainNodesPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
}

/// Scanning line effect for verification
class ScanningLine extends StatefulWidget {
  final double height;
  final Duration duration;
  final Color color;

  const ScanningLine({
    super.key,
    this.height = 200,
    this.duration = const Duration(seconds: 2),
    this.color = AppColors.neonGreen,
  });

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              Positioned(
                top: _controller.value * widget.height,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        widget.color.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Counter animation for stats
class AnimatedCounter extends StatefulWidget {
  final int value;
  final String prefix;
  final String suffix;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1500),
    this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toInt()}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Data flow animation between nodes
class DataFlowLine extends StatefulWidget {
  final double width;
  final Color color;
  final Duration duration;

  const DataFlowLine({
    super.key,
    this.width = 100,
    this.color = AppColors.neonGreen,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<DataFlowLine> createState() => _DataFlowLineState();
}

class _DataFlowLineState extends State<DataFlowLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, 4),
          painter: _DataFlowPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _DataFlowPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DataFlowPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Background line
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      bgPaint,
    );

    // Animated dot
    final dotX = progress * size.width;
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(dotX, size.height / 2), 4, dotPaint);

    // Trail
    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, color],
      ).createShader(Rect.fromLTWH(dotX - 30, 0, 30, size.height));
    canvas.drawLine(
      Offset(math.max(0, dotX - 30), size.height / 2),
      Offset(dotX, size.height / 2),
      trailPaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_DataFlowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Glitch text effect
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const GlitchText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shouldGlitch = _random.nextDouble() > 0.95;
        final offset = shouldGlitch ? _random.nextDouble() * 3 - 1.5 : 0.0;

        return Stack(
          children: [
            // Cyan offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(-offset, 0),
                child: Text(
                  widget.text,
                  style: widget.style?.copyWith(
                    color: AppColors.electricBlue.withValues(alpha: 0.7),
                  ),
                ),
              ),
            // Red offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(offset, 0),
                child: Text(
                  widget.text,
                  style: widget.style?.copyWith(
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                ),
              ),
            // Main text
            Text(widget.text, style: widget.style),
          ],
        );
      },
    );
  }
}
