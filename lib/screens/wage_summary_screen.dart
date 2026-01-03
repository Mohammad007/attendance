import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/worker.dart';
import '../providers/worker_provider.dart';
import '../services/wage_calculation_service.dart';
import '../services/pdf_service.dart';
import '../utils/currency_formatter.dart';

class WageSummaryScreen extends StatefulWidget {
  final Worker? initialWorker;
  const WageSummaryScreen({super.key, this.initialWorker});

  @override
  State<WageSummaryScreen> createState() => _WageSummaryScreenState();
}

class _WageSummaryScreenState extends State<WageSummaryScreen> {
  Worker? _selectedWorker;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  WageCalculation? _wageCalculation;
  bool _isCalculating = false;

  final WageCalculationService _wageService = WageCalculationService();
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    _selectedWorker = widget.initialWorker;
    // Set to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    if (_selectedWorker != null) {
      // Auto calculate if worker is provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateWage();
      });
    }
  }

  Future<void> _calculateWage() async {
    if (_selectedWorker == null) return;

    setState(() => _isCalculating = true);

    try {
      final calculation = await _wageService.calculateWage(
        worker: _selectedWorker!,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      );

      setState(() {
        _wageCalculation = calculation;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating wage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateWageSlip() async {
    if (_wageCalculation == null) return;

    try {
      await _pdfService.generateWageSlip(_wageCalculation!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating wage slip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wage Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E66FF), Color(0xFF5544FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker Selection
            _buildWorkerSelector(colorScheme),

            const SizedBox(height: 16),

            // Date Range Selection
            _buildDateRangeSelector(colorScheme),

            const SizedBox(height: 16),

            // Calculate Button
            if (_selectedWorker != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isCalculating ? null : _calculateWage,
                  icon: _isCalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(
                    _isCalculating ? 'Calculating...' : 'Calculate Wage',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF2E66FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Wage Calculation Results
            if (_wageCalculation != null) ...[
              _buildWageSummaryCard(colorScheme),
              const SizedBox(height: 16),
              _buildAttendanceBreakdown(colorScheme),
              const SizedBox(height: 16),
              _buildPaymentSummary(colorScheme),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSelector(ColorScheme colorScheme) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        final workers = workerProvider.activeWorkers;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Worker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Worker>(
                  value: _selectedWorker,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose a worker',
                  ),
                  items: workers.map((worker) {
                    return DropdownMenuItem(
                      value: worker,
                      child: Text('${worker.name} - ${worker.jobType}'),
                    );
                  }).toList(),
                  onChanged: (worker) {
                    setState(() {
                      _selectedWorker = worker;
                      _wageCalculation = null;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSelector(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Date Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From', style: TextStyle(fontSize: 10)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_startDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To', style: TextStyle(fontSize: 10)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_endDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('This Week'),
                  onSelected: (selected) => _setDateRange('week'),
                ),
                FilterChip(
                  label: const Text('This Month'),
                  onSelected: (selected) => _setDateRange('month'),
                ),
                FilterChip(
                  label: const Text('Last Month'),
                  onSelected: (selected) => _setDateRange('last_month'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWageSummaryCard(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wage Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Base Wage',
              CurrencyFormatter.format(_wageCalculation!.baseWage),
              colorScheme.onPrimaryContainer,
              isBold: true,
              fontSize: 18,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Advances',
              '- ${CurrencyFormatter.format(_wageCalculation!.totalAdvances)}',
              Colors.red[300]!,
            ),
            _buildSummaryRow(
              'Paid',
              '- ${CurrencyFormatter.format(_wageCalculation!.totalPaid)}',
              Colors.red[300]!,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Balance Due',
              CurrencyFormatter.format(_wageCalculation!.balance),
              colorScheme.onPrimaryContainer,
              isBold: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color.withOpacity(0.9),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBreakdown(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Attendance Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Only show Days Worked
            Center(
              child: _buildStatBox(
                'Days Worked',
                _wageCalculation!.totalDays.toStringAsFixed(1),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Total Paid',
                    CurrencyFormatter.formatCompact(
                      _wageCalculation!.totalPaid,
                    ),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'Advances',
                    CurrencyFormatter.formatCompact(
                      _wageCalculation!.totalAdvances,
                    ),
                    Icons.money_off,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _generateWageSlip,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate Wage Slip (PDF)'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              if (_wageCalculation != null) {
                await _pdfService.generateAttendanceReport(_wageCalculation!);
              }
            },
            icon: const Icon(Icons.assessment),
            label: const Text('View Attendance Report'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _wageCalculation = null;
      });
    }
  }

  void _setDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      switch (range) {
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'last_month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
      }
      _wageCalculation = null;
    });
  }
}
