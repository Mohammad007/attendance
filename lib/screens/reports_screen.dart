import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/worker.dart';
import '../providers/worker_provider.dart';
import '../services/wage_calculation_service.dart';
import '../services/pdf_service.dart';
import '../utils/currency_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  final WageCalculationService _wageService = WageCalculationService();
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    // Set to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
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
            // Date Range Selector
            _buildDateRangeCard(colorScheme),

            const SizedBox(height: 24),

            // Report Types
            const Text(
              'Select Report Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Monthly Summary Report
            _buildReportCard(
              colorScheme,
              title: 'Monthly Summary Report',
              description: 'Complete wage summary for all workers',
              icon: Icons.summarize,
              color: Colors.blue,
              onTap: _generateMonthlySummary,
            ),

            const SizedBox(height: 12),

            // Worker-wise Report
            _buildReportCard(
              colorScheme,
              title: 'Worker-wise Report',
              description: 'Individual worker attendance and wages',
              icon: Icons.person,
              color: Colors.green,
              onTap: _generateWorkerWiseReport,
            ),

            const SizedBox(height: 12),

            // Attendance Report
            _buildReportCard(
              colorScheme,
              title: 'Attendance Report',
              description: 'Daily attendance records for all workers',
              icon: Icons.calendar_month,
              color: Colors.orange,
              onTap: _generateAttendanceReport,
            ),

            const SizedBox(height: 12),

            // Payment History Report
            _buildReportCard(
              colorScheme,
              title: 'Payment History',
              description: 'All payments and advances record',
              icon: Icons.payment,
              color: Colors.purple,
              onTap: _generatePaymentReport,
            ),

            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
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
                  'Report Period',
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
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From', style: TextStyle(fontSize: 10)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_startDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To', style: TextStyle(fontSize: 10)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_endDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
              runSpacing: 8,
              children: [
                _buildQuickDateChip('This Week', 'week'),
                _buildQuickDateChip('This Month', 'month'),
                _buildQuickDateChip('Last Month', 'last_month'),
                _buildQuickDateChip('Last 3 Months', '3_months'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, String range) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) => _setDateRange(range),
    );
  }

  Widget _buildReportCard(
    ColorScheme colorScheme, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isGenerating ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ColorScheme colorScheme) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Workers',
                        workerProvider.workers.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Active Workers',
                        workerProvider.activeWorkers.length.toString(),
                        Icons.person,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Period',
                        '${(_endDate.difference(_startDate).inDays + 1)} days',
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'Reports',
                        '4 types',
                        Icons.description,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateMonthlySummary() async {
    setState(() => _isGenerating = true);

    try {
      final workerProvider = context.read<WorkerProvider>();
      final workers = workerProvider.activeWorkers;

      if (workers.isEmpty) {
        _showMessage('No active workers found', isError: true);
        setState(() => _isGenerating = false);
        return;
      }

      final summaries = await _wageService.getMonthlyWageSummary(
        workers,
        DateFormat('yyyy-MM-dd').format(_startDate),
        DateFormat('yyyy-MM-dd').format(_endDate),
      );

      // Generate PDF for ALL workers
      if (summaries.isNotEmpty) {
        await _pdfService.generateMonthlySummaryReport(
          summaries,
          DateFormat('yyyy-MM-dd').format(_startDate),
          DateFormat('yyyy-MM-dd').format(_endDate),
        );
        _showMessage(
          'Monthly summary generated for ${summaries.length} workers!',
        );
      }
    } catch (e) {
      _showMessage('Error generating report: $e', isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateWorkerWiseReport() async {
    final workerProvider = context.read<WorkerProvider>();
    final workers = workerProvider.activeWorkers;

    if (workers.isEmpty) {
      _showMessage('No active workers found', isError: true);
      return;
    }

    // Show worker selection dialog
    final selectedWorker = await showDialog<Worker>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Worker'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(worker.name[0].toUpperCase()),
                ),
                title: Text(worker.name),
                subtitle: Text(worker.jobType),
                onTap: () => Navigator.pop(context, worker),
              );
            },
          ),
        ),
      ),
    );

    if (selectedWorker != null) {
      setState(() => _isGenerating = true);

      try {
        final calculation = await _wageService.calculateWage(
          worker: selectedWorker,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate),
        );

        await _pdfService.generateAttendanceReport(calculation);
        _showMessage('Worker report generated successfully!');
      } catch (e) {
        _showMessage('Error generating report: $e', isError: true);
      } finally {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateAttendanceReport() async {
    setState(() => _isGenerating = true);

    try {
      final workerProvider = context.read<WorkerProvider>();
      final workers = workerProvider.activeWorkers;

      if (workers.isEmpty) {
        _showMessage('No active workers found', isError: true);
        setState(() => _isGenerating = false);
        return;
      }

      // Get calculations for ALL workers
      final summaries = await _wageService.getMonthlyWageSummary(
        workers,
        DateFormat('yyyy-MM-dd').format(_startDate),
        DateFormat('yyyy-MM-dd').format(_endDate),
      );

      // Generate attendance report for ALL workers
      await _pdfService.generateAllWorkersAttendanceReport(
        summaries,
        DateFormat('yyyy-MM-dd').format(_startDate),
        DateFormat('yyyy-MM-dd').format(_endDate),
      );
      _showMessage(
        'Attendance report generated for ${summaries.length} workers!',
      );
    } catch (e) {
      _showMessage('Error generating report: $e', isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generatePaymentReport() async {
    setState(() => _isGenerating = true);

    try {
      final workerProvider = context.read<WorkerProvider>();
      final workers = workerProvider.activeWorkers;

      if (workers.isEmpty) {
        _showMessage('No active workers found', isError: true);
        setState(() => _isGenerating = false);
        return;
      }

      // Get calculations for ALL workers
      final summaries = await _wageService.getMonthlyWageSummary(
        workers,
        DateFormat('yyyy-MM-dd').format(_startDate),
        DateFormat('yyyy-MM-dd').format(_endDate),
      );

      // Generate payment history for ALL workers
      await _pdfService.generatePaymentHistoryReport(
        summaries,
        DateFormat('yyyy-MM-dd').format(_startDate),
        DateFormat('yyyy-MM-dd').format(_endDate),
      );
      _showMessage('Payment report generated for ${summaries.length} workers!');
    } catch (e) {
      _showMessage('Error generating report: $e', isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
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
        case '3_months':
          _startDate = DateTime(now.year, now.month - 3, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
      }
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }
}
