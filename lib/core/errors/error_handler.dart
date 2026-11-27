import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Converts any given exception into a user-friendly string message.
  static String handleError(dynamic error) {
    if (error == null) {
      return "An Unexpected Error Occurred";
    }

    // 1. Handle Supabase Auth Exceptions
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case "invalid login credentials":
          return "Invalid Email Or Password";
        case "user already registered":
          return "An Account With This Email Already Exists";
        case "email rate limit exceeded":
          return "Too Many Requests";
        default:
          return "Authentication Failed";
      }
    }

    // 2. Handle Supabase Database Exceptions (Postgrest)
    if (error is PostgrestException) {
      if (error.message.contains("duplicate key value")) {
        return "The Information You Entered Already Exists";
      } else if (error.code == "23503") {
        // Foreign key violation
        return "Invalid Reference, The Selected Item Does Not Exist";
      } else if (error.code == "PGRST116") {
        return "Requested Data Was Not Found";
      }
      return "Failed To Load Data";
    }

    // 3. Handle Supabase Storage Exceptions
    if (error is StorageException) {
      if (error.message.contains("The resource was not found")) {
        return "The Requested File Could Not Be Found";
      } else if (error.statusCode == "413") {
        return "The File Size Is Too Large";
      }
      return "A problem Occurred With File Storage";
    }

    // 4. Handle Common Network & Base Exceptions
    if (error is SocketException) {
      return "No Internet Connection, Please Check Your Network";
    }

    if (error is TimeoutException) {
      return "The Connection Timed Out";
    }

    // 5. Generic Error handling
    return "An Unexpected Error Occurred";
  }
}
