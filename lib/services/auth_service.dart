import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // Register with phone + PIN + location
  Future<Map<String, dynamic>> register({
    required String phone,
    required String pin,
    required String name,
    required String role,
    String location = '',
    String district = '',
  }) async {
    try {
      // Check if phone already exists
      final existing = await _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return {'success': false, 'message': 'Phone number already registered'};
      }

      final userId = _uuid.v4();
      final hashedPin = _hashPin(pin);

      final user = UserModel(
        id: userId,
        phone: phone,
        name: name,
        role: role,
        location: location,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(userId).set({
        ...user.toMap(),
        'pinHash': hashedPin,
        'district': district,
      });

      // If caregiver, create caregiver profile with location pre-filled
      if (role == 'caregiver') {
        await _db.collection('caregivers').doc(userId).set({
          'userId': userId,
          'name': name,
          'phone': phone,
          'bio': '',
          'location': location,
          'district': district,
          'hourlyRate': 0,
          'experienceYears': 0,
          'specializations': [],
          'availability': [],
          'rating': 0.0,
          'reviewCount': 0,
          'isVerified': false,
          'isAvailable': true,
          'age': 0,
          'gender': '',
        });
      }

      await _saveSession(userId, role, name, phone, location);
      return {'success': true, 'userId': userId, 'role': role};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login with phone + PIN
  Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
  }) async {
    try {
      final result = await _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        return {'success': false, 'message': 'Phone number not found'};
      }

      final doc = result.docs.first;
      final data = doc.data();
      final storedHash = data['pinHash'] ?? '';
      final inputHash = _hashPin(pin);

      if (storedHash != inputHash) {
        return {'success': false, 'message': 'Incorrect PIN'};
      }
      final role = data['role'] ?? 'parent';
      final name = data['name'] ?? '';
      await _saveSession(doc.id, role, name, phone);

      return {'success': true, 'userId': doc.id, 'role': role};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<void> _saveSession(
      String userId, String role, String name, String phone,
      [String location = '']) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('location', location);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'role': prefs.getString('role'),
      'name': prefs.getString('name'),
      'phone': prefs.getString('phone'),
    };
  }
}
