import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// OnBoarding Imports
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';

// Auth Imports
import 'package:joby/features/common/auth/data/repos/auth_repo.dart';
import 'package:joby/features/common/auth/data/repos/auth_repo_impl.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';

import '../../features/common/on_boarding/data/repositories/user_type_repository.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {
  // ================= 1. Core Services =================
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // تسجيل عميل سوبابيز (مرة واحدة بس)
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ================= 2. OnBoarding Feature =================
  getIt.registerLazySingleton<OnBoardingRepo>(
    () => OnBoardingRepoImpl(sharedPreferences: getIt<SharedPreferences>()),
  );
  getIt.registerFactory<OnBoardingCubit>(
    () => OnBoardingCubit(onBoardingRepo: getIt<OnBoardingRepo>()),
  );

  // ================= 3. Auth Feature =================
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authRepo: getIt<AuthRepo>()),
  );
}
