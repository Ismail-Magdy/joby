import 'package:flutter/rendering.dart';
import 'package:joby/core/themes/app_colors.dart';

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = AppColors.primaryColor;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 1.25,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
