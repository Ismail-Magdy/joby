import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;

/// Centralized helper for reverse geocoding and location string normalization.
///
/// Always enforces English (`en_US`) locale for geocoding and normalizes any
/// legacy or device-cached Arabic location segments into clean English.
class LocationHelper {
  LocationHelper._();

  static final RegExp _arabicRegex = RegExp(r'[\u0600-\u06FF]');

  /// Common Arabic-to-English mappings for Egyptian governorates, major Arab
  /// cities, and countries so legacy Supabase records and device-locale leaks
  /// always display cleanly in English.
  static const Map<String, String> _arabicToEnglishMap = {
    // Countries
    'مصر': 'Egypt',
    'جمهورية مصر العربية': 'Egypt',
    'السعودية': 'Saudi Arabia',
    'المملكة العربية السعودية': 'Saudi Arabia',
    'الإمارات': 'UAE',
    'الامارات': 'UAE',
    'الإمارات العربية المتحدة': 'UAE',
    'الامارات العربية المتحدة': 'UAE',
    'قطر': 'Qatar',
    'دولة قطر': 'Qatar',
    'الكويت': 'Kuwait',
    'دولة الكويت': 'Kuwait',
    'البحرين': 'Bahrain',
    'مملكة البحرين': 'Bahrain',
    'عمان': 'Oman',
    'سلطنة عمان': 'Oman',
    'الأردن': 'Jordan',
    'الاردن': 'Jordan',
    'المملكة الأردنية الهاشمية': 'Jordan',
    'لبنان': 'Lebanon',
    'العراق': 'Iraq',
    'المغرب': 'Morocco',
    'تونس': 'Tunisia',
    'الجزائر': 'Algeria',
    'ليبيا': 'Libya',
    'السودان': 'Sudan',
    'فلسطين': 'Palestine',
    'سوريا': 'Syria',
    'اليمن': 'Yemen',

    // Egyptian Governorates & Cities
    'القاهرة': 'Cairo',
    'الجيزة': 'Giza',
    'الاسكندرية': 'Alexandria',
    'الإسكندرية': 'Alexandria',
    'القليوبية': 'Qalyubia',
    'الدقهلية': 'Daqahliya',
    'المنصورة': 'Mansoura',
    'الشرقية': 'Sharqia',
    'الغربية': 'Gharbia',
    'المنوفية': 'Menoufia',
    'البحيرة': 'Beheira',
    'كفر الشيخ': 'Kafr El Sheikh',
    'دمياط': 'Damietta',
    'بورسعيد': 'Port Said',
    'الإسماعيلية': 'Ismailia',
    'الاسماعيلية': 'Ismailia',
    'السويس': 'Suez',
    'الفيوم': 'Fayoum',
    'بني سويف': 'Beni Suef',
    'المنيا': 'Al Minya',
    'أسيوط': 'Assiut',
    'اسيوط': 'Assiut',
    'سوهاج': 'Sohag',
    'قنا': 'Qena',
    'الأقصر': 'Luxor',
    'الاقصر': 'Luxor',
    'أسوان': 'Aswan',
    'اسوان': 'Aswan',
    'البحر الأحمر': 'Red Sea',
    'البحر الاحمر': 'Red Sea',
    'الوادي الجديد': 'New Valley',
    'مطروح': 'Matrouh',
    'شمال سيناء': 'North Sinai',
    'جنوب سيناء': 'South Sinai',

    // Saudi / UAE / Qatar Major Cities
    'الرياض': 'Riyadh',
    'جدة': 'Jeddah',
    'الدمام': 'Dammam',
    'مكة': 'Mecca',
    'مكة المكرمة': 'Mecca',
    'المدينة المنورة': 'Al Madinah',
    'الخبر': 'Al Khobar',
    'تبوك': 'Tabuk',
    'دبي': 'Dubai',
    'أبوظبي': 'Abu Dhabi',
    'ابوظبي': 'Abu Dhabi',
    'الشارقة': 'Sharjah',
    'عجمان': 'Ajman',
    'الدوحة': 'Doha',
  };

  /// Normalizes English variants returned by different geocoders to clean,
  /// consistent English names.
  static const Map<String, String> _englishVariantsMap = {
    'al-qalyubia': 'Qalyubia',
    'al qalyubia': 'Qalyubia',
    'qalyubia': 'Qalyubia',
    'al-qalyubiyah': 'Qalyubia',
    'al qalyubiyah': 'Qalyubia',
    'qalyubiyah': 'Qalyubia',
    'el qalyubia': 'Qalyubia',
    'el-qalyubia': 'Qalyubia',
    'dakahlia': 'Daqahliya',
    'ad daqahliyah': 'Daqahliya',
    'al-sharqia': 'Sharqia',
    'ash sharqiyah': 'Sharqia',
    'al gharbiyah': 'Gharbia',
    'al minufiyah': 'Menoufia',
    'monufia': 'Menoufia',
    'al buhayrah': 'Beheira',
    'beheira': 'Beheira',
    'minya': 'Al Minya',
    'al minya': 'Al Minya',
    'asyut': 'Assiut',
    'faiyum': 'Fayoum',
  };

  /// Returns true if [text] contains any Arabic Unicode characters.
  static bool containsArabic(String text) => _arabicRegex.hasMatch(text);

  /// Reverse-geocodes [lat] and [lng] and returns a clean English location string
  /// such as `"Qalyubia, Egypt"` or `"Cairo, Egypt"`.
  static Future<String> getEnglishLocationName(double lat, double lng) async {
    try {
      await geocoding.setLocaleIdentifier('en_US');

      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = _firstNonEmpty([
          place.administrativeArea,
          place.locality,
          place.subAdministrativeArea,
        ]);
        final country = place.country ?? '';
        final raw = city.isNotEmpty && country.isNotEmpty
            ? '$city, $country'
            : (city.isNotEmpty ? city : country);

        final normalized = normalizeLocationName(raw);
        if (normalized.isNotEmpty && !containsArabic(normalized)) {
          return normalized;
        }
      }
    } catch (_) {
      // Fall through to Nominatim fallback if native geocoder fails
    }

    // Fallback to OpenStreetMap Nominatim with explicit English language
    final nominatimResult = await _reverseGeocodeNominatimEn(lat, lng);
    if (nominatimResult.isNotEmpty) {
      return nominatimResult;
    }

    return 'Unknown Location';
  }

  /// Normalizes a raw location string (including legacy Supabase values such as
  /// `"محافظة القليوبية, Egypt"`) into clean, deduplicated English.
  static String normalizeLocationName(String rawLocation) {
    final trimmed = rawLocation.trim();
    if (trimmed.isEmpty) return '';

    final rawParts = trimmed
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);

    final List<String> cleanedParts = [];
    final Set<String> seenLower = {};

    for (final part in rawParts) {
      final normalizedPart = _normalizeSegment(part);
      if (normalizedPart.isEmpty) continue;

      final lower = normalizedPart.toLowerCase();
      if (!seenLower.contains(lower)) {
        seenLower.add(lower);
        cleanedParts.add(normalizedPart);
      }
    }

    return cleanedParts.join(', ');
  }

  static String _normalizeSegment(String segment) {
    var clean = segment.trim();
    if (clean.isEmpty) return '';

    // Remove common Arabic administrative prefixes
    const arabicPrefixes = ['محافظة ', 'منطقة ', 'إمارة ', 'ولاية '];
    for (final prefix in arabicPrefixes) {
      if (clean.startsWith(prefix)) {
        clean = clean.substring(prefix.length).trim();
      }
    }

    // Direct Arabic lookup
    final arabicMapped = _arabicToEnglishMap[clean];
    if (arabicMapped != null) {
      return arabicMapped;
    }

    // Strip common English administrative suffixes like " Governorate" or " Province"
    clean = clean
        .replaceAll(RegExp(r'\s+Governorate$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+Province$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+Region$', caseSensitive: false), '')
        .trim();

    final englishMapped = _englishVariantsMap[clean.toLowerCase()];
    if (englishMapped != null) {
      return englishMapped;
    }

    return clean;
  }

  static Future<String> _reverseGeocodeNominatimEn(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat'
        '&lon=$lng'
        '&format=json'
        '&accept-language=en',
      );

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'Joby-App/1.0',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = _firstNonEmpty([
            address['state']?.toString(),
            address['city']?.toString(),
            address['town']?.toString(),
            address['county']?.toString(),
          ]);
          final country = address['country']?.toString() ?? '';
          final raw = city.isNotEmpty && country.isNotEmpty
              ? '$city, $country'
              : (city.isNotEmpty ? city : country);
          final normalized = normalizeLocationName(raw);
          if (normalized.isNotEmpty && !containsArabic(normalized)) {
            return normalized;
          }
        }
      }
    } catch (_) {
      // Ignore network errors and let caller return fallback
    }
    return '';
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }
}
