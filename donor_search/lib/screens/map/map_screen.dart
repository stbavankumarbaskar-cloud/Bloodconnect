import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/donor_map_popup.dart';
import '../../models/donor_model.dart';
import '../../services/api_service.dart';

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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _userLocation = const LatLng(9.9252, 78.1198); // Madurai Center
  final double _radiusKm = 5.0; // 5 KM Search Zone
  String _selectedBloodFilter = 'ALL';
  List<DonorModel> _donors = [];
  bool _isLoading = true;
  MapTypeOption _selectedMapType = MapTypeOption.googleRoadmap;

  @override
  void initState() {
    super.initState();
    _fetchDonorsForMap();
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
              initialZoom: 13.2,
              minZoom: 6.0,
              maxZoom: 20.0,
            ),
            children: [
              TileLayer(
                key: ValueKey(_selectedMapType),
                urlTemplate: _selectedMapType.urlTemplate,
                subdomains: _selectedMapType.subdomains,
                userAgentPackageName: 'com.bloodconnect.donor_search',
                maxNativeZoom: 20,
              ),

              // 5 KM Search Radius Circle Layer
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderColor: AppColors.primary.withValues(alpha: 0.6),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                    radius: _radiusKm * 1000, // 5000 meters
                  ),
                ],
              ),

              // Markers Layer: User Location + Donor Pins
              MarkerLayer(
                markers: [
                  // User Location Pin
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
                        child: Icon(Icons.person, color: Colors.white, size: 22),
                      ),
                    ),
                  ),

                  // Donor Pins (Red / Green based on last donation date)
                  ..._donors.map((donor) {
                    if (donor.latitude == null || donor.longitude == null) {
                      return null;
                    }
                    final isGreen = donor.markerColor == 'green';
                    final pinColor = isGreen ? AppColors.availableGreen : AppColors.recentlyDonatedRed;

                    return Marker(
                      point: LatLng(donor.latitude!, donor.longitude!),
                      width: 50,
                      height: 58,
                      child: GestureDetector(
                        onTap: () => _showDonorPopup(donor),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            Icon(
                              Icons.location_on,
                              color: pinColor,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          // Top Floating Bar with Blood Filter Chips
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Donor Map (${_donors.length} nearby)',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            Text(
                              'Google Maps • 5 KM Search Zone • Madurai',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                    ],
                  ),
                ),

                // Blood Filter Chips Bar
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
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

          // Bottom Map Legend Card
          Positioned(
            left: 14,
            right: 14,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Map Legend & Status',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Text(
                        '🟢 $eligibleCount Available  •  🔴 $recentCount Donated',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLegendItem(AppColors.recentlyDonatedRed, 'Recently Donated (<6m)'),
                      _buildLegendItem(AppColors.availableGreen, '6+ Mos. Available'),
                      _buildLegendItem(Colors.blue, 'My Location'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map Type Switcher FAB (Google Maps Layers)
          Positioned(
            right: 16,
            bottom: 170,
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
            bottom: 115,
            child: FloatingActionButton.small(
              heroTag: 'recenter_map_fab',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              tooltip: 'My Location',
              onPressed: () {
                _mapController.move(_userLocation, 13.5);
              },
              child: const Icon(Icons.my_location),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Map Style',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primarySoft : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type.icon,
                        color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      type.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? AppColors.primarySoft.withValues(alpha: 0.5) : null,
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
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
