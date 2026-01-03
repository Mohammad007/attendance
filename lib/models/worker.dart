class Worker {
  final int? id;
  final String name;
  final String? phone;
  final String jobType;
  final double dailyWage;
  final String joinDate;
  final String? photoPath;
  final bool isActive;

  Worker({
    this.id,
    required this.name,
    this.phone,
    required this.jobType,
    required this.dailyWage,
    required this.joinDate,
    this.photoPath,
    this.isActive = true,
  });

  // Convert Worker to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'job_type': jobType,
      'daily_wage': dailyWage,
      'join_date': joinDate,
      'photo_path': photoPath,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Create Worker from Map
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      jobType: map['job_type'] as String,
      dailyWage: (map['daily_wage'] as num).toDouble(),
      joinDate: map['join_date'] as String,
      photoPath: map['photo_path'] as String?,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  // Copy with method for updates
  Worker copyWith({
    int? id,
    String? name,
    String? phone,
    String? jobType,
    double? dailyWage,
    String? joinDate,
    String? photoPath,
    bool? isActive,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      jobType: jobType ?? this.jobType,
      dailyWage: dailyWage ?? this.dailyWage,
      joinDate: joinDate ?? this.joinDate,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Worker{id: $id, name: $name, jobType: $jobType, dailyWage: $dailyWage}';
  }
}
