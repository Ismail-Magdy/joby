import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class StepThreeContent extends StatelessWidget {
  const StepThreeContent({
    super.key,
    required this.whatsappController,
    required this.onChangedPhone,
    required this.onChangedCountry,
    required this.isPhoneValid,
    required this.linkedinController,
    required this.githubController,
    required this.behanceController,
    required this.linkedinValidator,
    required this.githubValidator,
    required this.behanceValidator,
    required this.onTapCV,
    required this.cvFile,
    required this.cvFileName,
    this.initialCountryCode = "EG",
  });

  final TextEditingController whatsappController;
  final TextEditingController linkedinController;
  final TextEditingController githubController;
  final TextEditingController behanceController;
  //
  final void Function(PhoneNumber)? onChangedPhone;
  final void Function(Country)? onChangedCountry;
  //
  final bool isPhoneValid;
  //
  final String? Function(String?)? linkedinValidator;
  final String? Function(String?)? githubValidator;
  final String? Function(String?)? behanceValidator;
  //
  final void Function()? onTapCV;
  //
  final File? cvFile;
  final String? cvFileName;
  final String initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
        verticalSpace(10),
        //
        IntlPhoneField(
          cursorColor: AppColors.primaryColor,
          controller: whatsappController,
          initialCountryCode: initialCountryCode,
          invalidNumberMessage: "Invalid number for the selected country",
          //
          pickerDialogStyle: PickerDialogStyle(backgroundColor: Colors.white),
          //
          decoration: InputDecoration(
            labelText: "WhatsApp Number",
            counterText: "",
            border: OutlineInputBorder(borderRadius: .circular(12.r)),
          ),
          onChanged: onChangedPhone,
          onCountryChanged: onChangedCountry,
        ),
        //
        if (isPhoneValid && whatsappController.text.isNotEmpty)
          Padding(
            padding: .only(top: 8.h),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                horizontalSpace(5),
                Text(
                  "Valid Phone Number Format",
                  style: TextStyle(color: Colors.green, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        //
        verticalSpace(15),
        //
        TextFormField(
          controller: linkedinController,
          decoration: const InputDecoration(
            labelText: "LinkedIn URL (Optional)",
            hintText: "https://linkedin.com/in/username",
            prefixIcon: Icon(Icons.link),
          ),
          validator: linkedinValidator,
        ),
        //
        verticalSpace(15),
        //
        TextFormField(
          controller: githubController,
          decoration: const InputDecoration(
            labelText: "GitHub URL (Optional)",
            hintText: "https://github.com/username",
            prefixIcon: Icon(Icons.code),
          ),
          validator: githubValidator,
        ),
        //
        verticalSpace(15),
        //
        TextFormField(
          controller: behanceController,
          decoration: const InputDecoration(
            labelText: "Behance URL (Optional)",
            hintText: "https://behance.net/username",
            prefixIcon: Icon(Icons.palette_outlined),
          ),
          validator: behanceValidator,
        ),
        //
        verticalSpace(20),
        //
        GestureDetector(
          onTap: onTapCV,
          child: Container(
            width: .infinity,
            padding: .symmetric(vertical: 15.h),
            decoration: BoxDecoration(
              border: .all(
                color: cvFile == null
                    ? Colors.grey.shade400
                    : AppColors.primaryColor,
                style: .solid,
              ),
              borderRadius: .circular(8.r),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                verticalSpace(8),
                Text(
                  cvFileName == null ? "Upload CV (PDF) *" : "$cvFileName",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: cvFileName != null ? .bold : .normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    //
  }
}
