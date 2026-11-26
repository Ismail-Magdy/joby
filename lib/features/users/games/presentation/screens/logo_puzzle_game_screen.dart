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

class LogoPuzzleGameScreen extends StatefulWidget {
  const LogoPuzzleGameScreen({super.key});

  @override
  State<LogoPuzzleGameScreen> createState() => _LogoPuzzleGameScreenState();
}

class _LogoPuzzleGameScreenState extends State<LogoPuzzleGameScreen> {
  // 3x3 sliding tile board: 1..8 with 0 as empty slot
  List<int> _board = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  int _moves = 0;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _shuffleBoard();
  }

  void _shuffleBoard() {
    if (_isSolved) return;
    final random = Random();
    List<int> candidate = [1, 2, 3, 4, 5, 6, 7, 8, 0];

    // Fisher-Yates shuffle with solvable parity check
    do {
      for (int i = candidate.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = candidate[i];
        candidate[i] = candidate[j];
        candidate[j] = temp;
      }
    } while (!_isSolvable(candidate) || _checkWin(candidate));

    setState(() {
      _board = candidate;
      _moves = 0;
      _isSolved = false;
    });
  }

  // A 3x3 sliding puzzle is solvable if and only if the number of inversions is even
  bool _isSolvable(List<int> tiles) {
    int inversions = 0;
    final nonZero = tiles.where((t) => t != 0).toList();
    for (int i = 0; i < nonZero.length; i++) {
      for (int j = i + 1; j < nonZero.length; j++) {
        if (nonZero[i] > nonZero[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  bool _checkWin(List<int> tiles) {
    for (int i = 0; i < 8; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[8] == 0;
  }

  void _onTileTap(int index) {
    if (_isSolved) return;

    final isAvailable = context.read<GamesCubit>().isGameAvailable(
      "logo_puzzle",
    );
    if (!isAvailable) {
      CustomFeedbackDialog.showWarning(
        context,
        title: "On Cooldown",
        message: "This Game is on Daily Cooldown, Come Back Soon",
      );
      return;
    }

    final emptyIndex = _board.indexOf(0);
    final row = index ~/ 3;
    final col = index % 3;
    final emptyRow = emptyIndex ~/ 3;
    final emptyCol = emptyIndex % 3;

    // Must be adjacent (up, down, left, right)
    final isAdjacent =
        (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);

    if (isAdjacent) {
      setState(() {
        _board[emptyIndex] = _board[index];
        _board[index] = 0;
        _moves += 1;
      });

      if (_checkWin(_board)) {
        setState(() => _isSolved = true);
        _onGameWon();
      }
    }
  }

  void _onGameWon() {
    int pointsWon = 50;
    if (_moves > 40) {
      pointsWon = 30;
    } else if (_moves > 25) {
      pointsWon = 40;
    }

    GameResultClaimSheet.show(
      context,
      gameTitle: "Logo Puzzle",
      pointsEarned: pointsWon,
      scoreDetails: "Emblem Reconstructed in $_moves Moves",
      onClaim: () async {
        context.pop();
        final cubit = context.read<GamesCubit>();
        final homeCubit = context.read<UserHomeCubit>();

        final success = await cubit.claimReward(
          gameId: "logo_puzzle",
          pointsEarned: pointsWon,
          userHomeCubit: homeCubit,
        );

        if (mounted) {
          if (success) {
            CustomFeedbackDialog.showSuccess(
              context,
              title: "Points Awarded",
              message: "Added $pointsWon Points To Your Profile Balance",
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
      appBar: const CustomAppBar(text: "Logo Puzzle"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Moves HUD
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Container(
                    padding: .symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                      borderRadius: .circular(14.r),
                    ),
                    child: Text(
                      "MOVES: $_moves",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: .bold,
                        fontFamily: "BrunoAceSC",
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSolved ? null : _shuffleBoard,
                    icon: const Icon(Icons.shuffle_rounded, size: 18),
                    label: const Text("Shuffle"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(14.r),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpace(24),
              // Target Preview Banner
              Container(
                width: .infinity,
                padding: .all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: .circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      padding: .all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: .circular(10.r),
                        border: .all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SvgPicture.asset("assets/svgs/joby_logo.svg"),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "Goal : Order Tiles 1 to 8",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: .bold,
                              fontFamily: "BrunoAceSC",
                              color: Colors.black87,
                            ),
                          ),
                          verticalSpace(2),
                          Text(
                            "Slide Tiles Into The Empty Space To Reconstruct The Emblem",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(28),
              // 3x3 Puzzle Board
              Container(
                width: 300.w,
                height: 300.w,
                padding: .all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: .circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemBuilder: (context, index) {
                    final tileValue = _board[index];
                    if (tileValue == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: .circular(14.r),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: .circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            Text(
                              "$tileValue",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            verticalSpace(2),
                            SvgPicture.asset(
                              "assets/svgs/joby_logo.svg",
                              height: 12.h,
                              colorFilter: const .mode(Colors.white60, .srcIn),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              verticalSpace(36),
              Text(
                "Tap Adjacent Tiles To Move Them Into The Blank Space",
                textAlign: .center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
