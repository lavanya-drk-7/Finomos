import 'package:flutter/material.dart';

class FinmosLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final bool showTagline;
  final bool showFooter;
  final bool isHorizontal;

  const FinmosLogo({
    super.key,
    this.size = 64.0,
    this.showTitle = true,
    this.showTagline = true,
    this.showFooter = false,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTitle && !showTagline && !showFooter) {
      return _buildIconMark();
    }

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconMark(),
          if (showTitle) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FINOMOS',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: const Color(0xFF0A2540),
                  ),
                ),
                if (showTagline)
                  Text.rich(
                    TextSpan(
                      text: 'YOUR AI PERSONAL ',
                      style: TextStyle(
                        fontSize: size * 0.16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFF0A2540),
                      ),
                      children: const [
                        TextSpan(
                          text: 'CFO',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconMark(),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text(
            'FINOMOS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.45,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              color: const Color(0xFF0A2540),
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 24, height: 1, color: const Color(0xFF0066FF).withOpacity(0.5)),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: 'YOUR AI PERSONAL ',
                  style: TextStyle(
                    fontSize: size * 0.16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: const Color(0xFF0A2540),
                  ),
                  children: const [
                    TextSpan(
                      text: 'CFO',
                      style: TextStyle(color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 24, height: 1, color: const Color(0xFF10B981).withOpacity(0.5)),
            ],
          ),
        ],
        if (showFooter) ...[
          const SizedBox(height: 10),
          Text(
            'INTELLIGENT   |   TRUSTED   |   SECURE   |   EMPOWERING',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconMark() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/app_icon.jpg',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackPainter(size),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPainter(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FinmosLogoPainter(),
      ),
    );
  }
}

class _FinmosLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final center = Offset(width / 2, height / 2);
    final radius = width / 2 - 2;

    final circlePaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF0A2540), Color(0xFF0066FF), Color(0xFF10B981), Color(0xFF0A2540)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.055
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.2,
      5.8,
      false,
      circlePaint,
    );

    final fPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A2540), Color(0xFF0066FF), Color(0xFF10B981)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(width * 0.38, height * 0.20);
    path.cubicTo(
      width * 0.55, height * 0.18,
      width * 0.78, height * 0.20,
      width * 0.85, height * 0.28,
    );
    path.cubicTo(
      width * 0.65, height * 0.34,
      width * 0.50, height * 0.35,
      width * 0.50, height * 0.40,
    );
    path.lineTo(width * 0.76, height * 0.40);
    path.cubicTo(
      width * 0.65, height * 0.48,
      width * 0.50, height * 0.52,
      width * 0.50, height * 0.55,
    );
    path.lineTo(width * 0.50, height * 0.78);
    path.cubicTo(
      width * 0.42, height * 0.78,
      width * 0.38, height * 0.70,
      width * 0.38, height * 0.55,
    );
    path.close();

    canvas.drawPath(path, fPaint);

    final starPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final starCenter = Offset(width * 0.68, height * 0.58);
    final starSize = width * 0.08;

    final Path starPath = Path();
    starPath.moveTo(starCenter.dx, starCenter.dy - starSize);
    starPath.quadraticBezierTo(starCenter.dx, starCenter.dy, starCenter.dx + starSize, starCenter.dy);
    starPath.quadraticBezierTo(starCenter.dx, starCenter.dy, starCenter.dx, starCenter.dy + starSize);
    starPath.quadraticBezierTo(starCenter.dx, starCenter.dy, starCenter.dx - starSize, starCenter.dy);
    starPath.quadraticBezierTo(starCenter.dx, starCenter.dy, starCenter.dx, starCenter.dy - starSize);
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
