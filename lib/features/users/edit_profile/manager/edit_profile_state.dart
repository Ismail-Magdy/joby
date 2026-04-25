import 'dart:io';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

// Avatar picked from gallery
class EditProfileAvatarPicked extends EditProfileState {
  final File file;
  EditProfileAvatarPicked({required this.file});
}

// CV file picked
class EditProfileCvPicked extends EditProfileState {
  final File file;
  final String fileName;
  EditProfileCvPicked({required this.file, required this.fileName});
}

// Save states
class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}
