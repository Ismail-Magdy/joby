import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/widgets/error_screen.dart';
import '../../../../../core/helpers/extensions.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../manager/games_cubit.dart';
import '../../manager/games_state.dart';
import '../widgets/game_hub_card.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GamesCubit>().loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      //
      appBar: const CustomAppBar(text: "Joby Arcade"),
      //
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          //
          if (state is GamesLoading) {
            // TODO : ADD SKELETON LOADING ANIMATION
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
            //
          } else if (state is GamesError) {
            return ErrorScreen();
            //
          } else if (state is GamesLoaded) {
            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () => context.read<GamesCubit>().loadGames(),
              child: ListView(
                padding: .symmetric(horizontal: 20.w, vertical: 16.h),
                children: [
                  // Header Points Balance Banner
                  Container(
                    width: .infinity,
                    padding: .all(20.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryColor, Color(0xFF1E3A8A)],
                        begin: .topLeft,
                        end: .bottomRight,
                      ),
                      borderRadius: .circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              "YOUR POINTS BALANCE",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: .bold,
                                color: Colors.white70,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            verticalSpace(4),
                            Text(
                              "${state.userTotalPoints} PTS",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            verticalSpace(4),
                            Text(
                              "Play Mini Games To Rank Higher",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 56.w,
                          height: 56.w,
                          padding: .all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: .circle,
                          ),
                          child: SvgPicture.asset(
                            "assets/svgs/points_count.svg",
                            colorFilter: const .mode(Colors.white, .srcIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(24),
                  // Section Title
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        "Daily Mini Games",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: .bold,
                          color: Colors.black87,
                          fontFamily: "BrunoAceSC",
                        ),
                      ),
                      Text(
                        "4 Games",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: .w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(14),
                  // Game Cards List
                  ...state.games.map((game) {
                    final cooldown = state.cooldowns[game.id];
                    return GameHubCard(
                      game: game,
                      cooldownStatus: cooldown,
                      onTap: () async {
                        await context.pushNamed(game.routeName);
                        if (context.mounted) {
                          context.read<GamesCubit>().loadGames();
                        }
                      },
                    );
                  }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
