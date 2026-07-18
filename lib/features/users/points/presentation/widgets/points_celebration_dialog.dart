import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class PointsCelebrationDialog extends StatefulWidget {
  final int pointsGained;

  const PointsCelebrationDialog({super.key, required this.pointsGained});

  @override
  State<PointsCelebrationDialog> createState() =>
      _PointsCelebrationDialogState();
}

class _PointsCelebrationDialogState extends State<PointsCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      //
      child: Stack(
        clipBehavior: .none,
        alignment: .center,
        children: [
          // Glassmorphism || Stylized Container
          Container(
            width: .infinity,
            padding: .symmetric(horizontal: 24.w, vertical: 30.h),
            // Decoration
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10.r,
                  spreadRadius: 3.r,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            //
            child: Column(
              mainAxisSize: .min,
              children: [
                // Lottie
                Lottie.asset(
                  "assets/lotties/coin_point.json",
                  width: 150.w,
                  height: 90.h,
                  fit: .contain,
                  repeat: true,
                ),
                //
                verticalSpace(10),
                //
                Text(
                  "Awesome",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: .bold,
                    color: Colors.black87,
                    fontFamily: "BrunoAceSC",
                  ),
                ),
                //
                verticalSpace(10),
                //
                Text(
                  "You've been rewarded for checking in today",
                  textAlign: .center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                //
                verticalSpace(20),
                // Points Container
                Container(
                  padding: .symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.05),
                    borderRadius: .circular(15.r),
                    border: .all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    "+${widget.pointsGained} Points",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: .w900,
                      color: AppColors.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                //
                verticalSpace(25),
                // Button
                SizedBox(
                  width: .infinity,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(10.r),
                      ),
                    ),
                    child: Text(
                      "Awesome",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: .bold,
                        color: Colors.white,
                        fontFamily: "BrunoAceSC",
                      ),
                    ),
                  ),
                ),
                //
              ],
            ),
          ),

          // Confetti blaster centered
          Align(
            alignment: .center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: .explosive,
              shouldLoop: false,
              colors: const [
                Colors.orange,
                Colors.red,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.black,
              ],
              createParticlePath: drawStar,
            ),
          ),
          //
        ],
      ),
      //
    );
  }

  /// A custom Path to paint stars
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}
