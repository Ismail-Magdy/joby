import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class GameResultClaimSheet extends StatefulWidget {
  final String gameTitle;
  final int pointsEarned;
  final String scoreDetails;
  final VoidCallback onClaim;
  final bool isClaiming;

  const GameResultClaimSheet({
    super.key,
    required this.gameTitle,
    required this.pointsEarned,
    required this.scoreDetails,
    required this.onClaim,
    this.isClaiming = false,
  });

  /// Static helper to display this sheet as a bottom modal
  static Future<void> show(
    BuildContext context, {
    required String gameTitle,
    required int pointsEarned,
    required String scoreDetails,
    required VoidCallback onClaim,
    bool isClaiming = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GameResultClaimSheet(
        gameTitle: gameTitle,
        pointsEarned: pointsEarned,
        scoreDetails: scoreDetails,
        onClaim: onClaim,
        isClaiming: isClaiming,
      ),
    );
  }

  @override
  State<GameResultClaimSheet> createState() => _GameResultClaimSheetState();
}

class _GameResultClaimSheetState extends State<GameResultClaimSheet> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
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
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti cannon
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: .explosive,
          shouldLoop: false,
          colors: const [
            AppColors.primaryColor,
            Colors.amber,
            Colors.green,
            Colors.purple,
            Colors.orange,
          ],
        ),
        Container(
          margin: .all(20.r),
          padding: .symmetric(horizontal: 24.w, vertical: 26.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              // Celebration Badge
              Container(
                width: 74.w,
                height: 74.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: .topLeft,
                    end: .bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/svgs/points_count.svg",
                    height: 38.h,
                    colorFilter: const .mode(Colors.white, .srcIn),
                  ),
                ),
              ),
              verticalSpace(16),
              // Game Title
              Text(
                widget.gameTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  fontFamily: "BrunoAceSC",
                ),
              ),
              verticalSpace(6),
              // Points won
              Text(
                "+${widget.pointsEarned} Points",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: .bold,
                  color: AppColors.primaryColor,
                  fontFamily: "BrunoAceSC",
                ),
              ),
              verticalSpace(8),
              // Score details summary
              Text(
                widget.scoreDetails,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                textAlign: .center,
              ),
              verticalSpace(24),
              // Claim button
              SizedBox(
                width: .infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: widget.isClaiming ? null : widget.onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(16.r),
                    ),
                    elevation: 3,
                  ),
                  child: widget.isClaiming
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 12.r,
                          ),
                        )
                      : Text(
                          textAlign: .center,
                          "CLAIM REWARD",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: .bold,
                            color: Colors.white,
                            fontFamily: "BrunoAceSC",
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
