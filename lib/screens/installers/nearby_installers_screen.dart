import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/installer_provider.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/common/app_button.dart';

/// Dynamic, Interactive Nearby Verified Installers Screen
/// Lists vetted solar EPC contractors with filters, ratings, turnaround times,
/// pricing per kW, and instant booking modal.
class NearbyInstallersScreen extends StatefulWidget {
  const NearbyInstallersScreen({super.key});

  @override
  State<NearbyInstallersScreen> createState() => _NearbyInstallersScreenState();
}

class _NearbyInstallersScreenState extends State<NearbyInstallersScreen> {
  final _session = SolarSessionState();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Empanelled verified solar installers
  final List<VerifiedInstaller> _allInstallers =
      VerifiedInstaller.defaultInstallers;

  List<VerifiedInstaller> get _filteredInstallers {
    return _allInstallers.where((installer) {
      // Query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = installer.name.toLowerCase().contains(q);
        final matchesBrand = installer.primaryBrand.toLowerCase().contains(q);
        if (!matchesName && !matchesBrand) return false;
      }
      // Category filter
      if (_selectedFilter == 'Top Rated') {
        return installer.rating >= 4.8;
      } else if (_selectedFilter == 'Fastest (<14d)') {
        return installer.turnaroundDays <= 13;
      } else if (_selectedFilter == 'Best Price') {
        return installer.pricePerKw <= 50500;
      } else if (_selectedFilter == 'Empanelled') {
        return installer.badges.any(
          (b) => b.contains('Empanelled') || b.contains('Certified'),
        );
      }
      return true;
    }).toList();
  }

  void _showBookingDialog(VerifiedInstaller installer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.engineering_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          installer.name,
                          style: AppTypography.titleLg.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${installer.distanceKm} km away · ${installer.turnaroundDays} Days Turnaround',
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.cardSm,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Site Inspection Address:',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _session.selectedProperty.locality,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated System Size:',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          '${_session.selectedCapacityKw.toStringAsFixed(1)} kW',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Quote:',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          '₹${((installer.pricePerKw * _session.selectedCapacityKw)).round()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Includes Free Physical Roof Survey, Structural Stability Inspection & DISCOM Net-Metering Feasibility Check.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              AppButton.primary(
                label: 'Confirm Free Site Visit Booking',
                icon: Icons.calendar_today_rounded,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _session.setSelectedInstaller(installer);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text(
                          '✓ Site audit booked with ${installer.name}! They will call you at ${installer.phone}.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locality = _session.selectedProperty.locality;
    final installers = _filteredInstallers;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, locality),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Filter Bar
                    _buildSearchAndFilters(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Installer count banner
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${installers.length} Empanelled Installers',
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Within 10 km radius',
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Installer Cards or Empty State
                    if (installers.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 36,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: AppRadii.card,
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.engineering_outlined,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No verifier/installer is currently available.',
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'There are no empanelled partners matching this query in your area. Please try clearing the filter or checking back soon.',
                              style: AppTypography.bodyMd.copyWith(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...installers.map((inst) => _buildInstallerCard(inst)),

                    const SizedBox(height: AppSpacing.spaceMd),
                    // Trust & Protection Badge
                    _buildEscrowProtectionCard(),
                    const SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ),
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String locality) {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: AppRadii.full,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Verified Local Installers',
                      style: AppTypography.titleLg.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Serving $locality',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: AppRadii.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  size: 13,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'DISCOM Vetted',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadii.cardSm,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              icon: Icon(Icons.search, size: 20, color: AppColors.outline),
              hintText: 'Search by installer or panel brand (Tata, Waaree...)',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.outline),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                [
                  'All',
                  'Top Rated',
                  'Fastest (<14d)',
                  'Best Price',
                  'Empanelled',
                ].map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 11,
                      ),
                      backgroundColor: AppColors.surfaceContainerLowest,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = f);
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallerCard(VerifiedInstaller inst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: inst.isTopPick
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
          width: inst.isTopPick ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: inst.isTopPick
                      ? AppColors.primaryContainer.withValues(alpha: 0.4)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.solar_power_rounded,
                  color: inst.isTopPick
                      ? AppColors.primary
                      : AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            inst.name,
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (inst.isTopPick) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TOP PICK',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${inst.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '(${inst.reviewsCount}) · ${inst.distanceKm} km',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${inst.pricePerKw ~/ 1000}k / kW',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${inst.turnaroundDays}d install',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Brands and specs row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${inst.primaryBrand} · ${inst.inverterBrand}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${inst.totalInstallations}+ Done',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Badges
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: inst.badges.map((b) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.cardSm,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Connecting to ${inst.name} on WhatsApp (${inst.phone})...',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_outlined,
                    size: 16,
                    color: Color(0xFF25D366),
                  ),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.cardSm,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showBookingDialog(inst),
                  icon: const Icon(Icons.calendar_today_rounded, size: 15),
                  label: const Text(
                    'Book Audit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowProtectionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ApnaSolar Escrow & Quality Guarantee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Your milestone payments are protected in escrow and released only upon successful bi-directional net-meter sync and DISCOM approval.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: 12,
      ),
      child: AppButton.secondary(
        label: 'Compare Top 3 Vendor Bids',
        icon: Icons.compare_arrows_rounded,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.compareVendors),
      ),
    );
  }
}
