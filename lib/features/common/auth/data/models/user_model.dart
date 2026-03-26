import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uId;
  final String email;
  final String name;
  final String userType;

  const UserModel({
    required this.uId,
    required this.email,
    required this.name,
    required this.userType,
  });

  factory UserModel.fromSupabase(dynamic supabaseUser) {
    return UserModel(
      uId: supabaseUser.id,
      email: supabaseUser.email ?? "",
      name: supabaseUser.userMetadata?["name"] ?? "",
      userType: supabaseUser.userMetadata?["user_type"] ?? "",
    );
  }

  @override
  List<Object?> get props => [uId, email, name, userType];
}
