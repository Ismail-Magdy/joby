import 'dart:async';
import 'dart:math';
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
import '../widgets/game_result_claim_sheet.dart';

class CatchLogoGameScreen extends StatefulWidget {
  const CatchLogoGameScreen({super.key});

  @override
  State<CatchLogoGameScreen> createState() => _CatchLogoGameScreenState();
}

class _FallingItem {
  double x; // normalized 0..1
  double y; // normalized 0..1
  final double speed;
  final bool isSpecialStar;

  _FallingItem({
    required this.x,
    required this.y,
    required this.speed,
    required this.isSpecialStar,
  });
}

class _CatchLogoGameScreenState extends State<CatchLogoGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  Timer? _countdownTimer;

  static const int _gameDurationSeconds = 25;
  int _secondsLeft = _gameDurationSeconds;
  bool _isPlaying = false;
  bool isGameOver = false;

  int _score = 0;
  int _caughtCount = 0;
  int _streak = 0;

  double _paddleX = 0.5; // normalized 0..1
  final List<_FallingItem> _items = [];
  final Random _random = Random();
  double _lastSpawnTime = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final isAvailable = context.read<GamesCubit>().isGameAvailable(
      "catch_logo",
    );
    if (!isAvailable) {
      CustomFeedbackDialog.showWarning(
        context,
        title: "On Cooldown",
        message: "This Game is on Daily Cooldown. Come Back Soon",
      );
      return;
    }

    setState(() {
      _isPlaying = true;
      isGameOver = false;
      _secondsLeft = _gameDurationSeconds;
      _score = 0;
      _caughtCount = 0;
      _streak = 0;
      _paddleX = 0.5;
      _items.clear();
      _lastSpawnTime = 0.0;
    });

    _ticker.repeat();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _endGame();
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _gameLoop() {
    if (!_isPlaying) return;

    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (now - _lastSpawnTime > 0.65) {
      _lastSpawnTime = now;
      _items.add(
        _FallingItem(
          x: 0.1 + (_random.nextDouble() * 0.8),
          y: 0.0,
          speed: 0.007 + (_random.nextDouble() * 0.006),
          isSpecialStar: _random.nextInt(5) == 0,
        ),
      );
    }

    // Update positions & check collisions
    const paddleWidth = 0.28;
    const paddleY = 0.88;

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      item.y += item.speed;

      // Collision check with paddle
      if (item.y >= paddleY - 0.04 && item.y <= paddleY + 0.04) {
        if ((item.x - _paddleX).abs() <= (paddleWidth / 2)) {
          _items.removeAt(i);
          _caughtCount += 1;
          _streak += 1;
          final bonus = item.isSpecialStar ? 30 : 15;
          _score += (bonus * (_streak > 4 ? 2 : 1));
          continue;
        }
      }

      // Missed item
      if (item.y > 1.05) {
        _items.removeAt(i);
        _streak = 0; // reset streak on miss
      }
    }

    setState(() {});
  }

  void _endGame() {
    _ticker.stop();
    _countdownTimer?.cancel();
    setState(() {
      _isPlaying = false;
      isGameOver = true;
    });

    // Calculate points: score scaled to max 40 pts
    int pointsWon = (_score / 8).clamp(10, 40).round();
    _showResultSheet(pointsWon);
  }

  void _showResultSheet(int points) {
    GameResultClaimSheet.show(
      context,
      gameTitle: "Catch The Logo",
      pointsEarned: points,
      scoreDetails: "Caught $_caughtCount Logos With a Final Score of $_score",
      onClaim: () async {
        context.pop();
        final cubit = context.read<GamesCubit>();
        final homeCubit = context.read<UserHomeCubit>();

        final success = await cubit.claimReward(
          gameId: "catch_logo",
          pointsEarned: points,
          userHomeCubit: homeCubit,
        );

        if (mounted) {
          if (success) {
            CustomFeedbackDialog.showSuccess(
              context,
              title: "Points Awarded",
              message: "Added $points Points to Your Profile Balance",
              onFinish: () {
                if (mounted) context.pop();
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: const CustomAppBar(text: "Catch The Logo"),
      body: SafeArea(
        child: Column(
          children: [
            // Stats HUD
            Container(
              padding: .symmetric(horizontal: 20.w, vertical: 12.h),
              margin: .symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: .circular(16.r),
                border: .all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  _hudBadge("TIME", "${_secondsLeft}s", Colors.amber),
                  _hudBadge("SCORE", "$_score", Colors.cyanAccent),
                  _hudBadge("CAUGHT", "$_caughtCount", Colors.greenAccent),
                ],
              ),
            ),
            // Game Area
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (!_isPlaying) return;
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final width = renderBox.size.width;
                    setState(() {
                      _paddleX = (details.localPosition.dx / width).clamp(
                        0.14,
                        0.86,
                      );
                    });
                  }
                },
                child: Container(
                  margin: .symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: .circular(24.r),
                    border: .all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: .circular(24.r),
                    child: Stack(
                      children: [
                        // Subtle grid lines
                        Opacity(
                          opacity: 0.05,
                          child: GridPaper(color: Colors.white, interval: 40.r),
                        ),
                        // Start overlay
                        if (!_isPlaying)
                          Center(
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                Icon(
                                  Icons.sports_esports_rounded,
                                  size: 64.sp,
                                  color: const Color(0xFFA78BFA),
                                ),
                                verticalSpace(12),
                                Text(
                                  "Catch The Joby Logos",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: "BrunoAceSC",
                                  ),
                                ),
                                verticalSpace(6),
                                Text(
                                  "Drag paddle left & right to catch items!",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                verticalSpace(24),
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C3AED),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: .circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    "START GAME",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: .bold,
                                      color: Colors.white,
                                      fontFamily: "BrunoAceSC",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Falling items
                        if (_isPlaying)
                          ..._items.map((item) {
                            return Align(
                              alignment: FractionalOffset(item.x, item.y),
                              child: item.isSpecialStar
                                  ? Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    )
                                  : Container(
                                      width: 36.w,
                                      height: 36.w,
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/svgs/joby_logo.svg",
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.primaryColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                            );
                          }),
                        // Catcher paddle at bottom
                        if (_isPlaying)
                          Align(
                            alignment: FractionalOffset(_paddleX, 0.88),
                            child: Container(
                              width: 90.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFFA78BFA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7C3AED,
                                    ).withValues(alpha: 0.6),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white60,
            fontFamily: "BrunoAceSC",
          ),
        ),
        verticalSpace(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: "BrunoAceSC",
          ),
        ),
      ],
    );
  }
}

// TODO :
