import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.isVerified,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, email, isVerified, createdAt];

  factory User.fromJson(Map<String, dynamic> json) {
    // Print the received JSON for debugging
    print('User.fromJson received: $json');
    
    // Handle various possible field names and formats
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    } else if (json['user_id'] != null) {
      id = json['user_id'].toString();
    } else {
      // Generate a fallback ID if none provided
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    // Handle email field
    String email = '';
    if (json['email'] != null) {
      email = json['email'].toString();
    } else {
      email = 'user@example.com';
    }
    
    // Handle is_verified field with different possible names
    bool isVerified = false;
    if (json['is_verified'] != null) {
      isVerified = json['is_verified'] as bool;
    } else if (json['verified'] != null) {
      isVerified = json['verified'] as bool;
    } else if (json['isVerified'] != null) {
      isVerified = json['isVerified'] as bool;
    }
    
    // Handle created_at field with different possible formats
    DateTime createdAt = DateTime.now();
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at'].toString());
      } else if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } else if (json['creation_date'] != null) {
        createdAt = DateTime.parse(json['creation_date'].toString());
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    
    return User(
      id: id,
      email: email,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 