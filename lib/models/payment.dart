class Payment {
  final int? id;
  final int workerId;
  final double amount;
  final String paymentDate;
  final PaymentType paymentType;
  final String? note;

  Payment({
    this.id,
    required this.workerId,
    required this.amount,
    required this.paymentDate,
    required this.paymentType,
    this.note,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_type': paymentType.toString().split('.').last,
      'note': note,
    };
  }

  // Create from Map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      workerId: map['worker_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: map['payment_date'] as String,
      paymentType: _typeFromString(map['payment_type'] as String),
      note: map['note'] as String?,
    );
  }

  static PaymentType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return PaymentType.cash;
      case 'advance':
        return PaymentType.advance;
      default:
        return PaymentType.cash;
    }
  }

  Payment copyWith({
    int? id,
    int? workerId,
    double? amount,
    String? paymentDate,
    PaymentType? paymentType,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentType: paymentType ?? this.paymentType,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'Payment{id: $id, workerId: $workerId, amount: $amount, type: $paymentType}';
  }
}

enum PaymentType { cash, advance }
