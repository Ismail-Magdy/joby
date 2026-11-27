import 'package:flutter/material.dart';
import 'package:joby/core/widgets/app_skeletonizer.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/company/user_details/screens/talent_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

class CompanyViewScreen extends StatefulWidget {
  const CompanyViewScreen({super.key});

  @override
  State<CompanyViewScreen> createState() => _CompanyViewScreenState();
}

class _CompanyViewScreenState extends State<CompanyViewScreen> {
  UserInfoModel? user;
  bool isLoading = true;

  static final UserInfoModel _dummyUser = UserInfoModel(
    id: "",
    name: "Placeholder User Name",
    jobCategory: "Software",
    jobTitle: "Senior Flutter Developer",
    level: "Senior",
    typeOfWork: "Full Time",
    whatsapp: "01000000000",
    linkedin: "https://linkedin.com",
    github: "https://github.com",
    behance: "https://behance.net",
    cvUrl: "https://example.com/cv.pdf",
    avatarUrl: null,
    totalPoints: 1250,
    locationName: "Cairo, Egypt",
    latitude: 0.0,
    longitude: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _fetchMyData();
  }

  ///
  Future<void> _fetchMyData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('seekers')
          .select()
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          user = UserInfoModel.fromJson(data);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && user == null) {
      return ErrorScreen();
    }

    return AppSkeletonizer(
      enabled: isLoading,
      child: TalentDetailsScreen(
        seeker: isLoading ? _dummyUser : user!,
        isPreview: true,
      ),
    );
  }
}
