import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar_without_leading.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import 'package:joby/features/users/settings_users/presentation/widgets/settings_group_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../manager/company_settings_cubit.dart';
import '../../manager/company_settings_state.dart';
import '../widgets/company_rate_app_dialog.dart';
import '../widgets/company_summary_card.dart';
import '../widgets/edit_company_profile_sheet.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Logout",
          style: TextStyle(
            fontFamily: 'BrunoAceSC',
            fontSize: 18.sp,
            fontWeight: .bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          "Are You Sure You Want To Log Out Of Your Account?",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(dialogContext, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: .w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
              elevation: 0,
              padding: .symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: .w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmLogout == true && context.mounted) {
      await getIt<LocalNotificationService>().cancelAllNotifications();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      context.pushNamedAndRemoveUntil(
        Routes.onBoardingScreen,
        predicate: (route) => false,
      );
    }
  }

  void _openEditSheet(BuildContext context, CompanySettingsState state) {
    final cubit = context.read<CompanySettingsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditCompanyProfileSheet(
          initialName: state.companyName,
          initialAvatarUrl: state.avatarUrl,
        ),
      ),
    );
  }

  void _openRateAppDialog(BuildContext context, CompanySettingsState state) {
    final cubit = context.read<CompanySettingsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CompanyRateAppDialog(initialRating: state.savedRating),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBarWithoutLeading(text: 'Settings'),
      body: BlocBuilder<CompanySettingsCubit, CompanySettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 110.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section: Company Profile Summary & Quick Edit Card
                CompanySummaryCard(
                  companyName: state.companyName,
                  avatarUrl: state.avatarUrl,
                  isLoading: state.isLoadingProfile,
                  onEditTap: () => _openEditSheet(context, state),
                ),
                verticalSpace(24),

                // Middle Section: SUPPORT & INFO
                SettingsGroupCard(
                  title: 'SUPPORT & INFO',
                  children: [
                    SettingsTileItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About Us',
                      subtitle: 'Learn More About JOBY',
                      onTap: () => context.pushNamed(Routes.aboutUsScreen),
                    ),
                    SettingsTileItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Feedback?',
                      onTap: () => context.pushNamed(Routes.feedBackScreen),
                    ),
                    SettingsTileItem(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate App',
                      subtitle: state.savedRating != null
                          ? 'You Rated JOBY ${state.savedRating!.rating}/5'
                          : 'Rate Your Experience With JOBY',
                      onTap: () => _openRateAppDialog(context, state),
                    ),
                  ],
                ),
                verticalSpace(28),

                // Bottom Action: Styled Logout Button
                InkWell(
                  onTap: () => _handleLogout(context),
                  borderRadius: .circular(16.r),
                  child: Container(
                    padding: .symmetric(vertical: 15.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: .circular(16.r),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade600,
                          size: 20.sp,
                        ),
                        horizontalSpace(8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'BrunoAceSC',
                            fontSize: 15.sp,
                            fontWeight: .bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
