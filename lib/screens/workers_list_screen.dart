import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:io';
import '../models/worker.dart';
import '../providers/worker_provider.dart';
import '../utils/currency_formatter.dart';
import 'wage_summary_screen.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WorkerProvider>().loadWorkers());
  }

  // Pick contact from phone
  Future<void> _pickFromContacts() async {
    try {
      final permissionGranted = await FlutterContacts.requestPermission();

      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied to access contacts'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final contact = await FlutterContacts.openExternalPick();

      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(
          contact.id,
          withProperties: true,
          withPhoto: false,
        );

        if (fullContact != null && mounted) {
          _showWorkerFormDialog(
            context,
            null,
            initialName: fullContact.displayName,
            initialPhone: fullContact.phones.isNotEmpty
                ? fullContact.phones.first.number
                : '',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Workers Management',
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
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildWorkersList()),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF2E66FF),
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.2,
        spacing: 16,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add_rounded),
            label: 'Add Manually',
            backgroundColor: const Color(0xFF27AE60),
            foregroundColor: Colors.white,
            onTap: () => _showWorkerFormDialog(context, null),
          ),
          SpeedDialChild(
            child: const Icon(Icons.contacts_rounded),
            label: 'Add from Contacts',
            backgroundColor: const Color(0xFF4C6FFF),
            foregroundColor: Colors.white,
            onTap: _pickFromContacts,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search workers...',
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Colors.black45),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black45),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        if (workerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var workers = workerProvider.activeWorkers;

        if (_searchQuery.isNotEmpty) {
          workers = workers
              .where(
                (w) =>
                    w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    w.jobType.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        }

        if (workers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => workerProvider.loadWorkers(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return _buildWorkerCard(worker);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No workers found' : 'No workers yet',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showWorkerDetails(context, worker),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: worker.photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(worker.photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: const Color(0xFFF1F4F9),
                ),
                child: worker.photoPath == null
                    ? const Icon(Icons.person, size: 32, color: Colors.black26)
                    : null,
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.work_rounded,
                          size: 14,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          worker.jobType,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                        if (worker.phone != null) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              worker.phone!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F0FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${CurrencyFormatter.format(worker.dailyWage)}/day',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E66FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black26),
                color: Colors.white,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showWorkerFormDialog(context, worker);
                      break;
                    case 'delete':
                      _confirmDelete(context, worker);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F0FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Color(0xFF2E66FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Delete worker',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkerDetails(BuildContext context, Worker worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: worker.photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(worker.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFFF1F4F9),
                  ),
                  child: worker.photoPath == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black26,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  worker.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  worker.jobType,
                  style: const TextStyle(fontSize: 16, color: Colors.black45),
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailRow(
                Icons.currency_rupee,
                'Daily Wage',
                CurrencyFormatter.format(worker.dailyWage),
              ),
              if (worker.phone != null)
                _buildDetailRow(Icons.phone, 'Phone', worker.phone!),
              _buildDetailRow(
                Icons.calendar_today,
                'Joined',
                _formatDate(worker.joinDate),
              ),
              _buildDetailRow(
                worker.isActive ? Icons.check_circle : Icons.cancel,
                'Status',
                worker.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showWorkerFormDialog(context, worker);
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E66FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WageSummaryScreen(initialWorker: worker),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black45),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black45),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkerFormDialog(
    BuildContext context,
    Worker? worker, {
    String? initialName,
    String? initialPhone,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: worker?.name ?? initialName,
    );
    final phoneController = TextEditingController(
      text: worker?.phone ?? initialPhone,
    );
    final jobTypeController = TextEditingController(text: worker?.jobType);
    final wageController = TextEditingController(
      text: worker?.dailyWage.toString() == 'null'
          ? ''
          : worker?.dailyWage.toString(),
    );
    String? photoPath = worker?.photoPath;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    worker == null ? 'Add Worker Manually' : 'Edit Worker',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      if (image != null) setState(() => photoPath = image.path);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F0FF),
                        shape: BoxShape.circle,
                        image: photoPath != null
                            ? DecorationImage(
                                image: FileImage(File(photoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoPath == null
                          ? const Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: Color(0xFF2D3142),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    nameController,
                    'Name *',
                    Icons.person_rounded,
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    phoneController,
                    'Phone',
                    Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    jobTypeController,
                    'Job Type *',
                    Icons.work_rounded,
                    validator: (v) => v!.isEmpty ? 'Enter job type' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    wageController,
                    'Daily Wage *',
                    Icons.currency_rupee_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter wage' : null,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF2E66FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF345A81,
                            ), // Dark blueish button from image
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final newWorker = Worker(
                                id: worker?.id,
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim().isEmpty
                                    ? null
                                    : phoneController.text.trim(),
                                jobType: jobTypeController.text.trim(),
                                dailyWage:
                                    double.tryParse(wageController.text) ?? 0.0,
                                joinDate:
                                    worker?.joinDate ??
                                    DateTime.now().toIso8601String().split(
                                      'T',
                                    )[0],
                                photoPath: photoPath,
                                isActive: worker?.isActive ?? true,
                              );

                              final provider = context.read<WorkerProvider>();
                              final success = worker == null
                                  ? await provider.addWorker(newWorker)
                                  : await provider.updateWorker(newWorker);

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success ? 'Success!' : 'Error saving',
                                    ),
                                    backgroundColor: success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(worker == null ? 'Add' : 'Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black45, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E66FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Worker'),
        content: Text('Are you sure you want to delete ${worker.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<WorkerProvider>().deleteWorker(
                worker.id!,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Deleted' : 'Error deleting'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
