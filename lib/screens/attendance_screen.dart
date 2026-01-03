import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/worker.dart';
import '../models/attendance.dart';
import '../providers/worker_provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<int, AttendanceStatus> _attendanceMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceForDate();
  }

  Future<void> _loadAttendanceForDate() async {
    setState(() => _isLoading = true);

    final attendanceProvider = context.read<AttendanceProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final attendances = await attendanceProvider.getAttendanceByDate(dateStr);

    setState(() {
      _attendanceMap.clear();
      for (var attendance in attendances) {
        _attendanceMap[attendance.workerId] = attendance.status;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    if (_attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one worker'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final attendanceProvider = context.read<AttendanceProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      for (var entry in _attendanceMap.entries) {
        final workerId = entry.key;
        final status = entry.value;

        final attendance = Attendance(
          workerId: workerId,
          date: dateStr,
          status: status,
          overtimeHours: 0.0,
        );

        await attendanceProvider.markAttendance(attendance);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAllPresent() {
    final workers = context.read<WorkerProvider>().activeWorkers;
    setState(() {
      for (var worker in workers) {
        _attendanceMap[worker.id!] = AttendanceStatus.present;
      }
    });
  }

  void _markAllAbsent() {
    final workers = context.read<WorkerProvider>().activeWorkers;
    setState(() {
      for (var worker in workers) {
        _attendanceMap[worker.id!] = AttendanceStatus.absent;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _attendanceMap.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: const Text(
          'Mark Attendance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'all_present':
                  _markAllPresent();
                  break;
                case 'all_absent':
                  _markAllAbsent();
                  break;
                case 'clear':
                  _clearAll();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all_present',
                child: Text('Mark All Present'),
              ),
              const PopupMenuItem(
                value: 'all_absent',
                child: Text('Mark All Absent'),
              ),
              const PopupMenuItem(value: 'clear', child: Text('Clear All')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildModernCalendar(),
              _buildDateInfoBar(),
              Expanded(child: _buildWorkersList()),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _attendanceMap.isNotEmpty
                ? _buildSaveButton()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black45),
                onPressed: () {
                  setState(
                    () => _selectedDate = _selectedDate.subtract(
                      const Duration(days: 7),
                    ),
                  );
                  _loadAttendanceForDate();
                },
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E3FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'WEEK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E66FF),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black45),
                onPressed: () {
                  setState(
                    () => _selectedDate = _selectedDate.add(
                      const Duration(days: 7),
                    ),
                  );
                  _loadAttendanceForDate();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              DateTime day = _selectedDate.subtract(
                Duration(days: _selectedDate.weekday % 7 - index),
              );
              bool isSelected =
                  day.day == _selectedDate.day &&
                  day.month == _selectedDate.month &&
                  day.year == _selectedDate.year;
              return Column(
                children: [
                  Text(
                    DateFormat('E').format(day),
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = day);
                      _loadAttendanceForDate();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF345A81)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF345A81,
                                  ).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoBar() {
    final isToday =
        DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1E3FF).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: Color(0xFF345A81)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              if (isToday)
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF345A81),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_attendanceMap.length} marked',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersList() {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        if (workerProvider.isLoading)
          return const Center(child: CircularProgressIndicator());
        final workers = workerProvider.activeWorkers;
        if (workers.isEmpty)
          return const Center(child: Text('No active workers'));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: workers.length,
          itemBuilder: (context, index) =>
              _buildWorkerAttendanceCard(workers[index]),
        );
      },
    );
  }

  Widget _buildWorkerAttendanceCard(Worker worker) {
    final status = _attendanceMap[worker.id];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E3FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  worker.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2E66FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      worker.jobType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${worker.dailyWage.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E66FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  worker.id!,
                  AttendanceStatus.present,
                  'Present',
                  Icons.check_circle_rounded,
                  const Color(0xFF53B158),
                  status == AttendanceStatus.present,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  worker.id!,
                  AttendanceStatus.half,
                  'Half',
                  Icons.access_time_filled_rounded,
                  const Color(0xFFF2994A),
                  status == AttendanceStatus.half,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  worker.id!,
                  AttendanceStatus.absent,
                  'Absent',
                  Icons.cancel_rounded,
                  const Color(0xFFFF5252),
                  status == AttendanceStatus.absent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    int workerId,
    AttendanceStatus status,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _attendanceMap[workerId] = status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? null : color.withOpacity(0.1),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2E66FF), Color(0xFF5544FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD1E3FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF345A81).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveAttendance,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF345A81),
                  ),
                )
              else
                const Icon(Icons.save_rounded, color: Color(0xFF345A81)),
              const SizedBox(width: 12),
              Text(
                _isLoading ? 'SAVING...' : 'Save Attendance',
                style: const TextStyle(
                  color: Color(0xFF345A81),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
