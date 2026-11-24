import 'package:get_it/get_it.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:joby/features/common/forgot_password/data/repo/forgot_password_repo.dart';
import 'package:joby/features/common/forgot_password/data/repo/forgot_password_repo_impl.dart';
import 'package:joby/features/common/forgot_password/manager/forgot_password_cubit.dart';
import 'package:joby/features/company/home/data/repos/company_home_repo.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/auth/data/repos/auth_repo.dart';
import 'package:joby/features/common/auth/data/repos/auth_repo_impl.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import '../../features/common/on_boarding/data/repositories/user_type_repository.dart';
import '../../features/common/feed_back/data/repos/feed_back_repo.dart';
import '../../features/common/feed_back/data/repos/feed_back_repo_impl.dart';
import '../../features/common/feed_back/manager/feed_back_cubit.dart';
import '../../features/users/edit_profile/data/repos/edit_profile_repo.dart';
import '../../features/users/edit_profile/manager/edit_profile_cubit.dart';
import '../../features/users/home/data/repos/user_home_repo.dart';
import '../../features/users/home/data/repos/user_home_repo_impl.dart';
import '../../features/users/home/manager/user_home_cubit.dart';
import '../../features/users/user_info/data/repos/user_info_repo.dart';
import '../../features/users/user_info/data/repos/user_info_repo_impl.dart';
import '../../features/users/user_info/manager/user_info_cubit.dart';
import '../../features/users/points/data/repos/points_repo.dart';
import '../../features/users/points/data/repos/points_repo_impl.dart';
import '../../features/users/points/manager/points_cubit.dart';
import '../../features/users/games/data/repos/games_repo.dart';
import '../../features/users/games/data/repos/games_repo_impl.dart';
import '../../features/users/games/manager/games_cubit.dart';
import '../../features/company/company_info/data/repos/company_info_repo.dart';
import '../../features/company/company_info/data/repos/company_info_repo_impl.dart';
import '../../features/company/company_info/manager/company_info_cubit.dart';
import '../../features/company/home/data/repos/company_home_repo_impl.dart';
import '../../features/company/home/manager/company_home_cubit.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {
  /// Core Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  /// OnBoarding Feature
  getIt.registerLazySingleton<OnBoardingRepo>(
    () => OnBoardingRepoImpl(sharedPreferences: getIt<SharedPreferences>()),
  );
  getIt.registerFactory<OnBoardingCubit>(
    () => OnBoardingCubit(onBoardingRepo: getIt<OnBoardingRepo>()),
  );

  /// Auth Feature
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authRepo: getIt<AuthRepo>()),
  );

  getIt.registerLazySingleton<ForgotPasswordRepo>(
    () => ForgotPasswordRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(repo: getIt<ForgotPasswordRepo>()),
  );

  /// User Part

  /// User Info Feature
  getIt.registerLazySingleton<UserInfoRepo>(
    () => UserInfoRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<UserInfoCubit>(
    () => UserInfoCubit(userInfoRepo: getIt<UserInfoRepo>()),
  );

  /// User Home Feature
  getIt.registerLazySingleton<UserHomeRepo>(
    () => UserHomeRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<UserHomeCubit>(
    () => UserHomeCubit(userHomeRepo: getIt<UserHomeRepo>()),
  );

  /// Edit Profile Feature
  getIt.registerLazySingleton<EditProfileRepo>(
    () => EditProfileRepo(getIt<SupabaseClient>()),
  );
  getIt.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(getIt<EditProfileRepo>(), getIt<SupabaseClient>()),
  );

  /// Advice (Feedback) Feature
  getIt.registerLazySingleton<FeedBackRepo>(
    () => FeedBackRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<FeedBackCubit>(
    () => FeedBackCubit(feedBackRepo: getIt<FeedBackRepo>()),
  );

  /// Profile Views Feature
  getIt.registerFactory<ProfileViewsCubit>(() => ProfileViewsCubit());

  /// Points Feature
  getIt.registerLazySingleton<PointsRepo>(
    () => PointsRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<PointsCubit>(
    () => PointsCubit(
      pointsRepo: getIt<PointsRepo>(),
      sharedPrefs: getIt<SharedPreferences>(),
    ),
  );

  /// Games Feature
  getIt.registerLazySingleton<GamesRepo>(
    () => GamesRepoImpl(
      supabaseClient: getIt<SupabaseClient>(),
      sharedPrefs: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerFactory<GamesCubit>(
    () => GamesCubit(gamesRepo: getIt<GamesRepo>()),
  );

  /// Notification Feature
  getIt.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );

  /// Shared AudioPlayer (reused across all cards)
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  /// Company Part

  /// Company Info Feature
  getIt.registerLazySingleton<CompanyInfoRepo>(
    () => CompanyInfoRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<CompanyInfoCubit>(
    () => CompanyInfoCubit(
      companyInfoRepo: getIt<CompanyInfoRepo>(),
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  /// Company Home Feature
  getIt.registerLazySingleton<CompanyHomeRepo>(
    () => CompanyHomeRepoImpl(
      supabaseClient: getIt<SupabaseClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerFactory<CompanyHomeCubit>(
    () => CompanyHomeCubit(repo: getIt<CompanyHomeRepo>()),
  );
}
