import "dart:io";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:image_picker/image_picker.dart";
import "package:image_cropper/image_cropper.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:joby/core/widgets/custom_app_bar_without_leading.dart";
import "package:joby/core/widgets/exit_confirmation_wrapper.dart";
import "package:joby/core/widgets/custom_feedback_dialog.dart";
import "package:joby/features/users/user_info/presentation/components/step_four_content.dart";
import "package:joby/features/users/user_info/presentation/components/step_one_content.dart";
import "package:joby/features/users/user_info/presentation/components/step_three_content.dart";
import "package:joby/features/users/user_info/presentation/components/step_two_content.dart";
import "package:joby/features/users/user_info/presentation/widgets/custom_two_buttons_row.dart";
import "package:joby/features/users/user_info/data/models/location_picker_result.dart";
import "package:joby/core/helpers/extensions.dart";
import "package:joby/features/users/user_info/presentation/widgets/step_title.dart";
import "../../data/models/user_info_model.dart";
import "../../manager/user_info_cubit.dart";
import "../../manager/user_info_state.dart";
import "package:file_picker/file_picker.dart";
import "package:intl_phone_field/countries.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'location_picker_screen.dart';

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
  final TextEditingController _behanceController = TextEditingController();

  String? _selectedLevel;
  String? _selectedWorkType;

  String? _cvFileName;
  File? _cvFile;
  File? _pickedAvatarFile;

  String _completeWhatsappNumber = "";
  bool _isPhoneValid = false;
  Country _selectedCountry = countries.firstWhere((c) => c.code == 'EG');

  double _latitude = 30.0444; // Default to Cairo
  double _longitude = 31.2357;
  String _locationName = "Detecting Location";
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  String? _networkAvatarUrl;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchUserMetadata();
  }

  void _fetchUserMetadata() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      if (metadata != null) {
        if (metadata['full_name'] != null &&
            metadata['full_name'].toString().isNotEmpty) {
          _nameController.text = metadata['full_name'];
        } else if (metadata['name'] != null &&
            metadata['name'].toString().isNotEmpty) {
          _nameController.text = metadata['name'];
        }

        if (metadata['avatar_url'] != null &&
            metadata['avatar_url'].toString().isNotEmpty) {
          setState(() {
            _networkAvatarUrl = metadata['avatar_url'];
          });
        } else if (metadata['picture'] != null &&
            metadata['picture'].toString().isNotEmpty) {
          setState(() {
            _networkAvatarUrl = metadata['picture'];
          });
        }
      }
    }
  }

  /// Determine Position
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _locationName = "Location Services Disabled");
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _locationName = "Location Permissions Denied");
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(
          () => _locationName = "Location Permissions Permanently Denied",
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
      if (mounted) setState(() => _locationName = "Error Getting Location");
    }
  }

  /// Update Location Name
  Future<void> _updateLocationName(double lat, double lng) async {
    try {
      if (mounted) setState(() => _isLoadingLocation = true);

      await geocoding.setLocaleIdentifier("en");

      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];

        String city = place.administrativeArea ?? place.locality ?? "";
        String country = place.country ?? "";
        String loc = city.isNotEmpty ? "$city, $country" : country;

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

  ///
  bool get _canSubmit {
    if (_currentStep != 2 && _currentStep != 3) return true;
    return _cvFile != null &&
        _whatsappController.text.isNotEmpty &&
        _isPhoneValid;
  }

  /// URL validators for social links
  String? _validateLinkedinUrl(String? val) {
    if (val == null || val.trim().isEmpty) return null; // optional
    final v = val.trim().toLowerCase();
    if (!v.contains("linkedin.com")) {
      return "Enter a Valid LinkedIn URL";
    }
    return null;
  }

  String? _validateGithubUrl(String? val) {
    if (val == null || val.trim().isEmpty) return null; // optional
    final v = val.trim().toLowerCase();
    if (!v.contains('github.com')) {
      return "Enter a Valid GitHub URL";
    }
    return null;
  }

  String? _validateBehanceUrl(String? val) {
    if (val == null || val.trim().isEmpty) return null; // optional
    final v = val.trim().toLowerCase();
    if (!v.contains('behance.net')) {
      return "Enter a Valid Behance URL";
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _whatsappController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _behanceController.dispose();
    super.dispose();
  }

  /// Pick Avatar
  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: .gallery);

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            activeControlsWidgetColor: AppColors.primaryColor,
            hideBottomControls: false,
            toolbarTitle: "Crop Image",
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: "Crop Image"),
        ],
      );

      final selectedPath = croppedFile?.path ?? image.path;
      String cleanPath = selectedPath;
      if (cleanPath.startsWith("file://")) {
        try {
          cleanPath = Uri.parse(cleanPath).toFilePath();
        } catch (_) {
          cleanPath = cleanPath.replaceFirst("file://", "");
        }
      }

      setState(() {
        _pickedAvatarFile = File(cleanPath);
      });
    }
  }

  /// Open the full-screen location picker
  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialLocationName: _locationName,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _locationName = result.locationName;
      });
      _mapController.move(LatLng(_latitude, _longitude), 14.0);
    }
  }

  /// Submit Data
  void _submitData(UserInfoCubit cubit) {
    if (_formKey.currentState!.validate()) {
      if (_cvFile == null || _whatsappController.text.isEmpty) return;

      final linkedinText = _linkedinController.text.trim();
      final githubText = _githubController.text.trim();
      final behanceText = _behanceController.text.trim();

      final userInfo = UserInfoModel(
        name: _nameController.text.trim(),
        jobCategory: _jobCategoryController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        level: _selectedLevel!,
        typeOfWork: _selectedWorkType!,
        whatsapp: _completeWhatsappNumber,
        linkedin: linkedinText.isEmpty ? null : linkedinText,
        github: githubText.isEmpty ? null : githubText,
        behance: behanceText.isEmpty ? null : behanceText,
        cvUrl: null,
        avatarUrl: _networkAvatarUrl,
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
    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        // App Bar
        appBar: CustomAppBarWithoutLeading(text: "Complete Your Profile"),
        //
        body: BlocConsumer<UserInfoCubit, UserInfoState>(
          listener: (context, state) async {
            if (state is UserInfoSuccess) {
              await SharedPrefHelper.setData("isUserInfoCompleted", true);
              if (!context.mounted) return;
              CustomFeedbackDialog.showSuccess(
                context,
                title: "Success",
                message: "Profile saved successfully",
                onFinish: () {
                  if (!context.mounted) return;
                  context.pushReplacementNamed(Routes.userRootScreen);
                },
              );
            } else if (state is UserInfoError) {
              CustomFeedbackDialog.showError(
                context,
                title: "Save Failed",
                message: state.message,
              );
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
                    onSurface: Colors.black87,
                  ),
                ),
                //
                child: Stepper(
                  type: .vertical,
                  physics: const BouncingScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: null,
                  onStepContinue: () {
                    final isLastStep = _currentStep == 3;

                    if (_currentStep == 0) {
                      if (_pickedAvatarFile == null &&
                          _networkAvatarUrl == null) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "Picture Required",
                          message: "Upload Your Profile Picture",
                        );
                        return;
                      }
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _currentStep += 1);
                    } else if (_currentStep == 1) {
                      if (_selectedLevel == null || _selectedWorkType == null) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "Selection Required",
                          message: "Select Your Level and Type of Work",
                        );
                        return;
                      }
                      setState(() => _currentStep += 1);
                    } else if (_currentStep == 2) {
                      // Check step 2 valid before proceeding
                      if (_cvFile == null && _whatsappController.text.isEmpty) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "Details Required",
                          message: "Fill WhatsApp Number and Upload CV",
                        );
                        return;
                      } else if (_whatsappController.text.isEmpty) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "WhatsApp Required",
                          message: "Enter Your WhatsApp Number",
                        );
                        return;
                      } else if (!_isPhoneValid) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "Invalid Number",
                          message: "Enter a Valid WhatsApp Number",
                        );
                        return;
                      } else if (_cvFile == null) {
                        CustomFeedbackDialog.showWarning(
                          context,
                          title: "CV Required",
                          message: "Upload Your CV",
                        );
                        return;
                      }
                      //
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
                    return CustomTwoButtonsRow(
                      onPressed:
                          (state is UserInfoLoading ||
                              (isLastStep && !_canSubmit))
                          ? null
                          : details.onStepContinue,
                      currentStep: _currentStep,
                      onStepCancelpressed: details.onStepCancel,
                      child: state is UserInfoLoading && isLastStep
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              isLastStep ? "Submit" : "Next",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                    //
                  },
                  steps: [
                    //
                    // Step One
                    Step(
                      state: _currentStep > 0 ? .complete : .indexed,
                      isActive: _currentStep >= 0,
                      title: const StepTitle(title: "Basic Information"),
                      content: StepOneContent(
                        backgroundImage: _pickedAvatarFile != null
                            ? FileImage(_pickedAvatarFile!)
                            : (_networkAvatarUrl != null
                                      ? NetworkImage(_networkAvatarUrl!)
                                      : null)
                                  as ImageProvider<Object>?,
                        pickedAvatarFile: _pickedAvatarFile,
                        onTapPickAvatar: _pickAvatar,
                        nameController: _nameController,
                        jobCategoryController: _jobCategoryController,
                        jobTitleController: _jobTitleController,
                      ),
                    ),
                    //
                    // Step Two
                    Step(
                      state: _currentStep > 1 ? .complete : .indexed,
                      isActive: _currentStep >= 1,
                      title: const StepTitle(title: "Experience & Work Type"),
                      content: StepTwoContent(
                        onChangedLevel: (newValue) =>
                            setState(() => _selectedLevel = newValue),
                        onChangedTypeOfWork: (newValue) =>
                            setState(() => _selectedWorkType = newValue),
                      ),
                      //
                    ),
                    //
                    // Step Three
                    Step(
                      state: _currentStep > 2 ? .complete : .indexed,
                      isActive: _currentStep >= 2,
                      title: const StepTitle(title: "Links & Resume"),
                      content: StepThreeContent(
                        whatsappController: _whatsappController,
                        linkedinController: _linkedinController,
                        githubController: _githubController,
                        behanceController: _behanceController,
                        cvFile: _cvFile,
                        cvFileName: _cvFileName,
                        isPhoneValid: _isPhoneValid,
                        onChangedPhone: (phone) {
                          setState(() {
                            _completeWhatsappNumber = phone.completeNumber;
                            _isPhoneValid =
                                phone.number.length >=
                                    _selectedCountry.minLength &&
                                phone.number.length <=
                                    _selectedCountry.maxLength;
                          });
                        },
                        onChangedCountry: (country) {
                          setState(() {
                            _selectedCountry = country;
                            if (_whatsappController.text.isNotEmpty) {
                              _isPhoneValid =
                                  _whatsappController.text.length >=
                                      _selectedCountry.minLength &&
                                  _whatsappController.text.length <=
                                      _selectedCountry.maxLength;
                            }
                          });
                        },
                        linkedinValidator: _validateLinkedinUrl,
                        githubValidator: _validateGithubUrl,
                        behanceValidator: _validateBehanceUrl,
                        onTapCV: () async {
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
                      ),
                    ),
                    //
                    // Step Four
                    Step(
                      isActive: _currentStep >= 3,
                      title: const StepTitle(title: "Location"),
                      content: StepFourContent(
                        locationName: _locationName,
                        isLoadingLocation: _isLoadingLocation,
                        mapController: _mapController,
                        latitude: _latitude,
                        longitude: _longitude,
                        onTap: _openLocationPicker,
                      ),
                    ),
                    //
                  ],
                ),
                //
              ),
            );
          },
        ),
      ),
    );
  }
}
