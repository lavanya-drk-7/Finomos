import 'package:flutter/material.dart';

enum BankBrand {
  sbi,
  hdfc,
  icici,
  axis,
  kotak,
  pnb,
  bob,
  canara,
  unionBank,
  indusind,
  federal,
  idfc,
  paytm,
  gpay,
  phonepe,
  bhim,
  amex,
  stanchart,
  rbl,
  cash,
  generic,
}

/// Identifies bank brand from text name
BankBrand detectBankBrand(String name) {
  final l = name.toLowerCase();
  if (l.contains('sbi') || l.contains('state bank')) return BankBrand.sbi;
  if (l.contains('hdfc')) return BankBrand.hdfc;
  if (l.contains('icici')) return BankBrand.icici;
  if (l.contains('axis')) return BankBrand.axis;
  if (l.contains('kotak')) return BankBrand.kotak;
  if (l.contains('punjab') || l.contains('pnb')) return BankBrand.pnb;
  if (l.contains('baroda') || l.contains('bob')) return BankBrand.bob;
  if (l.contains('canara')) return BankBrand.canara;
  if (l.contains('union bank')) return BankBrand.unionBank;
  if (l.contains('indusind')) return BankBrand.indusind;
  if (l.contains('federal')) return BankBrand.federal;
  if (l.contains('idfc')) return BankBrand.idfc;
  if (l.contains('paytm')) return BankBrand.paytm;
  if (l.contains('google pay') || l.contains('gpay') || l.contains('okhdfcbank')) return BankBrand.gpay;
  if (l.contains('phonepe') || l.contains('ybl')) return BankBrand.phonepe;
  if (l.contains('bhim')) return BankBrand.bhim;
  if (l.contains('american express') || l.contains('amex')) return BankBrand.amex;
  if (l.contains('standard chartered') || l.contains('stanchart')) return BankBrand.stanchart;
  if (l.contains('rbl')) return BankBrand.rbl;
  if (l.contains('cash') || l.contains('wallet')) return BankBrand.cash;
  return BankBrand.generic;
}

/// A dedicated widget that renders high-precision vector logos for Indian & global banks
class BankLogo extends StatelessWidget {
  final String bankName;
  final double size;
  final bool showBorder;
  final BorderRadius? borderRadius;

  const BankLogo({
    super.key,
    required this.bankName,
    this.size = 24.0,
    this.showBorder = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final brand = detectBankBrand(bankName);
    final radius = borderRadius ?? BorderRadius.circular(size * 0.28);

    Widget logoMark;
    switch (brand) {
      case BankBrand.sbi:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _SbiLogoPainter(),
        );
        break;
      case BankBrand.hdfc:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _HdfcLogoPainter(),
        );
        break;
      case BankBrand.icici:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _IciciLogoPainter(),
        );
        break;
      case BankBrand.axis:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _AxisLogoPainter(),
        );
        break;
      case BankBrand.kotak:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _KotakLogoPainter(),
        );
        break;
      case BankBrand.pnb:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _PnbLogoPainter(),
        );
        break;
      case BankBrand.bob:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _BobLogoPainter(),
        );
        break;
      case BankBrand.canara:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _CanaraLogoPainter(),
        );
        break;
      case BankBrand.unionBank:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _UnionBankLogoPainter(),
        );
        break;
      case BankBrand.indusind:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _IndusindLogoPainter(),
        );
        break;
      case BankBrand.federal:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _FederalLogoPainter(),
        );
        break;
      case BankBrand.idfc:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _IdfcLogoPainter(),
        );
        break;
      case BankBrand.paytm:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _PaytmLogoPainter(),
        );
        break;
      case BankBrand.gpay:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _GPayLogoPainter(),
        );
        break;
      case BankBrand.phonepe:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _PhonePeLogoPainter(),
        );
        break;
      case BankBrand.bhim:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _BhimLogoPainter(),
        );
        break;
      case BankBrand.amex:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _AmexLogoPainter(),
        );
        break;
      case BankBrand.stanchart:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _StanChartLogoPainter(),
        );
        break;
      case BankBrand.rbl:
        logoMark = CustomPaint(
          size: Size(size, size),
          painter: const _RblLogoPainter(),
        );
        break;
      case BankBrand.cash:
        logoMark = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.payments_outlined, size: size * 0.58, color: Colors.white),
        );
        break;
      case BankBrand.generic:
        logoMark = _buildGenericBankLogo(bankName, size);
        break;
    }

    if (!showBorder) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(borderRadius: radius, child: logoMark),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(borderRadius: radius, child: logoMark),
    );
  }

  static Widget _buildGenericBankLogo(String name, double size) {
    final clean = name.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
    final words = clean.split(' ').where((w) => w.isNotEmpty).toList();
    String initials = 'BK';
    if (words.isNotEmpty) {
      if (words.length >= 2) {
        initials = '${words[0][0]}${words[1][0]}'.toUpperCase();
      } else {
        initials = words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Renders bank name alongside the bank's authentic logo
class BankNameWithLogo extends StatelessWidget {
  final String bankName;
  final double logoSize;
  final TextStyle? textStyle;
  final double spacing;
  final bool isExpanded;
  final TextOverflow overflow;

  const BankNameWithLogo({
    super.key,
    required this.bankName,
    this.logoSize = 20.0,
    this.textStyle,
    this.spacing = 8.0,
    this.isExpanded = false,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final logo = BankLogo(bankName: bankName, size: logoSize);
    final text = Text(
      bankName,
      style: textStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A2540)),
      overflow: overflow,
    );

    if (isExpanded) {
      return Row(
        children: [
          logo,
          SizedBox(width: spacing),
          Expanded(child: text),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        SizedBox(width: spacing),
        text,
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HIGH-PRECISION CUSTOM PAINTERS FOR BANK LOGOS
// -----------------------------------------------------------------------------

/// State Bank of India (Official Blue Circle with White Keyhole Slot)
class _SbiLogoPainter extends CustomPainter {
  const _SbiLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2;

    // Outer SBI Blue circle (#0072BC)
    final bgPaint = Paint()
      ..color = const Color(0xFF0072BC)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Center circular cutout
    final innerR = radius * 0.28;
    canvas.drawCircle(Offset(cx, cy), innerR, whitePaint);

    // Vertical slit running down from center cutout to bottom edge
    final slitWidth = radius * 0.16;
    final slitRect = Rect.fromLTRB(
      cx - slitWidth / 2,
      cy,
      cx + slitWidth / 2,
      size.height,
    );
    canvas.drawRect(slitRect, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// HDFC Bank (Official Blue Frame with Red Central Geometric Block)
class _HdfcLogoPainter extends CustomPainter {
  const _HdfcLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background deep HDFC navy blue (#004B87)
    final bgPaint = Paint()
      ..color = const Color(0xFF004B87)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(rrect, bgPaint);

    // Inner white frame
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final pad = w * 0.20;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2),
        Radius.circular(w * 0.08),
      ),
      whitePaint,
    );

    // Center red square (#ED232A)
    final redPaint = Paint()
      ..color = const Color(0xFFED232A)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final redPad = w * 0.35;
    canvas.drawRect(
      Rect.fromLTWH(redPad, redPad, w - redPad * 2, h - redPad * 2),
      redPaint,
    );

    // 4 blue corner squares recreating the interlocking geometric cross
    final cornerSize = (w - pad * 2) * 0.28;
    canvas.drawRect(Rect.fromLTWH(pad, pad, cornerSize, cornerSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(w - pad - cornerSize, pad, cornerSize, cornerSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(pad, h - pad - cornerSize, cornerSize, cornerSize), bgPaint);
    canvas.drawRect(Rect.fromLTWH(w - pad - cornerSize, h - pad - cornerSize, cornerSize, cornerSize), bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ICICI Bank (Iconic Maroon & Orange Flame with stylized 'i')
class _IciciLogoPainter extends CustomPainter {
  const _IciciLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Gradient background: Maroon to Orange
    final gradPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9E1B26), Color(0xFFF37021)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, gradPaint);

    // Dot of 'i' in golden yellow
    final dotPaint = Paint()
      ..color = const Color(0xFFFDB813)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy - r * 0.35), r * 0.17, dotPaint);

    // White stylized stem of 'i'
    final stemPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(cx, cy - r * 0.05);
    path.lineTo(cx, cy + r * 0.32);
    path.quadraticBezierTo(cx, cy + r * 0.54, cx + r * 0.28, cy + r * 0.44);
    canvas.drawPath(path, stemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Axis Bank (Burgundy with White Chevron 'A')
class _AxisLogoPainter extends CustomPainter {
  const _AxisLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF97144D)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // Chevron A mark
    final path = Path();
    path.moveTo(cx, cy - r * 0.52);
    path.lineTo(cx + r * 0.50, cy + r * 0.48);
    path.lineTo(cx + r * 0.25, cy + r * 0.48);
    path.lineTo(cx, cy - r * 0.06);
    path.lineTo(cx - r * 0.25, cy + r * 0.48);
    path.lineTo(cx - r * 0.50, cy + r * 0.48);
    path.close();

    final markPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, markPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kotak Mahindra Bank (Kotak Red with Infinity Loop)
class _KotakLogoPainter extends CustomPainter {
  const _KotakLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFED1C24)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Vertical line
    final path = Path();
    path.moveTo(cx - r * 0.35, cy - r * 0.40);
    path.lineTo(cx - r * 0.35, cy + r * 0.40);
    canvas.drawPath(path, whitePaint);

    // Curve
    final curvePath = Path();
    curvePath.moveTo(cx + r * 0.35, cy - r * 0.35);
    curvePath.cubicTo(cx - r * 0.1, cy - r * 0.35, cx - r * 0.1, cy + r * 0.35, cx + r * 0.35, cy + r * 0.35);
    canvas.drawPath(curvePath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Punjab National Bank (Maroon with Gold Circle and Monogram)
class _PnbLogoPainter extends CustomPainter {
  const _PnbLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFA20000)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final goldPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r * 0.54, goldPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'PNB',
        style: TextStyle(
          color: Color(0xFFFFC107),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bank of Baroda (Vermillion Sun Emblem)
class _BobLogoPainter extends CustomPainter {
  const _BobLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFF26522)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18
      ..isAntiAlias = true;

    // Dual stylized arcs (Baroda sun)
    canvas.drawArc(Rect.fromCircle(center: Offset(cx - r * 0.05, cy - r * 0.18), radius: r * 0.28), -1.5, 3.14, false, whitePaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx - r * 0.05, cy + r * 0.18), radius: r * 0.28), -1.5, 3.14, false, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Canara Bank (Intertwined Canara Blue & Gold Triangles)
class _CanaraLogoPainter extends CustomPainter {
  const _CanaraLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF0091DF)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD100)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path1 = Path();
    path1.moveTo(cx, cy - r * 0.45);
    path1.lineTo(cx + r * 0.40, cy + r * 0.35);
    path1.lineTo(cx - r * 0.40, cy + r * 0.35);
    path1.close();
    canvas.drawPath(path1, yellowPaint);

    final blueCutout = Paint()
      ..color = const Color(0xFF0091DF)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final path2 = Path();
    path2.moveTo(cx, cy - r * 0.18);
    path2.lineTo(cx + r * 0.18, cy + r * 0.20);
    path2.lineTo(cx - r * 0.18, cy + r * 0.20);
    path2.close();
    canvas.drawPath(path2, blueCutout);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Union Bank of India (Interlocking Red & Blue U)
class _UnionBankLogoPainter extends CustomPainter {
  const _UnionBankLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final bluePaint = Paint()
      ..color = const Color(0xFF005A9C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final redPaint = Paint()
      ..color = const Color(0xFFD31E28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.20
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final pathRed = Path();
    pathRed.moveTo(cx - r * 0.20, cy - r * 0.30);
    pathRed.lineTo(cx - r * 0.20, cy + r * 0.20);
    pathRed.quadraticBezierTo(cx - r * 0.20, cy + r * 0.40, cx, cy + r * 0.40);
    canvas.drawPath(pathRed, redPaint);

    final pathBlue = Path();
    pathBlue.moveTo(cx + r * 0.20, cy - r * 0.30);
    pathBlue.lineTo(cx + r * 0.20, cy + r * 0.20);
    pathBlue.quadraticBezierTo(cx + r * 0.20, cy + r * 0.40, cx, cy + r * 0.40);
    canvas.drawPath(pathBlue, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// IndusInd Bank (Crimson with Zebu Bull Emblem)
class _IndusindLogoPainter extends CustomPainter {
  const _IndusindLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF8B1D41)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'INDUS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Federal Bank (Navy Blue & Gold)
class _FederalLogoPainter extends CustomPainter {
  const _FederalLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF004C97)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final goldPaint = Paint()
      ..color = const Color(0xFFFDB813)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(cx, cy - r * 0.45);
    path.lineTo(cx + r * 0.35, cy);
    path.lineTo(cx, cy + r * 0.45);
    path.lineTo(cx - r * 0.35, cy);
    path.close();
    canvas.drawPath(path, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// IDFC FIRST Bank (Burgundy with White '1')
class _IdfcLogoPainter extends CustomPainter {
  const _IdfcLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF9D1D27)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: '1st',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paytm Payments Bank (Cyan & Deep Navy)
class _PaytmLogoPainter extends CustomPainter {
  const _PaytmLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF00BAF2)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'paytm',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Google Pay (GPay 4-Color Ring)
class _GPayLogoPainter extends CustomPainter {
  const _GPayLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final stroke = r * 0.28;
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65);

    // Blue arc
    canvas.drawArc(arcRect, -0.78, 1.57, false, Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = stroke..isAntiAlias = true);
    // Green arc
    canvas.drawArc(arcRect, 0.78, 1.57, false, Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = stroke..isAntiAlias = true);
    // Yellow arc
    canvas.drawArc(arcRect, 2.35, 1.57, false, Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = stroke..isAntiAlias = true);
    // Red arc
    canvas.drawArc(arcRect, 3.92, 1.57, false, Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = stroke..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// PhonePe (Purple Circle with Devanagari Pe)
class _PhonePeLogoPainter extends CustomPainter {
  const _PhonePeLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF5F259F)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'पे',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// BHIM UPI (Green & Orange)
class _BhimLogoPainter extends CustomPainter {
  const _BhimLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final greenPaint = Paint()
      ..color = const Color(0xFF0F8A5F)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final orangePaint = Paint()
      ..color = const Color(0xFFEF7B10)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final p1 = Path()
      ..moveTo(cx - r * 0.4, cy - r * 0.4)
      ..lineTo(cx + r * 0.4, cy - r * 0.4)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(p1, greenPaint);

    final p2 = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + r * 0.4, cy + r * 0.4)
      ..lineTo(cx - r * 0.4, cy + r * 0.4)
      ..close();
    canvas.drawPath(p2, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// American Express (Amex Blue with AMEX)
class _AmexLogoPainter extends CustomPainter {
  const _AmexLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF006FCF)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'AMEX',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Standard Chartered (Blue & Green Helix)
class _StanChartLogoPainter extends CustomPainter {
  const _StanChartLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final bluePaint = Paint()
      ..color = const Color(0xFF0072CE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final greenPaint = Paint()
      ..color = const Color(0xFF009A44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.55), -1.0, 2.5, false, bluePaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.55), 2.14, 2.5, false, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// RBL Bank (Navy & Red)
class _RblLogoPainter extends CustomPainter {
  const _RblLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF002B49)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final redPaint = Paint()
      ..color = const Color(0xFFE31837)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx + r * 0.2, cy - r * 0.2), r * 0.22, redPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'RBL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
