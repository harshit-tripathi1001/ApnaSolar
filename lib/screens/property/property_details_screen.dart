import 'package:file_picker/file_picker.dart';
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

/// Representation of an uploaded utility bill file
class UploadedBill {
  final String name;
  final String size;
  final String monthLabel;

  const UploadedBill({
    required this.name,
    required this.size,
    required this.monthLabel,
  });
}

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

  final List<UploadedBill> _uploadedBills = [];
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    _selectedPropertyType = _session.propertyType;
    _selectedRoofType = _session.roofType;
    _monthlyBill = _session.monthlyBill;
    _sanctionedLoadKw = _session.sanctionedLoadKw;
    for (int i = 0; i < _session.uploadedBills.length; i++) {
      final name = _session.uploadedBills[i];
      final month = (i == 0)
          ? 'Month 1 (Latest Bill)'
          : (i == 1)
          ? 'Month 2 (Previous Bill)'
          : 'Month ${i + 1} Bill';
      _uploadedBills.add(
        UploadedBill(name: name, size: '142 KB', monthLabel: month),
      );
    }
  }

  Future<void> _pickBills() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isNotEmpty) {
        setState(() {
          for (final file in result) {
            final sizeBytes = file.lengthSync() ?? 128000;
            final sizeKb = (sizeBytes / 1024).round();
            final count = _uploadedBills.length + 1;
            final month = count == 1
                ? 'Month 1 (Latest Bill)'
                : count == 2
                ? 'Month 2 (Previous Bill)'
                : 'Month $count Bill';
            _uploadedBills.add(
              UploadedBill(
                name: file.name,
                size: '$sizeKb KB',
                monthLabel: month,
              ),
            );
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text(
                '✓ ${_uploadedBills.length} electricity bills attached successfully!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _saveAndProceed() {
    _session.updatePropertyDetails(
      propertyType: _selectedPropertyType,
      roofType: _selectedRoofType,
      monthlyBill: _monthlyBill,
      sanctionedLoadKw: _sanctionedLoadKw,
      uploadedBills: _uploadedBills.map((b) => b.name).toList(),
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
                    _buildSectionHeader(
                      'Building Structure',
                      'Defines structural load capacity',
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildPropertyTypeSelector(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Rooftop Structure Selector
                    _buildSectionHeader(
                      'Rooftop Surface',
                      'Determines panel mounting orientation',
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildRoofTypeSelector(),
                    const SizedBox(height: AppSpacing.spaceLg),

                    // Average Monthly Electricity Spend
                    _buildSectionHeader(
                      'Average Monthly Electricity Bill',
                      'Used to calculate net savings',
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildBillSelector(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Upload Last 2 Months Electricity Bills (PDF)
                    _buildSectionHeader(
                      'Upload Last 2 Months Bills',
                      'Attach multiple PDF utility bills for subsidy & sanction load calibration',
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildBillUploadSection(),
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
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.confirmLocation,
                );
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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'Selected Property',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.secondary,
                    ),
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
            onTap: () =>
                setState(() => _selectedPropertyType = type['title'] as String),
            borderRadius: AppRadii.cardSm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                borderRadius: AppRadii.cardSm,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
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
                      color: isSelected
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurfaceVariant,
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
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurface,
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
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
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
            onTap: () =>
                setState(() => _selectedRoofType = roof['title'] as String),
            borderRadius: AppRadii.cardSm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                borderRadius: AppRadii.cardSm,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      roof['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurfaceVariant,
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
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                            StatusBadge(
                              label: roof['tag'] as String,
                              variant: isSelected
                                  ? StatusBadgeVariant.green
                                  : StatusBadgeVariant.neutral,
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
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Current Monthly Spend',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 6,
            runSpacing: 6,
            children: _billPresets.map((preset) {
              final isPresetSelected = (_monthlyBill - preset).abs() < 50;
              return ChoiceChip(
                label: Text('₹${preset.toInt()}'),
                selected: isPresetSelected,
                selectedColor: AppColors.primaryContainer,
                labelStyle: TextStyle(
                  color: isPresetSelected
                      ? AppColors.secondaryFixed
                      : AppColors.onSurface,
                  fontWeight: isPresetSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
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

  Widget _buildBillUploadSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Electricity Bills (Last 2 Months)',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'PDF format • Accelerates MNRE Subsidy approval',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Uploaded bill items list
          if (_uploadedBills.isNotEmpty) ...[
            ..._uploadedBills.asMap().entries.map((entry) {
              final idx = entry.key;
              final bill = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.cardSm,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFE53935),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.name,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${bill.monthLabel} • ${bill.size}',
                                style: AppTypography.bodyMd.copyWith(
                                  fontSize: 10,
                                  color: AppColors.outline,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Ready for OCR',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.outline,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _uploadedBills.removeAt(idx);
                        });
                      },
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
          ],

          // Pick Button / Add More Button
          InkWell(
            onTap: _isPickingFile ? null : _pickBills,
            borderRadius: AppRadii.cardSm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _uploadedBills.isEmpty
                    ? AppColors.surfaceContainerLow
                    : AppColors.surfaceContainerLowest,
                borderRadius: AppRadii.cardSm,
                border: Border.all(
                  color: _uploadedBills.isEmpty
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: _isPickingFile
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _uploadedBills.isEmpty
                              ? Icons.file_upload_outlined
                              : Icons.add_circle_outline_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _uploadedBills.isEmpty
                                ? 'Upload Bills (PDF)'
                                : 'Upload Another Bill (PDF)',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildDiscomCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
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
