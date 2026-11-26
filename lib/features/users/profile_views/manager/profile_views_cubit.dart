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
        emit(ProfileViewsError("User Not Authenticated"));
        return;
      }

      final data = await Supabase.instance.client
          .from('profile_views')
          .select("viewed_at, companies(id, name, avatar_url)")
          .eq('seeker_id', userId)
          .order('viewed_at', ascending: false);

      if (data.isEmpty) {
        emit(ProfileViewsEmpty());
      } else {
        final rawViews = data.map((e) => ProfileViewModel.fromJson(e)).toList();

        //
        final List<ProfileViewModel> uniqueViews = [];
        for (var view in rawViews) {
          if (uniqueViews.isEmpty) {
            uniqueViews.add(view);
          } else {
            //
            if (uniqueViews.last.companyId == view.companyId) {
              uniqueViews.last.viewCount++;
            } else {
              uniqueViews.add(view);
            }
          }
        }

        //
      }
    } catch (e) {
      emit(ProfileViewsError("Failed to Load Profile Views"));
    }
  }
}
