import 'dart:io';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

// حالة اختيار الـ CV
class EditProfileCvPicked extends EditProfileState {
  final File file;
  final String fileName;
  EditProfileCvPicked({required this.file, required this.fileName});
}

// حالات الحفظ (Loading, Success, Error)
class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}
