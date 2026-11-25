import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/widgets/app_skeletonizer.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/helpers/extensions.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/game_cooldown_status.dart';
import '../../data/models/mini_game_model.dart';
import '../../manager/games_cubit.dart';
import '../../manager/games_state.dart';
import '../widgets/game_hub_card.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  static const List<MiniGameModel> _placeholderGames = [
    MiniGameModel(
      id: 'placeholder_1',
      title: 'Spin & Win',
      subtitle: 'Spin The Joby Wheel Of Fortune For Instant Points',
      badge: 'DAILY LUCK',
      icon: 'assets/images/spin_win.jpeg',
      maxRewardPoints: 50,
      cooldownDuration: Duration(hours: 18),
      primaryColor: AppColors.primaryColor,
      secondaryColor: Color(0xFF64B5F6),
      routeName: '',
    ),
    MiniGameModel(
      id: 'placeholder_2',
      title: 'Catch The Logo',
      subtitle: 'Catch Falling Joby Logos Before Time Expires',
      badge: 'FAST REFLEX',
      icon: 'assets/images/catch_the_logo.jpeg',
      maxRewardPoints: 40,
      cooldownDuration: Duration(hours: 18),
      primaryColor: AppColors.primaryColor,
      secondaryColor: Color(0xFF64B5F6),
      routeName: '',
    ),
    MiniGameModel(
      id: 'placeholder_3',
      title: 'Memory Match',
      subtitle: 'Flip and Pair Joby Recruitment Cards To Boost Your Brain',
      badge: 'BRAIN BOOST',
      icon: 'assets/images/memory_match.jpeg',
      maxRewardPoints: 45,
      cooldownDuration: Duration(hours: 18),
      primaryColor: AppColors.primaryColor,
      secondaryColor: Color(0xFF64B5F6),
      routeName: '',
    ),
    MiniGameModel(
      id: 'placeholder_4',
      title: 'Logo Puzzle',
      subtitle: 'Slide numbered tiles to reconstruct the official Joby emblem',
      badge: 'LOGIC PUZZLE',
      icon: 'assets/images/logo_puzzle.jpeg',
      maxRewardPoints: 50,
      cooldownDuration: Duration(hours: 18),
      primaryColor: AppColors.primaryColor,
      secondaryColor: Color(0xFF64B5F6),
      routeName: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<GamesCubit>().loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(text: "Joby Arcade"),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          if (state is GamesError) {
            return const ErrorScreen();
          }

          final isLoading = state is GamesLoading || state is GamesInitial;
          final int totalPoints = state is GamesLoaded
              ? state.userTotalPoints
              : 250;
          final List<MiniGameModel> games = state is GamesLoaded
              ? state.games
              : _placeholderGames;
          final Map<String, GameCooldownStatus> cooldowns =
              state is GamesLoaded ? state.cooldowns : const {};

          final content = ListView(
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
                          "$totalPoints PTS",
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
                      child: Skeleton.replace(
                        width: 32.w,
                        height: 32.w,
                        child: SvgPicture.asset(
                          "assets/svgs/points_count.svg",
                          colorFilter: const .mode(Colors.white, .srcIn),
                        ),
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
                    "${games.length} Games",
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
              ...games.map((game) {
                return GameHubCard(
                  game: game,
                  cooldownStatus: cooldowns[game.id],
                  onTap: isLoading
                      ? () {}
                      : () async {
                          await context.pushNamed(game.routeName);
                          if (context.mounted) {
                            context.read<GamesCubit>().loadGames();
                          }
                        },
                );
              }),
            ],
          );

          return AppSkeletonizer(
            enabled: isLoading,
            child: isLoading
                ? content
                : RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () => context.read<GamesCubit>().loadGames(),
                    child: content,
                  ),
          );
        },
      ),
    );
  }
}
