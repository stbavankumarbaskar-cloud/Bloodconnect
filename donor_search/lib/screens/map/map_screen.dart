import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/donor_map_popup.dart';
import '../../components/custom_button.dart';
import '../../models/donor_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

enum MapTypeOption {
  googleRoadmap(
    'Google Maps (Roadmap)',
    'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
    ['0', '1', '2', '3'],
    Icons.map_outlined,
  ),
  googleHybrid(
    'Google Satellite (Hybrid)',
    'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
    ['0', '1', '2', '3'],
    Icons.satellite_alt_outlined,
  ),
  googleTerrain(
    'Google Terrain',
    'https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
    ['0', '1', '2', '3'],
    Icons.terrain_outlined,
  ),
  osm(
    'OpenStreetMap',
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ['a', 'b', 'c'],
    Icons.public_outlined,
  );

  final String label;
  final String urlTemplate;
  final List<String> subdomains;
  final IconData icon;

  const MapTypeOption(this.label, this.urlTemplate, this.subdomains, this.icon);
}

class MapSearchItem {
  final String title;
  final String? subtitle;
  final LatLng location;
  final bool isDonor;
  final String? bloodGroup;
  final DonorModel? donor;

  const MapSearchItem({
    required this.title,
    this.subtitle,
    required this.location,
    this.isDonor = false,
    this.bloodGroup,
    this.donor,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng _userLocation = const LatLng(9.9252, 78.1198); // Madurai Center
  String _selectedLocationName = 'Madurai Center';
  double _radiusKm = 5.0; // Interactive Search Radius Zone (in KM)
  String _selectedBloodFilter = 'ALL';
  List<DonorModel> _donors = [];
  List<MapSearchItem> _suggestions = [];
  bool _isLoading = true;
  bool _isPanelExpanded = true;
  MapTypeOption _selectedMapType = MapTypeOption.googleRoadmap;

  // Pre-configured Tamil Nadu landmarks, cities, and areas for quick search
  static final List<MapSearchItem> _tamilNaduLocations = [
    // Madurai Areas & Landmarks
    const MapSearchItem(title: 'Madurai Center', subtitle: 'Madurai, Tamil Nadu', location: LatLng(9.9252, 78.1198)),
    const MapSearchItem(title: 'Keelapanangadi', subtitle: 'Madurai, Tamil Nadu (625017)', location: LatLng(9.9252, 78.1198)),
    const MapSearchItem(title: 'Anna Nagar', subtitle: 'Madurai, Tamil Nadu (625020)', location: LatLng(9.9275, 78.1420)),
    const MapSearchItem(title: 'KK Nagar', subtitle: 'Madurai, Tamil Nadu (625020)', location: LatLng(9.9340, 78.1480)),
    const MapSearchItem(title: 'Simmakkal', subtitle: 'Madurai, Tamil Nadu (625001)', location: LatLng(9.9238, 78.1215)),
    const MapSearchItem(title: 'Goripalayam', subtitle: 'Madurai, Tamil Nadu (625002)', location: LatLng(9.9325, 78.1310)),
    const MapSearchItem(title: 'Tallakulam', subtitle: 'Madurai, Tamil Nadu (625002)', location: LatLng(9.9385, 78.1360)),
    const MapSearchItem(title: 'Othakadai', subtitle: 'Madurai, Tamil Nadu (625107)', location: LatLng(9.9650, 78.1880)),
    const MapSearchItem(title: 'Thirunagar', subtitle: 'Madurai, Tamil Nadu (625006)', location: LatLng(9.8780, 78.0720)),
    const MapSearchItem(title: 'South Gate', subtitle: 'Madurai, Tamil Nadu (625001)', location: LatLng(9.9160, 78.1180)),
    const MapSearchItem(title: 'Villapuram', subtitle: 'Madurai, Tamil Nadu (625012)', location: LatLng(9.8970, 78.1250)),
    const MapSearchItem(title: 'Ponmeni', subtitle: 'Madurai, Tamil Nadu (625016)', location: LatLng(9.9142, 78.0985)),
    const MapSearchItem(title: 'Palanganatham', subtitle: 'Madurai, Tamil Nadu (625003)', location: LatLng(9.9050, 78.1010)),
    const MapSearchItem(title: 'Kalavasal', subtitle: 'Madurai, Tamil Nadu (625016)', location: LatLng(9.9280, 78.0950)),
    const MapSearchItem(title: 'Kochadai', subtitle: 'Madurai, Tamil Nadu (625016)', location: LatLng(9.9360, 78.0820)),
    const MapSearchItem(title: 'Pasumalai', subtitle: 'Madurai, Tamil Nadu (625004)', location: LatLng(9.8910, 78.0860)),
    const MapSearchItem(title: 'Tirupparankunram', subtitle: 'Madurai, Tamil Nadu (625005)', location: LatLng(9.8820, 78.0710)),
    const MapSearchItem(title: 'Mattuthavani', subtitle: 'Madurai, Tamil Nadu (625007)', location: LatLng(9.9450, 78.1560)),
    const MapSearchItem(title: 'K.Pudur', subtitle: 'Madurai, Tamil Nadu (625007)', location: LatLng(9.9480, 78.1460)),
    const MapSearchItem(title: 'Bibikulam', subtitle: 'Madurai, Tamil Nadu (625002)', location: LatLng(9.9410, 78.1320)),
    const MapSearchItem(title: 'Iyer Bunglow', subtitle: 'Madurai, Tamil Nadu (625014)', location: LatLng(9.9600, 78.1410)),
    const MapSearchItem(title: 'Vandiyur', subtitle: 'Madurai, Tamil Nadu (625020)', location: LatLng(9.9210, 78.1630)),
    const MapSearchItem(title: 'Sellur', subtitle: 'Madurai, Tamil Nadu (625002)', location: LatLng(9.9390, 78.1230)),
    const MapSearchItem(title: 'Alanganallur', subtitle: 'Madurai, Tamil Nadu (625501)', location: LatLng(10.0450, 78.1020)),
    const MapSearchItem(title: 'Sholavandan', subtitle: 'Madurai, Tamil Nadu (625214)', location: LatLng(10.0210, 78.0120)),
    const MapSearchItem(title: 'Samayanallur', subtitle: 'Madurai, Tamil Nadu (625402)', location: LatLng(9.9880, 78.0450)),
    const MapSearchItem(title: 'Melur', subtitle: 'Madurai, Tamil Nadu (625106)', location: LatLng(10.0280, 78.3340)),
    const MapSearchItem(title: 'Thirumangalam', subtitle: 'Madurai, Tamil Nadu (625706)', location: LatLng(9.8220, 77.9860)),
    const MapSearchItem(title: 'Nagamalai Pudukkottai', subtitle: 'Madurai, Tamil Nadu (625019)', location: LatLng(9.9210, 78.0420)),
    const MapSearchItem(title: 'Teppakulam', subtitle: 'Madurai, Tamil Nadu (625009)', location: LatLng(9.9130, 78.1490)),
    const MapSearchItem(title: 'Jaihindpuram', subtitle: 'Madurai, Tamil Nadu (625011)', location: LatLng(9.9070, 78.1150)),
    const MapSearchItem(title: 'Avaniyapuram', subtitle: 'Madurai, Tamil Nadu (625012)', location: LatLng(9.8850, 78.1210)),

    // Chennai & Areas
    const MapSearchItem(title: 'Chennai', subtitle: 'Chennai Capital City, Tamil Nadu', location: LatLng(13.0827, 80.2707)),
    const MapSearchItem(title: 'T. Nagar', subtitle: 'Chennai, Tamil Nadu (600017)', location: LatLng(13.0418, 80.2341)),
    const MapSearchItem(title: 'Anna Nagar Chennai', subtitle: 'Chennai, Tamil Nadu (600040)', location: LatLng(13.0850, 80.2101)),
    const MapSearchItem(title: 'Velachery', subtitle: 'Chennai, Tamil Nadu (600042)', location: LatLng(12.9815, 80.2180)),
    const MapSearchItem(title: 'Guindy', subtitle: 'Chennai, Tamil Nadu (600032)', location: LatLng(13.0067, 80.2025)),
    const MapSearchItem(title: 'Adyar', subtitle: 'Chennai, Tamil Nadu (600020)', location: LatLng(13.0012, 80.2565)),
    const MapSearchItem(title: 'Mylapore', subtitle: 'Chennai, Tamil Nadu (600004)', location: LatLng(13.0368, 80.2676)),
    const MapSearchItem(title: 'Tambaram', subtitle: 'Chennai, Tamil Nadu (600045)', location: LatLng(12.9249, 80.1000)),
    const MapSearchItem(title: 'Porur', subtitle: 'Chennai, Tamil Nadu (600116)', location: LatLng(13.0382, 80.1565)),
    const MapSearchItem(title: 'Koyambedu', subtitle: 'Chennai, Tamil Nadu (600107)', location: LatLng(13.0694, 80.1948)),

    // Coimbatore & Areas
    const MapSearchItem(title: 'Coimbatore', subtitle: 'Coimbatore, Tamil Nadu', location: LatLng(11.0168, 76.9558)),
    const MapSearchItem(title: 'Gandhipuram', subtitle: 'Coimbatore, Tamil Nadu (641012)', location: LatLng(11.0168, 76.9558)),
    const MapSearchItem(title: 'RS Puram', subtitle: 'Coimbatore, Tamil Nadu (641002)', location: LatLng(11.0085, 76.9482)),
    const MapSearchItem(title: 'Peelamedu', subtitle: 'Coimbatore, Tamil Nadu (641004)', location: LatLng(11.0285, 77.0015)),
    const MapSearchItem(title: 'Singanallur', subtitle: 'Coimbatore, Tamil Nadu (641005)', location: LatLng(11.0012, 77.0256)),
    const MapSearchItem(title: 'Saravanampatti', subtitle: 'Coimbatore, Tamil Nadu (641035)', location: LatLng(11.0825, 76.9942)),

    // Tiruchirappalli (Trichy)
    const MapSearchItem(title: 'Tiruchirappalli (Trichy)', subtitle: 'Trichy, Tamil Nadu', location: LatLng(10.7905, 78.7047)),
    const MapSearchItem(title: 'Thillai Nagar', subtitle: 'Tiruchirappalli, Tamil Nadu (620018)', location: LatLng(10.8285, 78.6854)),
    const MapSearchItem(title: 'Srirangam', subtitle: 'Tiruchirappalli, Tamil Nadu (620006)', location: LatLng(10.8625, 78.6942)),
    const MapSearchItem(title: 'Cantonment', subtitle: 'Tiruchirappalli, Tamil Nadu (620001)', location: LatLng(10.8095, 78.6821)),
    const MapSearchItem(title: 'KK Nagar Trichy', subtitle: 'Tiruchirappalli, Tamil Nadu (620021)', location: LatLng(10.7850, 78.7025)),

    // Salem
    const MapSearchItem(title: 'Salem', subtitle: 'Salem, Tamil Nadu', location: LatLng(11.6643, 78.1460)),
    const MapSearchItem(title: 'Hasthampatti', subtitle: 'Salem, Tamil Nadu (636007)', location: LatLng(11.6750, 78.1620)),
    const MapSearchItem(title: 'Fairlands', subtitle: 'Salem, Tamil Nadu (636016)', location: LatLng(11.6685, 78.1450)),
    const MapSearchItem(title: 'Suramangalam', subtitle: 'Salem, Tamil Nadu (636005)', location: LatLng(11.6825, 78.1215)),

    // Tirunelveli
    const MapSearchItem(title: 'Tirunelveli', subtitle: 'Tirunelveli, Tamil Nadu', location: LatLng(8.7139, 77.7567)),
    const MapSearchItem(title: 'Palayamkottai', subtitle: 'Tirunelveli, Tamil Nadu (627002)', location: LatLng(8.7185, 77.7425)),
    const MapSearchItem(title: 'Vannarpettai', subtitle: 'Tirunelveli, Tamil Nadu (627003)', location: LatLng(8.7295, 77.7285)),

    // Thanjavur
    const MapSearchItem(title: 'Thanjavur', subtitle: 'Thanjavur, Tamil Nadu', location: LatLng(10.7870, 79.1378)),
    const MapSearchItem(title: 'Medical College Road', subtitle: 'Thanjavur, Tamil Nadu (613004)', location: LatLng(10.7750, 79.1285)),

    // Dindigul
    const MapSearchItem(title: 'Dindigul', subtitle: 'Dindigul, Tamil Nadu', location: LatLng(10.3673, 77.9803)),
    const MapSearchItem(title: 'Begambur', subtitle: 'Dindigul, Tamil Nadu (624002)', location: LatLng(10.3625, 77.9740)),

    // Erode
    const MapSearchItem(title: 'Erode', subtitle: 'Erode, Tamil Nadu', location: LatLng(11.3410, 77.7172)),
    const MapSearchItem(title: 'Perundurai Road', subtitle: 'Erode, Tamil Nadu (638011)', location: LatLng(11.3415, 77.7125)),

    // Vellore
    const MapSearchItem(title: 'Vellore', subtitle: 'Vellore, Tamil Nadu', location: LatLng(12.9165, 79.1325)),
    const MapSearchItem(title: 'Katpadi', subtitle: 'Vellore, Tamil Nadu (632007)', location: LatLng(12.9685, 79.1385)),

    // Other Tamil Nadu Districts
    const MapSearchItem(title: 'Tiruppur', subtitle: 'Tiruppur, Tamil Nadu', location: LatLng(11.1085, 77.3411)),
    const MapSearchItem(title: 'Kanyakumari', subtitle: 'Kanyakumari, Tamil Nadu', location: LatLng(8.1833, 77.4119)),
    const MapSearchItem(title: 'Thoothukudi', subtitle: 'Thoothukudi, Tamil Nadu', location: LatLng(8.7642, 78.1348)),
    const MapSearchItem(title: 'Karur', subtitle: 'Karur, Tamil Nadu', location: LatLng(10.9601, 78.0766)),
    const MapSearchItem(title: 'Virudhunagar', subtitle: 'Virudhunagar, Tamil Nadu', location: LatLng(9.5680, 77.9624)),
    const MapSearchItem(title: 'Theni', subtitle: 'Theni, Tamil Nadu', location: LatLng(10.0104, 77.4768)),
    const MapSearchItem(title: 'Sivagangai', subtitle: 'Sivagangai, Tamil Nadu', location: LatLng(9.8433, 78.4809)),
  ];

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndFetch() async {
    final user = await StorageService.getUser();
    if (user != null && user.latitude != null && user.longitude != null) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(user.latitude!, user.longitude!);
          _selectedLocationName = user.area.isNotEmpty ? '${user.area}, ${user.district}' : user.district;
        });
      }
    }
    _fetchDonorsForMap();
  }

  double _getZoomForRadius(double radiusKm) {
    if (radiusKm <= 3.0) return 14.0;
    if (radiusKm <= 6.0) return 13.0;
    if (radiusKm <= 11.0) return 12.0;
    if (radiusKm <= 16.0) return 11.3;
    if (radiusKm <= 26.0) return 10.4;
    return 9.5;
  }

  Future<void> _fetchDonorsForMap() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getNearbyDonors(
      latitude: _userLocation.latitude,
      longitude: _userLocation.longitude,
      radius: _radiusKm,
      bloodGroup: _selectedBloodFilter != 'ALL' ? _selectedBloodFilter : null,
    );

    if (!mounted) return;
    setState(() {
      _donors = res.data ?? [];
      _isLoading = false;
    });
  }

  void _onRadiusChanged(double newRadius) {
    setState(() {
      _radiusKm = newRadius;
    });
    _mapController.move(_userLocation, _getZoomForRadius(newRadius));
    _fetchDonorsForMap();
  }

  void _handleSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final matches = <MapSearchItem>[];

    // 1. Search in pre-configured Tamil Nadu landmarks/locations
    for (final loc in _tamilNaduLocations) {
      if (loc.title.toLowerCase().contains(q) || (loc.subtitle?.toLowerCase().contains(q) ?? false)) {
        matches.add(loc);
        if (matches.length >= 5) break;
      }
    }

    // 2. Search in current donors on the map (names, areas)
    for (final donor in _donors) {
      if (donor.latitude != null && donor.longitude != null) {
        final nameMatch = donor.fullName.toLowerCase().contains(q);
        final areaMatch = donor.area.toLowerCase().contains(q);
        if (nameMatch || areaMatch) {
          matches.add(MapSearchItem(
            title: donor.fullName,
            subtitle: '${donor.area}, ${donor.district}',
            location: LatLng(donor.latitude!, donor.longitude!),
            isDonor: true,
            bloodGroup: donor.bloodGroup,
            donor: donor,
          ));
          if (matches.length >= 8) break;
        }
      }
    }

    setState(() => _suggestions = matches);
  }

  void _selectSuggestion(MapSearchItem item) {
    _searchController.text = item.title;
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
      _selectedLocationName = item.title;
      _userLocation = item.location;
    });

    _mapController.move(item.location, _getZoomForRadius(_radiusKm));

    if (item.isDonor && item.donor != null) {
      _showDonorPopup(item.donor!);
    } else {
      _fetchDonorsForMap();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Map centered on ${item.title} • ${_radiusKm.toInt()} KM zone',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleSearchSubmitted(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    _searchFocusNode.unfocus();

    MapSearchItem? bestMatch;
    for (final loc in _tamilNaduLocations) {
      if (loc.title.toLowerCase().contains(q) || (loc.subtitle?.toLowerCase().contains(q) ?? false)) {
        bestMatch = loc;
        break;
      }
    }

    if (bestMatch == null) {
      for (final donor in _donors) {
        if (donor.latitude != null && donor.longitude != null) {
          if (donor.fullName.toLowerCase().contains(q) || donor.area.toLowerCase().contains(q)) {
            bestMatch = MapSearchItem(
              title: donor.fullName,
              subtitle: '${donor.area}, ${donor.district}',
              location: LatLng(donor.latitude!, donor.longitude!),
              isDonor: true,
              bloodGroup: donor.bloodGroup,
              donor: donor,
            );
            break;
          }
        }
      }
    }

    if (bestMatch != null) {
      _selectSuggestion(bestMatch);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No location or donor found matching "$query" in Tamil Nadu'),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  Future<void> _handleUseLiveLocation() async {
    _clearSearch();
    setState(() {
      _selectedLocationName = 'Live GPS Center';
      _isLoading = true;
    });
    final user = await StorageService.getUser();
    if (user != null && user.latitude != null && user.longitude != null) {
      setState(() {
        _userLocation = LatLng(user.latitude!, user.longitude!);
      });
    } else {
      setState(() {
        _userLocation = const LatLng(9.9252, 78.1198);
      });
    }
    _mapController.move(_userLocation, _getZoomForRadius(_radiusKm));
    await _fetchDonorsForMap();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live GPS calibrated • ${_donors.length} donors found within ${_radiusKm.toInt()} KM zone',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDonorPopup(DonorModel donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DonorMapPopup(donor: donor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligibleCount = _donors.where((d) => d.markerColor == 'green').length;
    final recentCount = _donors.where((d) => d.markerColor == 'red').length;

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps / Interactive Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: _getZoomForRadius(_radiusKm),
              minZoom: 6.0,
              maxZoom: 20.0,
              onTap: (_, __) {
                if (_searchFocusNode.hasFocus) {
                  _searchFocusNode.unfocus();
                }
                if (_suggestions.isNotEmpty) {
                  setState(() => _suggestions = []);
                }
              },
            ),
            children: [
              TileLayer(
                key: ValueKey(_selectedMapType),
                urlTemplate: _selectedMapType.urlTemplate,
                subdomains: _selectedMapType.subdomains,
                userAgentPackageName: 'com.bloodconnect.donor_search',
                maxNativeZoom: 20,
              ),

              // Interactive Search Radius Circle Layer (Controlled by Slider KMs)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderColor: AppColors.primary.withValues(alpha: 0.6),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                    radius: _radiusKm * 1000, // Dynamic radius in meters!
                  ),
                ],
              ),

              // Markers Layer: User Location + Donor Pins
              MarkerLayer(
                markers: [
                  // Center Location Pin
                  Marker(
                    point: _userLocation,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // Donor Pins (Red / Green based on last donation date)
                  ..._donors.map((donor) {
                    if (donor.latitude == null || donor.longitude == null) {
                      return null;
                    }
                    final isGreen = donor.markerColor == 'green';
                    final pinColor = isGreen
                        ? AppColors.availableGreen
                        : AppColors.recentlyDonatedRed;

                    return Marker(
                      point: LatLng(donor.latitude!, donor.longitude!),
                      width: 50,
                      height: 58,
                      child: GestureDetector(
                        onTap: () => _showDonorPopup(donor),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: pinColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: pinColor.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                donor.bloodGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Icon(Icons.location_on, color: pinColor, size: 32),
                          ],
                        ),
                      ),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          // Top Floating Bar: Search Bar + Location Chip + Blood Filters
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Google Maps-style Search Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 14, right: 8),
                            child: Icon(Icons.search, color: AppColors.primary, size: 22),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _handleSearchChanged,
                              onSubmitted: _handleSearchSubmitted,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Search area, city or donor in Tamil Nadu...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              onPressed: _clearSearch,
                            ),
                          IconButton(
                            icon: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                            tooltip: 'Live Location',
                            onPressed: _handleUseLiveLocation,
                          ),
                        ],
                      ),

                      // Auto-suggestions dropdown
                      if (_suggestions.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 230),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, index) {
                              final item = _suggestions[index];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: item.isDonor ? AppColors.primarySoft : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.isDonor ? Icons.person : Icons.place,
                                    color: item.isDonor ? AppColors.primary : Colors.blue.shade700,
                                    size: 16,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                subtitle: item.subtitle != null
                                    ? Text(
                                        item.subtitle!,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: item.bloodGroup != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.bloodGroup!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.north_west, size: 14, color: Colors.grey),
                                onTap: () => _selectSuggestion(item),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Active Location & Zone Pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place, color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _selectedLocationName,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_radiusKm.toInt()} KM Zone',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${_donors.length} Donors',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. Blood Filter Chips Bar
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: ['ALL', ...AppConstants.bloodGroups].length,
                    itemBuilder: (context, index) {
                      final bg = ['ALL', ...AppConstants.bloodGroups][index];
                      final isSel = _selectedBloodFilter == bg;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: FilterChip(
                          label: Text(
                            bg,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSel
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (_) {
                            setState(() => _selectedBloodFilter = bg);
                            _fetchDonorsForMap();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Map Type Switcher FAB (Google Maps Layers)
          Positioned(
            right: 16,
            bottom: _isPanelExpanded ? 260 : 125,
            child: FloatingActionButton.small(
              heroTag: 'map_layer_switcher_fab',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              tooltip: 'Change Map Layer',
              onPressed: _showMapTypeSelector,
              child: const Icon(Icons.layers_rounded),
            ),
          ),

          // Recenter FAB
          Positioned(
            right: 16,
            bottom: _isPanelExpanded ? 208 : 72,
            child: FloatingActionButton.small(
              heroTag: 'recenter_map_fab',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              tooltip: 'Center Location',
              onPressed: _handleUseLiveLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Bottom Live Location & Zone Control Card
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Live GPS Coordinates, GPS Active, and Collapse toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gps_fixed, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Live GPS Coordinates',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.availableGreenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'GPS Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.availableGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _isPanelExpanded = !_isPanelExpanded),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Center: ${_userLocation.latitude.toStringAsFixed(4)}° N, ${_userLocation.longitude.toStringAsFixed(4)}° E ($_selectedLocationName)',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (_isPanelExpanded) ...[
                    const SizedBox(height: 12),
                    // Search Radius Zone label + KM value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Search Radius Zone',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_radiusKm.toInt()} KM',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    // Zone Slider
                    Slider(
                      value: _radiusKm,
                      min: 2.0,
                      max: 25.0,
                      divisions: 23,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primaryLight,
                      onChanged: (val) {
                        setState(() => _radiusKm = val);
                      },
                      onChangeEnd: (val) {
                        _onRadiusChanged(val);
                      },
                    ),
                    const SizedBox(height: 6),

                    // "Use My Live Location" Button
                    CustomButton(
                      text: 'Use My Live Location',
                      icon: Icons.my_location,
                      isLoading: _isLoading,
                      onPressed: _handleUseLiveLocation,
                      height: 44,
                    ),
                    const SizedBox(height: 10),

                    // Legend Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLegendItem(
                          AppColors.availableGreen,
                          '$eligibleCount Available',
                        ),
                        _buildLegendItem(
                          AppColors.recentlyDonatedRed,
                          'Recently Donated (<6m)',
                        ),
                        _buildLegendItem(Colors.blue.shade700, 'Center Pin'),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_donors.length} donors in ${_radiusKm.toInt()} KM zone',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isPanelExpanded = true),
                          child: Text(
                            'Adjust Zone (${_radiusKm.toInt()} KM) ⌃',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMapTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Map Style',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...MapTypeOption.values.map((type) {
                  final isSelected = _selectedMapType == type;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySoft
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type.icon,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      type.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? AppColors.primarySoft.withValues(alpha: 0.5)
                        : null,
                    onTap: () {
                      setState(() => _selectedMapType = type);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
