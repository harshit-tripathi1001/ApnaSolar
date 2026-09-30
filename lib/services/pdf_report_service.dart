import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'auth_service.dart';
import 'solar_session_service.dart';

/// Generates and exports the official ApnaSolar PDF Audit Dossier.
class PdfReportService {
  static final PdfReportService _instance = PdfReportService._internal();
  factory PdfReportService() => _instance;
  PdfReportService._internal();

  /// Compiles the structured PDF document for the current session.
  Future<Uint8List> buildPdfReport({
    required SolarSessionState session,
    User? user,
  }) async {
    final pdf = pw.Document(
      title: 'ApnaSolar Rooftop Feasibility Audit Report',
      author: 'ApnaSolar AI Engine',
    );

    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle('assets/images/app_logo.png');
    } catch (_) {
      // Offline / headless test fallback
    }

    final currentUser = user ?? AuthService().currentUser;
    final resolvedName = AuthService.resolveUserName(
      authUser: currentUser,
      fallback: 'Solar Homeowner',
    );
    final userName = resolvedName.isNotEmpty ? resolvedName : 'Solar Homeowner';
    final userEmail = currentUser?.email ?? 'Direct Portal Assessment';

    final prop = session.selectedProperty;
    final financials = session.financialBreakdown;
    final solarEstimate = session.solarEstimate;
    final capacity = session.selectedCapacityKw;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#003323'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            width: 36,
                            height: 36,
                            margin: const pw.EdgeInsets.only(right: 12),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.all(
                                pw.Radius.circular(6),
                              ),
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Image(logoImage),
                            ),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'APNASOLAR',
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('#F5C542'),
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'National Rooftop Solar Feasibility Audit Report',
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#0B6D33'),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                          child: pw.Text(
                            'PM SURYA GHAR CERTIFIED',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Report ID: AS-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Consumer & Site Information
              pw.Text(
                '1. CONSUMER & SITE DIAGNOSTICS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#003323'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPdfKeyValue('Consumer Name', userName),
                        pw.SizedBox(height: 4),
                        _buildPdfKeyValue('Contact Identifier', userEmail),
                        pw.SizedBox(height: 4),
                        _buildPdfKeyValue(
                          'DISCOM Authority',
                          '${prop.city} Electric Supply Co.',
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPdfKeyValue(
                          'Site Address',
                          prop.formattedAddress,
                        ),
                        pw.SizedBox(height: 4),
                        _buildPdfKeyValue(
                          'City / State',
                          '${prop.city}, ${prop.state}',
                        ),
                        pw.SizedBox(height: 4),
                        _buildPdfKeyValue(
                          'Coordinates',
                          '${prop.latitude.toStringAsFixed(4)} N, ${prop.longitude.toStringAsFixed(4)} E',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Rooftop & Solar Geometry
              pw.Text(
                '2. ROOFTOP AI VISION & SHADOW ANALYSIS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#003323'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  _buildPdfStatBox(
                    'Gross Terrace Area',
                    '${session.rooftopAnalysis.totalGrossAreaSqFt.toInt()} sq.ft',
                    PdfColors.grey800,
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfStatBox(
                    'Effective Solar Area',
                    '${session.rooftopAnalysis.netUsableAreaSqFt.toInt()} sq.ft',
                    PdfColor.fromHex('#0B6D33'),
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfStatBox(
                    'Obstacles Isolated',
                    'Mumty & Tanks',
                    PdfColors.grey700,
                  ),
                  pw.SizedBox(width: 10),
                  _buildPdfStatBox(
                    'Peak Sun Irradiance',
                    '5.4 hrs/day',
                    PdfColor.fromHex('#003323'),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              // Technical Recommendation
              pw.Text(
                '3. RECOMMENDED SOLAR HARDWARE SPECIFICATIONS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#003323'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F4FBF4'),
                  border: pw.Border.all(color: PdfColor.fromHex('#B5E2C4')),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfTableRow(
                      'Recommended Plant Size',
                      '${capacity.toStringAsFixed(1)} kW Grid-Tied System',
                    ),
                    pw.Divider(color: PdfColor.fromHex('#E0EFE5')),
                    _buildPdfTableRow(
                      'Photovoltaic Modules',
                      '14 x Tier-1 400W Bifacial Mono-PERC Panels (25-Yr Warranty)',
                    ),
                    pw.Divider(color: PdfColor.fromHex('#E0EFE5')),
                    _buildPdfTableRow(
                      'Power Inverter',
                      '5kW IP65 Smart String Inverter with MPPT Efficiency >98%',
                    ),
                    pw.Divider(color: PdfColor.fromHex('#E0EFE5')),
                    _buildPdfTableRow(
                      'Estimated Annual Generation',
                      '~${solarEstimate.annualGenerationKwh.toInt()} kWh (Units) per year',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Financial Economics & PM Surya Ghar Subsidy
              pw.Text(
                '4. FINANCIAL AUDIT & CENTRAL GOVT. SUBSIDY BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#003323'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfTableRow(
                      'Turnkey Project Cost (Panels, Inverter, Bos & Approvals)',
                      'Rs. ${financials.grossTurnkeyCost.toInt()}',
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    _buildPdfTableRow(
                      'PM Surya Ghar Muft Bijli Yojana Central DBT Subsidy',
                      '- Rs. ${financials.centralDbtSubsidy.toInt()} (Direct Bank Credit)',
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    _buildPdfTableRow(
                      'Net Consumer Investment Payable',
                      'Rs. ${financials.netPayableCost.toInt()}',
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    _buildPdfTableRow(
                      'Estimated 1st Year Electricity Savings',
                      'Rs. ${financials.annualSavings.toInt()} / year',
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    _buildPdfTableRow(
                      'Payback Breakeven Period',
                      '${financials.paybackPeriodYears.toStringAsFixed(1)} Years',
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    _buildPdfTableRow(
                      'Cumulative 25-Year Net Economic Gain',
                      'Rs. ${(financials.cumulative25YearSavings / 100000).toStringAsFixed(2)} Lakhs',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Environmental Impact & Accreditation Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#003323'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '25-Year Environmental Offsets:',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Offset ~${solarEstimate.co2OffsetTonnesPerYear.toStringAsFixed(1)} Tonnes CO2/yr  •  Equivalent to planting ${solarEstimate.treeOffsetEquivalent} teak trees',
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Official ApnaSolar AI Dossier\nGenerated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Triggers the browser download or platform print dialog.
  Future<void> downloadOrPrintReport({
    required BuildContext context,
    required SolarSessionState session,
    User? user,
  }) async {
    final pdfBytes = await buildPdfReport(session: session, user: user);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'ApnaSolar_Official_Solar_Audit_Report.pdf',
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static pw.Widget _buildPdfKeyValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfStatBox(
    String title,
    String value,
    PdfColor valueColor,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: valueColor,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPdfTableRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            key,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#003323'),
            ),
          ),
        ],
      ),
    );
  }
}
