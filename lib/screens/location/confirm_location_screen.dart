import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/map/map_provider_interface.dart';
import '../../core/map/mock_solar_map_canvas.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/property_location.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

/// Confirm Location Screen (Stitch: 29594313ffc24d539db94b05f63c3ae2)
/// Step 1 of 5 in the ApnaSolar solar rooftop planning flow.
class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  late final SolarMapController _mapController;
  late final TextEditingController _searchController;
  bool _isConfirming = false;
  bool _showSuggestions = false;

  final List<PropertyLocation> _mockLocations = [
    const PropertyLocation(
      formattedAddress:
          '42, 14th Main Rd, HAL 2nd Stage, Indiranagar, Bengaluru, KA 560038',
      locality: 'Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560038',
      latitude: 12.9719,
      longitude: 77.6412,
      peakSunHoursPerDay: 5.2,
    ),
    const PropertyLocation(
      formattedAddress:
          '88, 100 Feet Rd, HAL 2nd Stage, Indiranagar, Bengaluru, KA 560038',
      locality: 'Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560038',
      latitude: 12.9725,
      longitude: 77.6435,
      peakSunHoursPerDay: 5.3,
    ),
    const PropertyLocation(
      formattedAddress:
          '12, 1st Cross, Koramangala 4th Block, Bengaluru, KA 560034',
      locality: 'Koramangala',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560034',
      latitude: 12.9352,
      longitude: 77.6245,
      peakSunHoursPerDay: 5.1,
    ),
    const PropertyLocation(
      formattedAddress:
          '104, Outer Ring Rd, HSR Layout Sector 2, Bengaluru, KA 560102',
      locality: 'HSR Layout',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560102',
      latitude: 12.9116,
      longitude: 77.6389,
      peakSunHoursPerDay: 5.4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = SolarMapController();
    _searchController = TextEditingController(
      text: _mapController.property.formattedAddress,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmLocation() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isConfirming = false);
    Navigator.pushNamed(context, AppRoutes.satelliteRoofDrawing);
  }

  void _selectLocation(PropertyLocation loc) {
    setState(() {
      _mapController.setProperty(loc);
      _searchController.text = loc.formattedAddress;
      _showSuggestions = false;
      _mapController.recenterPin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar matching Stitch Step 1 of 5
            _buildFlowHeader(context),

            // Floating Search & GPS Control Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.spaceXs,
              ),
              child: _buildSearchBar(),
            ),

            // Autocomplete suggestions dropdown if active
            if (_showSuggestions) _buildSuggestionsList(),

            // Interactive Map Viewport with Floating Controls & Solar Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                  vertical: AppSpacing.spaceXs,
                ),
                child: _buildMapContainer(),
              ),
            ),

            // Bottom Confirmation Bento Card
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.spaceXs,
                AppSpacing.margin,
                AppSpacing.spaceSm,
              ),
              child: _buildBottomConfirmationCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Frosted Back Button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: AppRadii.full,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),

          // Step Badge Pill with Pulsing Dot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
              borderRadius: AppRadii.full,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulsingDot(size: 7, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Step 1 of 5 · Location',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Solar Satellite Layer Toggle
          ListenableBuilder(
            listenable: _mapController,
            builder: (context, _) {
              final isSatellite = _mapController.mode != SolarMapMode.vector;
              return InkWell(
                onTap: _mapController.toggleSatellite,
                borderRadius: AppRadii.full,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSatellite
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLowest.withValues(
                            alpha: 0.9,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.layers,
                    size: 20,
                    color: isSatellite
                        ? AppColors.secondaryFixed
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C164A38),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onTap: () => setState(() => _showSuggestions = true),
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search your home address or colony...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outline,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _mapController.triggerGpsLocate();
              _selectLocation(_mockLocations.first);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppColors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'GPS',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: 4,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _mockLocations.map((loc) {
          return InkWell(
            onTap: () => _selectLocation(loc),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.formattedAddress,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Underlying Custom Painted Map Canvas
          MockSolarMapCanvas(controller: _mapController),

          // Floating Top-Left Irradiance Sunlight Chip
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
                borderRadius: AppRadii.full,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    size: 16,
                    color: AppColors.tertiaryFixedDim,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_mapController.property.peakSunHoursPerDay} Peak Sun-Hours / day',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Top-Right Zoom Controls
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              children: [
                InkWell(
                  onTap: _mapController.zoomIn,
                  borderRadius: AppRadii.full,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.95,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _mapController.zoomOut,
                  borderRadius: AppRadii.full,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.95,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomConfirmationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14164A38),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle notch
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: AppRadii.full,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Question & Address Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Is this your home?',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: AppRadii.full,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.onSecondaryContainer,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'High Solar Yield',
                                style: AppTypography.labelMd.copyWith(
                                  fontSize: 10,
                                  color: AppColors.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mapController.property.formattedAddress,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Mini Rooftop Area Estimate Tile
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.cardSm,
                ),
                child: Column(
                  children: [
                    Text(
                      'Est. Area',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '1,420',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'sq. ft.',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 9,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Primary CTA Button
          AppButton(
            label: _isConfirming
                ? 'Locking Coordinates...'
                : 'Confirm Location',
            isLoading: _isConfirming,
            showTrailingArrowBadge: true,
            onPressed: _handleConfirmLocation,
          ),
          const SizedBox(height: 4),

          // Secondary Nudge
          InkWell(
            onTap: _mapController.recenterPin,
            borderRadius: AppRadii.full,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pan_tool,
                    size: 15,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Move map to adjust pin',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
