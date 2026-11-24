import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/extensions.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/custom_feedback_dialog.dart';
import '../../../home/manager/user_home_cubit.dart';
import '../../manager/games_cubit.dart';
import '../../manager/games_state.dart';
import '../widgets/game_result_claim_sheet.dart';

class SpinWheelGameScreen extends StatefulWidget {
  const SpinWheelGameScreen({super.key});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const List<int> _rewards = [10, 25, 5, 50, 15, 30, 20, 40];
  static const List<Color> _sliceColors = [
    Color(0xFF096DCA),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFEA580C),
    Color(0xFF2563EB),
    Color(0xFF9333EA),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  double _currentAngle = 0.0;
  bool _isSpinning = false;
  int? _wonPoints;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    final isAvailable = context.read<GamesCubit>().isGameAvailable(
      "spin_wheel",
    );
    if (!isAvailable) {
      CustomFeedbackDialog.showWarning(
        context,
        title: "On Cooldown",
        message: "This Game is on Daily Cooldown, Come Back Soon",
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _wonPoints = null;
    });

    final random = Random();
    // Choose winning index
    final targetIndex = random.nextInt(_rewards.length);
    final sliceAngle = (2 * pi) / _rewards.length;

    // Pointer is at the top (-pi / 2). Target index should stop under top pointer.
    final targetSectorCenter = (targetIndex * sliceAngle) + (sliceAngle / 2);
    final targetStopAngle =
        (2 * pi * 5) + ((2 * pi) - targetSectorCenter) - (pi / 2);

    final startAngle = _currentAngle % (2 * pi);
    _animation = Tween<double>(
      begin: startAngle,
      end: startAngle + targetStopAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.reset();
    _controller.forward().then((_) {
      _currentAngle = _animation.value;
      _wonPoints = _rewards[targetIndex];
      setState(() => _isSpinning = false);

      _showResultSheet(_wonPoints!);
    });
  }

  void _showResultSheet(int points) {
    GameResultClaimSheet.show(
      context,
      gameTitle: "Spin & Win Wheel",
      pointsEarned: points,
      scoreDetails: "Congratulations The Wheel Landed on $points Bonus Points",
      onClaim: () async {
        context.pop(); // close sheet
        final cubit = context.read<GamesCubit>();
        final homeCubit = context.read<UserHomeCubit>();

        final success = await cubit.claimReward(
          gameId: "spin_wheel",
          pointsEarned: points,
          userHomeCubit: homeCubit,
        );

        if (mounted) {
          if (success) {
            CustomFeedbackDialog.showSuccess(
              context,
              title: "Points Claimed",
              message: "Added $points Points To Your Profile Balance",
              onFinish: () {
                if (mounted) Navigator.pop(context);
              },
            );
          } else {
            CustomFeedbackDialog.showError(
              context,
              title: "Claim Failed",
              message: "Could not Claim Points",
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(text: "Spin & Win"),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          final isAvailable = context.read<GamesCubit>().isGameAvailable(
            "spin_wheel",
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  // Headline banner
                  Container(
                    width: .infinity,
                    padding: .symmetric(horizontal: 18.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: .circular(16.r),
                      border: .all(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Expanded(
                      child: Text(
                        textAlign: .center,
                        "Spin Daily To Win Up To 50 Pts",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: .bold,
                          color: AppColors.primaryColor,
                          fontFamily: "BrunoAceSC",
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(36),
                  // Wheel Stack
                  SizedBox(
                    width: 300.w,
                    height: 300.w,
                    child: Stack(
                      alignment: .center,
                      children: [
                        // Rotating wheel
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final angle = _isSpinning
                                ? _animation.value
                                : _currentAngle;
                            return Transform.rotate(
                              angle: angle,
                              child: CustomPaint(
                                size: Size(290.w, 290.w),
                                painter: _WheelPainter(
                                  rewards: _rewards,
                                  colors: _sliceColors,
                                ),
                              ),
                            );
                          },
                        ),
                        // Center hub with Joby emblem
                        Container(
                          width: 68.w,
                          height: 68.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: .circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: .all(
                              color: AppColors.primaryColor,
                              width: 3,
                            ),
                          ),
                          padding: .all(12.r),
                          child: SvgPicture.asset(
                            "assets/svgs/joby_logo.svg",
                            colorFilter: const .mode(
                              AppColors.primaryColor,
                              .srcIn,
                            ),
                          ),
                        ),
                        // Top indicator pointer pin
                        Positioned(
                          top: -2.h,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 44.sp,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(48),
                  // Spin button
                  SizedBox(
                    width: .infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: (_isSpinning || !isAvailable) ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(18.r),
                        ),
                        elevation: 4,
                      ),
                      child: _isSpinning
                          ? Row(
                              mainAxisAlignment: .center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                horizontalSpace(12),
                                Text(
                                  "SPINNING",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: .bold,
                                    color: Colors.white,
                                    fontFamily: "BrunoAceSC",
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              isAvailable ? "SPIN NOW" : "ON COOLDOWN",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                                fontFamily: "BrunoAceSC",
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                  verticalSpace(16),
                  Text(
                    "One Free Spin Every 18 Hours, Points Update Profile Balance Immediately",
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> rewards;
  final List<Color> colors;

  _WheelPainter({required this.rewards, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = (2 * pi) / rewards.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < rewards.length; i++) {
      paint.color = colors[i % colors.length];
      final startAngle = i * sliceAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Draw reward number
      final textAngle = startAngle + (sliceAngle / 2);
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + (pi / 2));

      final textSpan = TextSpan(
        text: "${rewards[i]}\nPTS",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: .bold,
          fontFamily: "BrunoAceSC",
          height: 1.1,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: .center,
        textDirection: .ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Outer rim border
    final rimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
