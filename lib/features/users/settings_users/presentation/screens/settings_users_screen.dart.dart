import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar_without_leading.dart';
import 'package:joby/core/widgets/custom_feedback_dialog.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../manager/settings_users_cubit.dart';
import '../../manager/settings_users_state.dart';
import '../widgets/rate_app_dialog.dart';
import '../widgets/settings_group_card.dart';

class SettingsUsersScreen extends StatelessWidget {
  const SettingsUsersScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: .circular(20.r)),
        title: Text(
          "Logout",
          style: TextStyle(
            fontFamily: "BrunoAceSC",
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

  void _openRateAppDialog(BuildContext context, SettingsUsersState state) {
    final cubit = context.read<SettingsUsersCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: RateAppDialog(initialRating: state.savedRating),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBarWithoutLeading(text: "Settings"),
      body: BlocConsumer<SettingsUsersCubit, SettingsUsersState>(
        listenWhen: (previous, current) =>
            current.visibilityError != null &&
            current.visibilityError != previous.visibilityError,
        listener: (context, state) {
          if (state.visibilityError != null) {
            CustomFeedbackDialog.showError(
              context,
              title: "Update Failed",
              message: state.visibilityError!,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: .fromLTRB(20.w, 18.h, 20.w, 110.h),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                // Section 1: ACCOUNT & PRIVACY
                SettingsGroupCard(
                  title: "ACCOUNT & PRIVACY",
                  children: [
                    SettingsTileItem(
                      icon: Icons.visibility_outlined,
                      title: "Profile Visibility",
                      subtitle: "Allow Companies To Discover Your Profile",
                      trailing: Switch.adaptive(
                        value: state.isVisible,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: state.isUpdatingVisibility
                            ? null
                            : (val) => context
                                  .read<SettingsUsersCubit>()
                                  .toggleProfileVisibility(val),
                      ),
                    ),
                  ],
                ),
                verticalSpace(22),

                // Section 2: PREFERENCES
                SettingsGroupCard(
                  title: "PREFERENCES",
                  children: [
                    SettingsTileItem(
                      icon: Icons.notifications_active_outlined,
                      title: 'Daily Notifications',
                      subtitle:
                          'Receive Daily Check In, Mini Game, and Profile View Reminders',
                      trailing: Switch.adaptive(
                        value: state.isDailyNotificationsEnabled,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: (val) => context
                            .read<SettingsUsersCubit>()
                            .toggleDailyNotifications(val),
                      ),
                    ),
                  ],
                ),
                verticalSpace(22),

                // Section 3: SUPPORT & INFO
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
                      subtitle: 'Rate Your Experience With JOBY',
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
                      border: .all(color: Colors.red.withValues(alpha: 0.25)),
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
                verticalSpace(28),
              ],
            ),
          );
        },
      ),
    );
  }
}
// 245
