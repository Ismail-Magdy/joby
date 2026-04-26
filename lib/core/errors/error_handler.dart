import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Converts any given exception into a user-friendly string message.
  static String handleError(dynamic error) {
    if (error == null) {
      return "An unexpected error occurred. Please try again";
    }

    // 1. Handle Supabase Auth Exceptions
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case "invalid login credentials":
          return "Invalid email or password. Please check your credentials";
        case "user already registered":
          return "An account with this email already exists";
        case "email rate limit exceeded":
          return "Too many requests. Please try again later";
        default:
          return "Authentication failed. Please try again";
      }
    }

    // 2. Handle Supabase Database Exceptions (Postgrest)
    if (error is PostgrestException) {
      if (error.message.contains("duplicate key value")) {
        return "The information you entered already exists";
      } else if (error.code == "23503") {
        // Foreign key violation
        return 'Invalid reference. The selected item does not exist';
      } else if (error.code == 'PGRST116') {
        return 'Requested data was not found';
      }
      return 'Failed to load data. Please try again later';
    }

    // 3. Handle Supabase Storage Exceptions
    if (error is StorageException) {
      if (error.message.contains('The resource was not found')) {
        return 'The requested file could not be found';
      } else if (error.statusCode == '413') {
        return 'The file size is too large';
      }
      return 'A problem occurred with file storage. Please try again';
    }

    // 4. Handle Common Network & Base Exceptions
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again';
    }

    if (error is TimeoutException) {
      return 'The connection timed out. Please try again';
    }

    // 5. Generic Error handling
    return 'An unexpected error occurred. Please try again later';
  }
}
