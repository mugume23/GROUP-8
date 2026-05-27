import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/uganda_location_service.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';

/// Full Uganda administrative location picker.
/// Cascading dropdowns: District → County → Subcounty → Parish → Village
/// Plus GPS "Detect my location" button.
///
/// Usage:
/// ```dart
/// UgandaLocationPicker(
///   onLocationSelected: (loc) {
///     print(loc.fullAddress); // "Kampala, Central, Kampala Central, ..."
///   },
/// )
/// ```
class UgandaLocationPicker extends StatefulWidget {
  final UgandaLocation? initialValue;
  final ValueChanged<UgandaLocation> onLocationSelected;
  final bool showVillage;

  const UgandaLocationPicker({
    super.key,
    this.initialValue,
    required this.onLocationSelected,
    this.showVillage = true,
  });

  @override
  State<UgandaLocationPicker> createState() => _UgandaLocationPickerState();
}

class _UgandaLocationPickerState extends State<UgandaLocationPicker> {
  // Selected values
  String? _district;
  String? _county;
  String? _subcounty;
  String? _parish;
  String? _village;

  // Lists
  List<String> _districts = [];
  List<String> _counties = [];
  List<String> _subcounties = [];
  List<String> _parishes = [];
  List<String> _villages = [];

  // Loading states
  bool _loadingDistricts = true;
  bool _loadingCounties = false;
  bool _loadingSubcounties = false;
  bool _loadingParishes = false;
  bool _loadingVillages = false;
  bool _detectingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
    if (widget.initialValue != null) {
      _district = widget.initialValue!.district;
      _county = widget.initialValue!.county;
      _subcounty = widget.initialValue!.subcounty;
      _parish = widget.initialValue!.parish;
      _village = widget.initialValue!.village;
    }
  }

  Future<void> _loadDistricts() async {
    setState(() => _loadingDistricts = true);
    final list = await UgandaLocationService.getDistricts();
    setState(() {
      _districts = list;
      _loadingDistricts = false;
    });
  }

  Future<void> _onDistrictChanged(String? value) async {
    setState(() {
      _district = value;
      _county = null;
      _subcounty = null;
      _parish = null;
      _village = null;
      _counties = [];
      _subcounties = [];
      _parishes = [];
      _villages = [];
      _loadingCounties = true;
    });
    _emit();
    if (value != null) {
      final list = await UgandaLocationService.getCounties(value);
      setState(() {
        _counties = list;
        _loadingCounties = false;
      });
    } else {
      setState(() => _loadingCounties = false);
    }
  }

  Future<void> _onCountyChanged(String? value) async {
    setState(() {
      _county = value;
      _subcounty = null;
      _parish = null;
      _village = null;
      _subcounties = [];
      _parishes = [];
      _villages = [];
      _loadingSubcounties = true;
    });
    _emit();
    if (value != null) {
      final list = await UgandaLocationService.getSubcounties(value);
      setState(() {
        _subcounties = list;
        _loadingSubcounties = false;
      });
    } else {
      setState(() => _loadingSubcounties = false);
    }
  }

  Future<void> _onSubcountyChanged(String? value) async {
    setState(() {
      _subcounty = value;
      _parish = null;
      _village = null;
      _parishes = [];
      _villages = [];
      _loadingParishes = true;
    });
    _emit();
    if (value != null) {
      final list = await UgandaLocationService.getParishes(value);
      setState(() {
        _parishes = list;
        _loadingParishes = false;
      });
    } else {
      setState(() => _loadingParishes = false);
    }
  }

  Future<void> _onParishChanged(String? value) async {
    setState(() {
      _parish = value;
      _village = null;
      _villages = [];
      _loadingVillages = true;
    });
    _emit();
    if (value != null && widget.showVillage) {
      final list = await UgandaLocationService.getVillages(value);
      setState(() {
        _villages = list;
        _loadingVillages = false;
      });
    } else {
      setState(() => _loadingVillages = false);
    }
  }

  void _onVillageChanged(String? value) {
    setState(() => _village = value);
    _emit();
  }

  void _emit() {
    if (_district != null) {
      widget.onLocationSelected(UgandaLocation(
        district: _district!,
        county: _county,
        subcounty: _subcounty,
        parish: _parish,
        village: _village,
      ));
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _detectingLocation = true);

    final position = await LocationService.getCurrentPosition();

    if (!mounted) return;

    if (position == null) {
      setState(() => _detectingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not detect location. Please enable GPS and grant permission.'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show GPS coordinates and let user know to select district manually
    // (Reverse geocoding to Uganda admin units requires a paid API;
    //  we show the coordinates and pre-select Kampala as nearest major city
    //  if within ~50km, otherwise prompt manual selection)
    setState(() => _detectingLocation = false);

    if (mounted) {
      _showLocationDetectedSheet(position);
    }
  }

  void _showLocationDetectedSheet(Position position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on,
                  color: AppTheme.successColor, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Location Detected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${position.latitude.toStringAsFixed(5)}\n'
              'Lng: ${position.longitude.toStringAsFixed(5)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textGrey, height: 1.6),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select your district below to complete your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Select District'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GPS detect button
        GestureDetector(
          onTap: _detectingLocation ? null : _detectLocation,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_detectingLocation)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                else
                  const Icon(Icons.my_location,
                      color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _detectingLocation
                      ? 'Detecting location...'
                      : 'Use My Current Location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider with "or select manually"
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or select manually',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey.withValues(alpha: 0.8),
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.dividerColor)),
          ],
        ),
        const SizedBox(height: 16),

        // District
        _LocationDropdown(
          label: 'District',
          icon: Icons.location_city_outlined,
          value: _district,
          items: _districts,
          loading: _loadingDistricts,
          onChanged: _onDistrictChanged,
          hint: 'Select District',
        ),
        const SizedBox(height: 12),

        // County
        _LocationDropdown(
          label: 'County',
          icon: Icons.map_outlined,
          value: _county,
          items: _counties,
          loading: _loadingCounties,
          onChanged: _district != null ? _onCountyChanged : null,
          hint: _district == null
              ? 'Select district first'
              : _counties.isEmpty && !_loadingCounties
                  ? 'No counties found'
                  : 'Select County',
        ),
        const SizedBox(height: 12),

        // Subcounty
        _LocationDropdown(
          label: 'Subcounty / Town Council',
          icon: Icons.account_balance_outlined,
          value: _subcounty,
          items: _subcounties,
          loading: _loadingSubcounties,
          onChanged: _county != null ? _onSubcountyChanged : null,
          hint: _county == null
              ? 'Select county first'
              : _subcounties.isEmpty && !_loadingSubcounties
                  ? 'No subcounties found'
                  : 'Select Subcounty',
        ),
        const SizedBox(height: 12),

        // Parish
        _LocationDropdown(
          label: 'Parish / Ward',
          icon: Icons.holiday_village_outlined,
          value: _parish,
          items: _parishes,
          loading: _loadingParishes,
          onChanged: _subcounty != null ? _onParishChanged : null,
          hint: _subcounty == null
              ? 'Select subcounty first'
              : _parishes.isEmpty && !_loadingParishes
                  ? 'No parishes found'
                  : 'Select Parish',
        ),

        // Village (optional)
        if (widget.showVillage) ...[
          const SizedBox(height: 12),
          _LocationDropdown(
            label: 'Village / Cell',
            icon: Icons.home_outlined,
            value: _village,
            items: _villages,
            loading: _loadingVillages,
            onChanged: _parish != null ? _onVillageChanged : null,
            hint: _parish == null
                ? 'Select parish first'
                : _villages.isEmpty && !_loadingVillages
                    ? 'No villages found'
                    : 'Select Village',
          ),
        ],

        // Summary chip
        if (_district != null) ...[
          const SizedBox(height: 16),
          _LocationSummaryChip(
            location: UgandaLocation(
              district: _district!,
              county: _county,
              subcounty: _subcounty,
              parish: _parish,
              village: _village,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Dropdown widget ──────────────────────────────────────────────────────────
class _LocationDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final bool loading;
  final ValueChanged<String?>? onChanged;
  final String hint;

  const _LocationDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.loading,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null && !loading && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textGrey),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isEnabled ? AppTheme.cardWhite : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value != null
                  ? AppTheme.primaryColor.withValues(alpha: 0.4)
                  : AppTheme.dividerColor,
              width: value != null ? 1.5 : 1,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        hint,
                        style: TextStyle(
                          fontSize: 14,
                          color: isEnabled
                              ? AppTheme.textGrey
                              : AppTheme.textGrey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isEnabled
                            ? AppTheme.primaryColor
                            : AppTheme.textGrey.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    borderRadius: BorderRadius.circular(14),
                    onChanged: isEnabled ? onChanged : null,
                    selectedItemBuilder: (context) => items
                        .map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Summary chip ─────────────────────────────────────────────────────────────
class _LocationSummaryChip extends StatelessWidget {
  final UgandaLocation location;

  const _LocationSummaryChip({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on,
              color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              location.fullAddress,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────
class UgandaLocation {
  final String district;
  final String? county;
  final String? subcounty;
  final String? parish;
  final String? village;

  const UgandaLocation({
    required this.district,
    this.county,
    this.subcounty,
    this.parish,
    this.village,
  });

  /// Returns the most specific location available.
  String get shortAddress => village ?? parish ?? subcounty ?? county ?? district;

  /// Returns full hierarchical address.
  String get fullAddress {
    final parts = [district, county, subcounty, parish, village]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() => {
        'district': district,
        'county': county ?? '',
        'subcounty': subcounty ?? '',
        'parish': parish ?? '',
        'village': village ?? '',
        'fullAddress': fullAddress,
      };

  factory UgandaLocation.fromMap(Map<String, dynamic> map) => UgandaLocation(
        district: map['district'] ?? '',
        county: map['county'],
        subcounty: map['subcounty'],
        parish: map['parish'],
        village: map['village'],
      );

  @override
  String toString() => fullAddress;
}
