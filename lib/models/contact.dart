class Contact {
  int? id;
  String name;
  String? phoneNumber;
  String? email;
  String? postalCode;
  String? address;
  String? company;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.postalCode,
    this.address,
    this.company,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // データベースからマップを作成するコンストラクタ
  Contact.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        phoneNumber = map['phone_number'],
        email = map['email'],
        postalCode = map['postal_code'],
        address = map['address'],
        company = map['company'],
        notes = map['notes'],
        createdAt = DateTime.parse(map['created_at']),
        updatedAt = DateTime.parse(map['updated_at']);

  // データベースに保存するためのマップに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'postal_code': postalCode,
      'address': address,
      'company': company,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 更新時に使用するマップ（IDを除く）
  Map<String, dynamic> toMapForUpdate() {
    final map = toMap();
    map.remove('id');
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  // コピーを作成（更新時に使用）
  Contact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? postalCode,
    String? address,
    String? company,
    String? notes,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phoneNumber: $phoneNumber, email: $email, postalCode: $postalCode, address: $address, company: $company, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}