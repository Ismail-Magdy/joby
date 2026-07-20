import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/job_suggestions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/autocomplete_text_field.dart';

class StepOneContent extends StatelessWidget {
  const StepOneContent({
    super.key,
    required this.backgroundImage,
    required this.pickedAvatarFile,
    required this.onTapPickAvatar,
    required this.nameController,
    required this.jobCategoryController,
    required this.jobTitleController,
  });
  final ImageProvider<Object>? backgroundImage;
  final File? pickedAvatarFile;
  final void Function() onTapPickAvatar;
  final TextEditingController nameController;
  final TextEditingController jobCategoryController;
  final TextEditingController jobTitleController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: .bottomRight,
            children: [
              //
              Container(
                decoration: BoxDecoration(
                  shape: .circle,
                  border: .all(color: AppColors.primaryColor, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? Icon(
                          CupertinoIcons.person,
                          size: 70.sp,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
              ),
              //
              GestureDetector(
                onTap: onTapPickAvatar,
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primaryColor,
                  child: SvgPicture.asset(
                    backgroundImage == null
                        ? "assets/svgs/camera.svg"
                        : "assets/svgs/pen_edit.svg",
                    colorFilter: const .mode(Colors.white, .srcIn),
                  ),
                ),
              ),
              //
            ],
          ),
        ),
        //
        verticalSpace(25),
        // Name
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Full Name",
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (val) {
            final v = val?.trim() ?? "";
            if (v.isEmpty) return "Please enter your name";
            if (v.length < 2) {
              return "Name must be at least 2 characters";
            }

            if (RegExp(r'[0-9]').hasMatch(v)) {
              return "Name cannot contain numbers";
            }

            if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(v)) {
              return "Name can only contain letters";
            }
            return null;
          },
        ),
        //
        verticalSpace(15),
        //
        AutocompleteTextField(
          controller: jobCategoryController,
          labelText: "Job Category (e.g. Graphic Design)",
          prefixIcon: Icons.category_outlined,
          suggestions: JobSuggestions.categories,
          validator: (val) {
            final text = val?.trim() ?? "";
            if (text.isEmpty) return "Required";
            if (!JobSuggestions.categories.contains(text)) {
              return "Please select a valid category from the suggestions";
            }
            return null;
          },
        ),
        //
        verticalSpace(15),
        //
        AutocompleteTextField(
          controller: jobTitleController,
          labelText: "Job Title (e.g. Flutter Developer)",
          prefixIcon: Icons.work_outline,
          suggestions: JobSuggestions.titles,
          validator: (val) {
            final text = val?.trim() ?? "";
            if (text.isEmpty) return "Required";
            if (!JobSuggestions.titles.contains(text)) {
              return "Please select a valid job title from the suggestions";
            }
            return null;
          },
        ),
        //
      ],
    );
    //
  }
}
