import 'dart:io';
import 'package:dartz/dartz.dart';

abstract class CompanyInfoRepo {
  Future<Either<String, void>> completeCompanyInfo({
    required String name,
    String? profileImageUrl,
    File? profileImageFile,
  });
}
