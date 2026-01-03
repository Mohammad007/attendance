import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/wage_calculation_service.dart';
import '../models/attendance.dart';

class PdfService {
  // Generate Wage Slip PDF
  Future<void> generateWageSlip(WageCalculation calculation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'WAGE SLIP',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Period: ${_formatDate(calculation.startDate)} to ${_formatDate(calculation.endDate)}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Worker Details
              _buildSection('Worker Details', [
                _buildRow('Name', calculation.worker.name),
                _buildRow('Job Type', calculation.worker.jobType),
                _buildRow(
                  'Daily Wage',
                  'Rs. ${calculation.worker.dailyWage.toStringAsFixed(2)}',
                ),
                if (calculation.worker.phone != null)
                  _buildRow('Phone', calculation.worker.phone!),
              ]),

              pw.SizedBox(height: 20),

              // Attendance Summary
              _buildSection('Attendance Summary', [
                _buildRow(
                  'Total Days Worked',
                  calculation.totalDays.toStringAsFixed(1),
                ),
                // Overtime hours removed
              ]),

              pw.SizedBox(height: 20),

              // Wage Calculation
              _buildSection('Wage Calculation', [
                _buildRow(
                  'Base Wage',
                  'Rs. ${calculation.baseWage.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ]),

              pw.SizedBox(height: 20),

              // Deductions & Payments
              _buildSection('Deductions & Payments', [
                _buildRow(
                  'Advances',
                  'Rs. ${calculation.totalAdvances.toStringAsFixed(2)}',
                ),
                _buildRow(
                  'Total Paid',
                  'Rs. ${calculation.totalPaid.toStringAsFixed(2)}',
                ),
                pw.Divider(thickness: 2),
                _buildRow(
                  'Balance Due',
                  'Rs. ${calculation.balance.toStringAsFixed(2)}',
                  isBold: true,
                  isHighlight: true,
                ),
              ]),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Text(
                'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Print or share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Generate Attendance Report
  Future<void> generateAttendanceReport(WageCalculation calculation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ATTENDANCE REPORT',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    calculation.worker.name,
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Attendance Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                    _buildTableCell('Wage', isHeader: true),
                  ],
                ),
                // Data Rows
                ...calculation.attendances.map((attendance) {
                  final wage = _calculateDailyWage(
                    calculation.worker.dailyWage,
                    attendance.status,
                    0.0, // No overtime
                  );
                  return pw.TableRow(
                    children: [
                      _buildTableCell(_formatDate(attendance.date)),
                      _buildTableCell(_getStatusText(attendance.status)),
                      _buildTableCell('Rs. ${wage.toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildRow(
                    'Total Days',
                    calculation.totalDays.toStringAsFixed(1),
                  ),
                  // Overtime removed
                  _buildRow(
                    'Total Wage',
                    'Rs. ${calculation.grossWage.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper: Build Section
  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // Helper: Build Row
  pw.Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlight ? PdfColors.green700 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build Table Cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Helper: Format Date
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Helper: Get Status Text
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.half:
        return 'Half Day';
    }
  }

  // Helper: Calculate Daily Wage
  double _calculateDailyWage(
    double dailyWage,
    AttendanceStatus status,
    double overtimeHours,
  ) {
    double wage = 0;

    switch (status) {
      case AttendanceStatus.present:
        wage = dailyWage;
        break;
      case AttendanceStatus.half:
        wage = dailyWage * 0.5;
        break;
      case AttendanceStatus.absent:
        wage = 0;
        break;
    }

    if (overtimeHours > 0) {
      wage += (overtimeHours / 8) * dailyWage * 1.5;
    }

    return wage;
  }

  // Generate Monthly Summary Report for All Workers
  Future<void> generateMonthlySummaryReport(
    List<WageCalculation> calculations,
    String startDate,
    String endDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MONTHLY SUMMARY REPORT',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Period: ${_formatDate(startDate)} to ${_formatDate(endDate)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Worker', isHeader: true),
                    _buildTableCell('Job', isHeader: true),
                    _buildTableCell('Days', isHeader: true),
                    _buildTableCell('Wage', isHeader: true),
                    _buildTableCell('Balance', isHeader: true),
                  ],
                ),
                // Data Rows
                ...calculations.map((calc) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(calc.worker.name),
                      _buildTableCell(calc.worker.jobType),
                      _buildTableCell(calc.totalDays.toStringAsFixed(1)),
                      _buildTableCell(
                        'Rs. ${calc.baseWage.toStringAsFixed(0)}',
                      ),
                      _buildTableCell('Rs. ${calc.balance.toStringAsFixed(0)}'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Totals
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildRow('Total Workers', calculations.length.toString()),
                  _buildRow(
                    'Total Wage',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.baseWage).toStringAsFixed(2)}',
                  ),
                  _buildRow(
                    'Total Balance Due',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.balance).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Generate All Workers Attendance Report
  Future<void> generateAllWorkersAttendanceReport(
    List<WageCalculation> calculations,
    String startDate,
    String endDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ATTENDANCE REPORT - ALL WORKERS',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Period: ${_formatDate(startDate)} to ${_formatDate(endDate)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Workers Attendance Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Worker', isHeader: true),
                    _buildTableCell('Job Type', isHeader: true),
                    _buildTableCell('Days', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                  ],
                ),
                // Data Rows
                ...calculations.map((calc) {
                  String status = 'Active';
                  if (calc.totalDays == 0) {
                    status = 'No Work';
                  } else if (calc.totalDays < 5) {
                    status = 'Low';
                  }

                  return pw.TableRow(
                    children: [
                      _buildTableCell(calc.worker.name),
                      _buildTableCell(calc.worker.jobType),
                      _buildTableCell(calc.totalDays.toStringAsFixed(1)),
                      _buildTableCell(status),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildRow('Total Workers', calculations.length.toString()),
                  _buildRow(
                    'Total Days Worked',
                    calculations
                        .fold<double>(0, (sum, calc) => sum + calc.totalDays)
                        .toStringAsFixed(1),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Generate Payment History Report for All Workers
  Future<void> generatePaymentHistoryReport(
    List<WageCalculation> calculations,
    String startDate,
    String endDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple700,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PAYMENT HISTORY REPORT',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Period: ${_formatDate(startDate)} to ${_formatDate(endDate)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Payment Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Worker', isHeader: true),
                    _buildTableCell('Wage', isHeader: true),
                    _buildTableCell('Advances', isHeader: true),
                    _buildTableCell('Paid', isHeader: true),
                    _buildTableCell('Balance', isHeader: true),
                  ],
                ),
                // Data Rows
                ...calculations.map((calc) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(calc.worker.name),
                      _buildTableCell(
                        'Rs. ${calc.baseWage.toStringAsFixed(0)}',
                      ),
                      _buildTableCell(
                        'Rs. ${calc.totalAdvances.toStringAsFixed(0)}',
                      ),
                      _buildTableCell(
                        'Rs. ${calc.totalPaid.toStringAsFixed(0)}',
                      ),
                      _buildTableCell('Rs. ${calc.balance.toStringAsFixed(0)}'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildRow(
                    'Total Wage',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.baseWage).toStringAsFixed(2)}',
                  ),
                  _buildRow(
                    'Total Advances',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.totalAdvances).toStringAsFixed(2)}',
                  ),
                  _buildRow(
                    'Total Paid',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.totalPaid).toStringAsFixed(2)}',
                  ),
                  _buildRow(
                    'Total Balance Due',
                    'Rs. ${calculations.fold<double>(0, (sum, calc) => sum + calc.balance).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
