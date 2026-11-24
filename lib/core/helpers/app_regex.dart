class AppRegex {
  static bool isEmailValid(String email) {
    return RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    return RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
    ).hasMatch(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(phoneNumber);
  }

  static bool hasLowerCase(String password) {
    return RegExp(r'^(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'^(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'^(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'^(?=.{8,})').hasMatch(password);
  }

  /// Validates a password on the Login screen (non-empty check only, no policy leaks).
  static String? validateLoginPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  /// Validates a new password on Sign Up or Password Reset (enforces full policy).
  static String? validateNewPassword(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "Please enter a password";
    if (v.length < 8) {
      return "At least 8 characters";
    }
    if (!hasUpperCase(v)) {
      return "Include an uppercase letter";
    }
    if (!hasLowerCase(v)) {
      return "Include a lowercase letter";
    }
    if (!hasNumber(v)) {
      return "Include a number";
    }
    if (!hasSpecialCharacter(v)) {
      return "Include a special character (!@#\$%^&*)";
    }
    return null;
  }
}
