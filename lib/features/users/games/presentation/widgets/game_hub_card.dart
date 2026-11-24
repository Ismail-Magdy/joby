import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../data/models/game_cooldown_status.dart';
import '../../data/models/mini_game_model.dart';

class GameHubCard extends StatelessWidget {
  final MiniGameModel game;
  final GameCooldownStatus? cooldownStatus;
  final VoidCallback onTap;

  const GameHubCard({
    super.key,
    required this.game,
    this.cooldownStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = cooldownStatus?.isAvailable ?? true;
    final cooldownText = cooldownStatus?.remainingTimeString ?? "Ready";

    return Container(
      margin: .only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(22.r),
        boxShadow: [
          BoxShadow(
            color: game.primaryColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isAvailable
              ? game.primaryColor.withValues(alpha: 0.25)
              : Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: .circular(22.r),
          onTap: isAvailable ? onTap : null,
          child: Padding(
            padding: .all(18.r),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    // Game Icon Container
                    Container(
                      width: 54.w,
                      height: 54.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [game.primaryColor, game.secondaryColor],
                          begin: .topLeft,
                          end: .bottomRight,
                        ),
                        borderRadius: .circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: game.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: .circular(16.r),
                        child: Image.asset(game.icon, fit: .cover),
                      ),
                    ),
                    horizontalSpace(14),
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  game.title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: .bold,
                                    color: Colors.black87,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                              // Badge
                              Container(
                                padding: .symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: game.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: .circular(8.r),
                                ),
                                child: Text(
                                  game.badge,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: .bold,
                                    color: game.primaryColor,
                                    fontFamily: "BrunoAceSC",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(4),
                          Text(
                            game.subtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: .ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),
                // Footer: Reward chip + Action Button
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    // Reward points chip
                    Container(
                      padding: .symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: .circular(12.r),
                        border: .all(
                          color: const Color(0xFFFDBA74).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          SvgPicture.asset(
                            "assets/svgs/points_count.svg",
                            height: 14.h,
                          ),
                          horizontalSpace(6),
                          Text(
                            "Up to ${game.maxRewardPoints} pts",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: .bold,
                              color: const Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action button / Cooldown badge
                    if (isAvailable)
                      Container(
                        padding: .symmetric(horizontal: 16.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [game.primaryColor, game.secondaryColor],
                          ),
                          borderRadius: .circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: game.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            Text(
                              "PLAY NOW",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                                fontFamily: "BrunoAceSC",
                                letterSpacing: 0.5,
                              ),
                            ),
                            horizontalSpace(4),
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: .symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: .circular(12.r),
                          border: .all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                            horizontalSpace(6),
                            Text(
                              cooldownText,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: .w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
