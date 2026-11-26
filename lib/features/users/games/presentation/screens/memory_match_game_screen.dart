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

class _MemoryCardItem {
  final int id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final Color color;

  const _MemoryCardItem({
    required this.id,
    required this.label,
    this.icon,
    this.svgAsset,
    required this.color,
  });
}

class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({super.key});

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  static const List<_MemoryCardItem> _items = [
    _MemoryCardItem(
      id: 1,
      label: "Joby Logo",
      svgAsset: "assets/svgs/joby_logo.svg",
      color: AppColors.primaryColor,
    ),
    _MemoryCardItem(
      id: 2,
      label: "Resume",
      icon: Icons.description_rounded,
      color: Color(0xFF7C3AED),
    ),
    _MemoryCardItem(
      id: 3,
      label: "Points",
      svgAsset: "assets/svgs/points_count.svg",
      color: Color(0xFFF59E0B),
    ),
    _MemoryCardItem(
      id: 4,
      label: "Location",
      icon: Icons.location_on_rounded,
      color: Color(0xFFEF4444),
    ),
    _MemoryCardItem(
      id: 5,
      label: "Career",
      icon: Icons.work_rounded,
      color: Color(0xFF059669),
    ),
    _MemoryCardItem(
      id: 6,
      label: "Featured",
      icon: Icons.stars_rounded,
      color: Color(0xFF2563EB),
    ),
  ];

  late List<_MemoryCardItem> _deck;
  late List<bool> _isFlipped;
  late List<bool> _isMatched;

  int _moves = 0;
  int _pairsFound = 0;
  bool _isProcessing = false;
  bool _isGameFinished = false;
  int? _firstFlippedIndex;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    if (_isGameFinished) return;
    final list = [..._items, ..._items];
    list.shuffle(Random());
    setState(() {
      _deck = list;
      _isFlipped = List<bool>.filled(list.length, false);
      _isMatched = List<bool>.filled(list.length, false);
      _moves = 0;
      _pairsFound = 0;
      _firstFlippedIndex = null;
      _isProcessing = false;
    });
  }

  void _onCardTapped(int index) {
    if (_isProcessing ||
        _isGameFinished ||
        _isFlipped[index] ||
        _isMatched[index]) {
      return;
    }

    final isAvailable = context.read<GamesCubit>().isGameAvailable(
      "memory_match",
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
      _isFlipped[index] = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _moves += 1;
      final secondIndex = index;
      final firstIndex = _firstFlippedIndex!;
      _firstFlippedIndex = null;

      if (_deck[firstIndex].id == _deck[secondIndex].id) {
        // Matched!
        setState(() {
          _isMatched[firstIndex] = true;
          _isMatched[secondIndex] = true;
          _pairsFound += 1;
        });

        if (_pairsFound == _items.length) {
          _onGameWon();
        }
      } else {
        // Not matched - flip back after delay
        _isProcessing = true;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _isFlipped[firstIndex] = false;
              _isFlipped[secondIndex] = false;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _onGameWon() {
    setState(() => _isGameFinished = true);
    int pointsWon = 45;
    if (_moves > 16) {
      pointsWon = 25;
    } else if (_moves > 10) {
      pointsWon = 35;
    }

    GameResultClaimSheet.show(
      context,
      gameTitle: "Memory Match",
      pointsEarned: pointsWon,
      scoreDetails: "All 6 pairs Matched in $_moves Moves",
      onClaim: () async {
        context.pop();
        final cubit = context.read<GamesCubit>();
        final homeCubit = context.read<UserHomeCubit>();

        final success = await cubit.claimReward(
          gameId: "memory_match",
          pointsEarned: pointsWon,
          userHomeCubit: homeCubit,
        );

        if (mounted) {
          if (success) {
            CustomFeedbackDialog.showSuccess(
              context,
              title: "Points Claimed",
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
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(text: "Memory Match"),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD
            Padding(
              padding: .symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Container(
                    padding: .symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: .circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      "MOVES : $_moves",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: .bold,
                        fontFamily: "BrunoAceSC",
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: .symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: .circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      "PAIRS: $_pairsFound / ${_items.length}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: .bold,
                        fontFamily: "BrunoAceSC",
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isGameFinished ? null : _startNewGame,
                    icon: const Icon(Icons.refresh_rounded),
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
            // Cards Grid
            Expanded(
              child: Padding(
                padding: .symmetric(horizontal: 20.w, vertical: 8.h),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _deck.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = _deck[index];
                    final isFlipped = _isFlipped[index];
                    final isMatched = _isMatched[index];

                    return GestureDetector(
                      onTap: () => _onCardTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        decoration: BoxDecoration(
                          color: isFlipped
                              ? Colors.white
                              : AppColors.primaryColor,
                          borderRadius: .circular(16.r),
                          border: Border.all(
                            color: isMatched
                                ? const Color(0xFF10B981)
                                : isFlipped
                                ? item.color.withValues(alpha: 0.4)
                                : Colors.transparent,
                            width: isMatched ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isFlipped
                                  ? item.color.withValues(alpha: 0.15)
                                  : AppColors.primaryColor.withValues(
                                      alpha: 0.25,
                                    ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isFlipped
                              ? Column(
                                  mainAxisAlignment: .center,
                                  children: [
                                    if (item.svgAsset != null)
                                      SvgPicture.asset(
                                        item.svgAsset!,
                                        height: 32.h,
                                        colorFilter: .mode(item.color, .srcIn),
                                      )
                                    else if (item.icon != null)
                                      Icon(
                                        item.icon,
                                        size: 32.sp,
                                        color: item.color,
                                      ),
                                    verticalSpace(6),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: .bold,
                                        color: Colors.black87,
                                        fontFamily: "BrunoAceSC",
                                      ),
                                    ),
                                  ],
                                )
                              : SvgPicture.asset(
                                  "assets/svgs/joby_logo.svg",
                                  height: 24.h,
                                  colorFilter: const .mode(
                                    Colors.white70,
                                    .srcIn,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
