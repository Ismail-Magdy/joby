import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/auth/data/repos/auth_repo.dart';
import 'package:joby/features/common/auth/data/repos/auth_repo_impl.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import '../../features/common/on_boarding/data/repositories/user_type_repository.dart';
import '../../features/users/advice/data/repos/advice_repo.dart';
import '../../features/users/advice/data/repos/advice_repo_impl.dart';
import '../../features/users/advice/manager/advice_cubit.dart';
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
  getIt.registerLazySingleton<AdviceRepo>(
    () => AdviceRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<AdviceCubit>(
    () => AdviceCubit(adviceRepo: getIt<AdviceRepo>()),
  );

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

  ///
}
