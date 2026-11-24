import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_map/flutter_map.dart";
import "package:joby/core/widgets/custom_app_bar.dart";
import "package:joby/features/users/user_info/presentation/widgets/custom_search_container.dart";
import "package:joby/features/users/user_info/presentation/widgets/location_footer_widget.dart";
import "package:joby/features/users/user_info/data/models/location_picker_result.dart";
import "package:joby/features/users/user_info/presentation/widgets/search_results_dropdown.dart";
import "package:latlong2/latlong.dart";
import "package:geocoding/geocoding.dart" as geocoding;
import "package:joby/core/themes/app_colors.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:http/http.dart" as http;

class LocationPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String initialLocationName;

  const LocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialLocationName,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late double _latitude;
  late double _longitude;
  late String _locationName;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _locationName = widget.initialLocationName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Reverse geocode to get a human-readable name
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

  /// Search locations using OpenStreetMap Nominatim (free, no API key)
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search"
        "?q=${Uri.encodeComponent(query)}"
        "&format=json"
        "&limit=5"
        "&accept-language=en",
      );

      final response = await http.get(
        url,
        headers: {"User-Agent": "Joby-App/1.0"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data.map((item) {
              return {
                "display_name": item["display_name"] as String,
                "lat": double.parse(item["lat"] as String),
                "lon": double.parse(item["lon"] as String),
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // Silently fail on search errors
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  /// Handle debounced search input
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  /// Move the map to a selected search result
  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = result["lat"] as double;
    final lon = result["lon"] as double;

    setState(() {
      _latitude = lat;
      _longitude = lon;
      _searchResults = [];
      _searchController.clear();
    });
    _searchFocusNode.unfocus();

    _mapController.move(LatLng(lat, lon), 15.0);
    _updateLocationName(lat, lon);
  }

  /// Confirm and return the selected location
  void _confirmLocation() {
    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      resizeToAvoidBottomInset: false,
      //
      appBar: const CustomAppBar(text: "Pick Location"),
      //
      body: Stack(
        children: [
          // Full-screen Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_latitude, _longitude),
              initialZoom: 14.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _latitude = camera.center.latitude;
                    _longitude = camera.center.longitude;
                  });
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateLocationName(_latitude, _longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.joby',
              ),
            ],
          ),
          //
          // Center Pin
          Center(
            child: Padding(
              padding: .only(bottom: 40.h),
              child: Icon(Icons.location_pin, color: Colors.red, size: 50.sp),
            ),
          ),
          //
          // Search Bar
          Positioned(
            top: 10.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              children: [
                // Search Input
                CustomSearchContainer(
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                    _searchFocusNode.unfocus();
                  },
                ),
                //
                verticalSpace(6),
                //
                // Search Results Dropdown
                if (_isSearching) const SearchResultsDropdown(),
                //
                if (_searchResults.isNotEmpty && !_isSearching)
                  //
                  Container(
                    constraints: BoxConstraints(maxHeight: 250.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: .circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: .circular(14.r),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: .zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                            title: Text(
                              result["display_name"] as String,
                              maxLines: 2,
                              overflow: .ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                  ),
                //
              ],
            ),
          ),
          //
          // Bottom Bar: Location Name + Confirm
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LocationFooterWidget(
              isLoadingLocation: _isLoadingLocation,
              locationName: _locationName,
              onPressed: _confirmLocation,
            ),
            //
          ),
          //
        ],
      ),
    );
  }
}
