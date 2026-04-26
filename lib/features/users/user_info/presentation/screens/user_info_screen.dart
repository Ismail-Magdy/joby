import "dart:io";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:image_picker/image_picker.dart";
import "package:intl_phone_field/country_picker_dialog.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "package:joby/core/themes/app_colors.dart";
import "../../../../../core/helpers/extensions.dart";
import "../../data/models/user_info_model.dart";
import "../../manager/user_info_cubit.dart";
import "../../manager/user_info_state.dart";
import "package:file_picker/file_picker.dart";
import "package:intl_phone_field/intl_phone_field.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobCategoryController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();

  String? _selectedLevel;
  String? _selectedWorkType;

  String? _cvFileName;
  File? _cvFile;
  File? _pickedAvatarFile;

  String _completeWhatsappNumber = "";

  double _latitude = 30.0444; // Default to Cairo
  double _longitude = 31.2357;
  String _locationName = "Detecting location...";
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _locationName = "Location services disabled");
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _locationName = "Location permissions denied");
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(
          () => _locationName = "Location permissions permanently denied.",
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        _mapController.move(LatLng(_latitude, _longitude), 14.0);
        await _updateLocationName(_latitude, _longitude);
      }
    } catch (e) {
      if (mounted) setState(() => _locationName = "Error getting location.");
    }
  }

  Future<void> _updateLocationName(double lat, double lng) async {
    try {
      if (mounted) setState(() => _isLoadingLocation = true);
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        String loc = place.administrativeArea ?? "";
        if (place.country != null) {
          loc += (loc.isNotEmpty ? ", " : "") + place.country!;
        }
        if (mounted) {
          setState(
            () => _locationName = loc.isNotEmpty ? loc : "Unknown Location",
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _locationName = "Unknown Location");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  bool get _canSubmit {
    if (_currentStep != 2 && _currentStep != 3) return true;
    return _cvFile != null && _whatsappController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _whatsappController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedAvatarFile = File(image.path);
      });
    }
  }

  void _submitData(UserInfoCubit cubit) {
    if (_formKey.currentState!.validate()) {
      if (_cvFile == null || _whatsappController.text.isEmpty) return;

      final linkedinText = _linkedinController.text.trim();
      final githubText = _githubController.text.trim();

      final userInfo = UserInfoModel(
        name: _nameController.text.trim(),
        jobCategory: _jobCategoryController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        level: _selectedLevel!,
        typeOfWork: _selectedWorkType!,
        whatsapp: _completeWhatsappNumber,
        linkedin: linkedinText.isEmpty
            ? "https://www.linkedin.com"
            : linkedinText,
        github: githubText.isEmpty ? "https://github.com" : githubText,
        cvUrl: null,
        avatarUrl: null,
        locationName: _locationName,
        latitude: _latitude,
        longitude: _longitude,
      );

      cubit.saveUserInfo(
        userInfo,
        avatarFile: _pickedAvatarFile,
        cvFile: _cvFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Complete Your Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: .bold,
            fontSize: 18.sp,
            fontFamily: "BrunoAceSC",
          ),
        ),
        centerTitle: true,
      ),
      //
      body: BlocConsumer<UserInfoCubit, UserInfoState>(
        listener: (context, state) async {
          if (state is UserInfoSuccess) {
            // Success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(
                    "Profile saved successfully",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            //
            await SharedPrefHelper.setData("isUserInfoCompleted", true);
            //
            if (!context.mounted) return;
            //
            context.pushReplacementNamed(Routes.userRootScreen);
            //
          } else if (state is UserInfoError) {
            // Error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(state.message, style: TextStyle(fontSize: 14.sp)),
                ),
                backgroundColor: Colors.red,
              ),
            );
            //
          }
        },
        builder: (context, state) {
          final cubit = context.read<UserInfoCubit>();
          return Form(
            key: _formKey,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryColor,
                  onSurface: Colors.grey.shade400,
                ),
              ),
              child: Stepper(
                type: .vertical,
                physics: const BouncingScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                onStepContinue: () {
                  final isLastStep = _currentStep == 3;

                  if (_currentStep == 0) {
                    if (_pickedAvatarFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(
                              "Please upload your profile picture",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _currentStep += 1);
                  } else if (_currentStep == 1) {
                    if (_selectedLevel == null || _selectedWorkType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(
                              "Please select your Level and Type of Work",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() => _currentStep += 1);
                  } else if (_currentStep == 2) {
                    // Check step 2 valid before proceeding
                    if (_cvFile == null || _whatsappController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(
                              "Please fill WhatsApp and upload CV",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() => _currentStep += 1);
                  } else if (isLastStep) {
                    _submitData(cubit);
                  }
                },
                onStepCancel: _currentStep == 0
                    ? null
                    : () => setState(() => _currentStep -= 1),
                controlsBuilder: (context, details) {
                  final isLastStep = _currentStep == 3;
                  //
                  return Padding(
                    padding: .only(top: 20.h),
                    child: Row(
                      children: [
                        //
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (state is UserInfoLoading ||
                                    (isLastStep && !_canSubmit))
                                ? null
                                : details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: .symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: .circular(8.r),
                              ),
                            ),
                            child: state is UserInfoLoading && isLastStep
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isLastStep ? "Submit" : "Next",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: .bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        //
                        if (_currentStep != 0) ...[
                          //
                          horizontalSpace(12),
                          //
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                padding: .symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: .circular(8.r),
                                ),
                              ),
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          //
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  // Step One
                  Step(
                    state: _currentStep > 0 ? .complete : .indexed,
                    isActive: _currentStep >= 0,
                    title: Text(
                      "Basic Information",
                      style: TextStyle(fontSize: 16.sp, fontWeight: .bold),
                    ),
                    content: Column(
                      children: [
                        Center(
                          child: Stack(
                            alignment: .bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: .circle,
                                  border: .all(
                                    color: AppColors.primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60.r,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: _pickedAvatarFile != null
                                      ? FileImage(_pickedAvatarFile!)
                                      : null,
                                  child: _pickedAvatarFile == null
                                      ? Icon(
                                          CupertinoIcons.person,
                                          size: 70.sp,
                                          color: Colors.grey.shade400,
                                        )
                                      : null,
                                ),
                              ),
                              GestureDetector(
                                onTap: _pickAvatar,
                                child: CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: AppColors.primaryColor,
                                  child: SvgPicture.asset(
                                    "assets/svgs/camera.svg",
                                    colorFilter: .mode(Colors.white, .srcIn),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //
                        verticalSpace(25),
                        //
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                        //
                        verticalSpace(15),
                        //
                        TextFormField(
                          controller: _jobCategoryController,
                          decoration: const InputDecoration(
                            labelText: "Job Category (e.g. Graphic Design)",
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                        //
                        verticalSpace(15),
                        //
                        TextFormField(
                          controller: _jobTitleController,
                          decoration: const InputDecoration(
                            labelText: "Job Title (e.g. Flutter Developer)",
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  // Step Two
                  Step(
                    state: _currentStep > 1 ? .complete : .indexed,
                    isActive: _currentStep >= 1,
                    title: Text(
                      "Experience & Work Type",
                      style: TextStyle(fontSize: 16.sp, fontWeight: .bold),
                    ),
                    content: Column(
                      children: [
                        //
                        verticalSpace(10),
                        //
                        DropdownButtonFormField<String>(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryColor,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: .circular(12.r),
                          decoration: InputDecoration(
                            labelText: "Level",
                            prefixIcon: Icon(
                              Icons.leaderboard_outlined,
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: .symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: ["Junior", "Mid-Level", "Senior", "Lead"].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => _selectedLevel = newValue),
                        ),
                        //
                        verticalSpace(15),
                        //
                        DropdownButtonFormField<String>(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryColor,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: .circular(12.r),
                          decoration: InputDecoration(
                            labelText: "Type of Work",
                            prefixIcon: Icon(
                              Icons.business_center_outlined,
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: .symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: ["Remote", "On-site", "Hybrid"].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => _selectedWorkType = newValue),
                        ),
                        //
                      ],
                    ),
                  ),
                  // Step Three
                  Step(
                    isActive: _currentStep >= 2,
                    title: Text(
                      "Links & Resume",
                      style: TextStyle(fontSize: 16.sp, fontWeight: .bold),
                    ),
                    content: Column(
                      children: [
                        //
                        verticalSpace(10),
                        //
                        IntlPhoneField(
                          cursorColor: AppColors.primaryColor,
                          controller: _whatsappController,
                          initialCountryCode: "EG",
                          // ===================================
                          pickerDialogStyle: PickerDialogStyle(
                            backgroundColor: Colors.white,
                          ),
                          // ===================================
                          decoration: InputDecoration(
                            labelText: "WhatsApp Number",
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: .circular(12.r),
                            ),
                          ),
                          onChanged: (phone) {
                            setState(() {
                              _completeWhatsappNumber = phone.completeNumber;
                            });
                          },
                          onCountryChanged: (country) {
                            setState(() {});
                          },
                        ),
                        //
                        verticalSpace(15),
                        //
                        TextFormField(
                          controller: _linkedinController,
                          decoration: const InputDecoration(
                            labelText: "LinkedIn URL (Optional)",
                            prefixIcon: Icon(Icons.link),
                          ),
                        ),
                        //
                        verticalSpace(15),
                        //
                        TextFormField(
                          controller: _githubController,
                          decoration: const InputDecoration(
                            labelText: "GitHub URL (Optional)",
                            prefixIcon: Icon(Icons.code),
                          ),
                        ),
                        //
                        verticalSpace(20),
                        //
                        GestureDetector(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: .custom,
                                  allowedExtensions: ["pdf"],
                                );

                            if (result != null &&
                                result.files.single.path != null) {
                              setState(() {
                                _cvFile = File(result.files.single.path!);
                                _cvFileName = result.files.single.name;
                              });
                            }
                          },
                          child: Container(
                            width: .infinity,
                            padding: .symmetric(vertical: 15.h),
                            decoration: BoxDecoration(
                              border: .all(
                                color: _cvFile == null
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
                                  _cvFileName == null
                                      ? "Upload CV (PDF) *"
                                      : "CV Uploaded: $_cvFileName",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: _cvFileName != null
                                        ? .bold
                                        : .normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Step Four
                  Step(
                    isActive: _currentStep >= 3,
                    title: Text(
                      "Location",
                      style: TextStyle(fontSize: 16.sp, fontWeight: .bold),
                    ),
                    content: Column(
                      children: [
                        verticalSpace(10),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 24.sp,
                            ),
                            horizontalSpace(8),
                            Expanded(
                              child: Text(
                                _locationName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: .w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (_isLoadingLocation)
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                          ],
                        ),
                        verticalSpace(15),
                        Container(
                          height: 250.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: .circular(12.r),
                            border: .all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: .circular(12.r),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      _latitude,
                                      _longitude,
                                    ),
                                    initialZoom: 14.0,
                                    onPositionChanged: (camera, hasGesture) {
                                      if (hasGesture) {
                                        _latitude = camera.center.latitude;
                                        _longitude = camera.center.longitude;
                                      }
                                    },
                                    onMapEvent: (event) {
                                      if (event is MapEventMoveEnd) {
                                        _updateLocationName(
                                          _latitude,
                                          _longitude,
                                        );
                                      }
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      userAgentPackageName: 'com.example.joby',
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// 827