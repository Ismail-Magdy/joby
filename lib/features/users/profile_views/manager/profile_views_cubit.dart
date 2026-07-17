import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/users/profile_views/data/models/profile_view_model.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewsCubit extends Cubit<ProfileViewsState> {
  ProfileViewsCubit() : super(ProfileViewsInitial());

  Future<void> fetchViews() async {
    emit(ProfileViewsLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(ProfileViewsError("User not authenticated"));
        return;
      }

      final data = await Supabase.instance.client
          .from('profile_views')
          .select('viewed_at, companies(id, name, avatar_url)')
          .eq('seeker_id', userId)
          .order('viewed_at', ascending: false);

      if (data.isEmpty) {
        emit(ProfileViewsEmpty());
      } else {
        final views = data.map((e) => ProfileViewModel.fromJson(e)).toList();

        final now = DateTime.now();
        int viewsThisWeek = 0;
        int viewsLastWeek = 0;

        for (var view in views) {
          final diffInDays = now.difference(view.viewedAt).inDays;
          if (diffInDays <= 7) {
            viewsThisWeek++;
          } else if (diffInDays > 7 && diffInDays <= 14) {
            viewsLastWeek++;
          }
        }

        final bool isTrendUp = viewsThisWeek >= viewsLastWeek;
        final int trendDifference = (viewsThisWeek - viewsLastWeek).abs();

        emit(
          ProfileViewsLoaded(
            views: views,
            totalViews: views.length,
            isTrendUp: isTrendUp,
            trendDifference: trendDifference,
          ),
        );
      }
    } catch (e) {
      emit(ProfileViewsError("Failed to load profile views"));
    }
  }
}
