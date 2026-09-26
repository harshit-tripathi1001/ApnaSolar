import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_badge.dart';

/// Property Details Screen (Step 2 of 5 in ApnaSolar Prototype)
/// Connects Location with Rooftop boundary calibration, allowing homeowners
/// to configure property type, roof structure, and monthly power consumption.
class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _session = SolarSessionState();

  late String _selectedPropertyType;
  late String _selectedRoofType;
  late double _monthlyBill;
  late double _sanctionedLoadKw;

  final List<Map<String, dynamic>> _propertyTypes = [
    {
      'title': 'Independent House / Villa',
      'subtitle': 'Sole terrace ownership',
      'icon': Icons.home_rounded,
    },
    {
      'title': 'Row House / Duplex',
      'subtitle': 'Shared side walls',
      'icon': Icons.cottage_rounded,
    },
    {
      'title': 'G+2 Floors Independent',
      'subtitle': 'Multi-family residential',
      'icon': Icons.apartment_rounded,
    },
    {
      'title': 'Penthouse / Top Floor',
      'subtitle': 'Private roof rights',
      'icon': Icons.domain_rounded,
    },
  ];

  final List<Map<String, dynamic>> _roofTypes = [
    {
      'title': 'Flat Concrete (RCC)',
      'subtitle': 'Ideal for elevated tilt racks',
      'tag': 'Best Yield',
      'icon': Icons.roofing_rounded,
    },
    {
      'title': 'Pitched / Sloped Tile',
      'subtitle': 'Flush rail mounting',
      'tag': 'Standard',
      'icon': Icons.home_work_outlined,
    },
    {
      'title': 'Industrial Metal Sheet',
      'subtitle': 'Direct clamp fixtures',
      'tag': 'High Durability',
      'icon': Icons.hardware_rounded,
    },
  ];

  final List<double> _billPresets = [2500.0, 3850.0, 5200.0, 7500.0];

  @override
  void initState() {
    super.initState();
    _selectedPropertyType = _session.propertyType;
    _selectedRoofType = _session.roofType;
    _monthlyBill = _session.monthlyBill;
    _sanctionedLoadKw = _session.sanctionedLoadKw;
  }

  void _saveAndProceed() {
    _session.updatePropertyDetails(
      propertyType: _selectedPropertyType,
      roofType: _selectedRoofType,
      monthlyBill: _monthlyBill,
      sanctionedLoadKw: _sanctionedLoadKw,
    );
    Navigator.pushNamed(context, AppRoutes.satelliteRoofDrawing);
  }

  @override
  Widget build(BuildContext context) {
    final property = _session.selectedProperty;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Step Header
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Confirmed Address Banner (Requirement 6: reflects selected property)
                    _buildAddressCard(property.formattedAddress),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Building Type Selector
                    _buildSectionHeader('Building Structure', 'Defines structural load capacity'),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildPropertyTypeSelector(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Rooftop Structure Selector
                    _buildSectionHeader('Rooftop Surface', 'Determines panel mounting orientation'),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildRoofTypeSelector(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Average Monthly Electricity Spend
                    _buildSectionHeader('Average Monthly Electricity Bill', 'Used to calculate net savings'),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildBillSelector(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // DISCOM & Sanctioned Load Specs
                    _buildDiscomCard(),
                    const SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ),

            // Bottom CTA Card
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.confirmLocation);
              }
            },
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

          // Step Pill
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  const Icon(
                    Icons.home_work_rounded,
                    size: 15,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Step 2 of 5 · Property',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // High Solar Yield Tag
          StatusBadge(
            label: '5.2 Sun-Hrs',
            variant: StatusBadgeVariant.secondaryFixed,
            icon: Icons.wb_sunny,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String address) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadii.md,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.secondaryFixed,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Selected Property',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Change',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineSm.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeSelector() {
    return Column(
      children: _propertyTypes.map((type) {
        final isSelected = _selectedPropertyType == type['title'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedPropertyType = type['title'] as String),
            borderRadius: AppRadii.cardSm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                borderRadius: AppRadii.cardSm,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x10164A38),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondaryContainer : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['title'] as String,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          type['subtitle'] as String,
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoofTypeSelector() {
    return Column(
      children: _roofTypes.map((roof) {
        final isSelected = _selectedRoofType == roof['title'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedRoofType = roof['title'] as String),
            borderRadius: AppRadii.cardSm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                borderRadius: AppRadii.cardSm,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondaryContainer : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      roof['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              roof['title'] as String,
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            StatusBadge(
                              label: roof['tag'] as String,
                              variant: isSelected ? StatusBadgeVariant.green : StatusBadgeVariant.neutral,
                              fontSize: 9,
                            ),
                          ],
                        ),
                        Text(
                          roof['subtitle'] as String,
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillSelector() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Monthly Spend',
                style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Text(
                '₹${_monthlyBill.toInt()}',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Preset Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _billPresets.map((preset) {
              final isPresetSelected = (_monthlyBill - preset).abs() < 50;
              return ChoiceChip(
                label: Text('₹${preset.toInt()}'),
                selected: isPresetSelected,
                selectedColor: AppColors.primaryContainer,
                labelStyle: TextStyle(
                  color: isPresetSelected ? AppColors.secondaryFixed : AppColors.onSurface,
                  fontWeight: isPresetSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _monthlyBill = preset);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Fine slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerHighest,
              thumbColor: AppColors.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: _monthlyBill,
              min: 1500.0,
              max: 12000.0,
              divisions: 21,
              onChanged: (val) => setState(() => _monthlyBill = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscomCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.tertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected DISCOM: BESCOM',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Sanctioned Meter Load: ${_sanctionedLoadKw.toInt()} kW · Net Meter Eligible',
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: 'Eligible',
            variant: StatusBadgeVariant.green,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14164A38),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceSm,
        AppSpacing.margin,
        AppSpacing.spaceSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'Proceed to Rooftop Boundary',
            subtitle: 'AI Satellite Detection',
            showTrailingArrowBadge: true,
            onPressed: _saveAndProceed,
          ),
        ],
      ),
    );
  }
}
