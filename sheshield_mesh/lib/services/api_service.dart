import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../models/mesh_message.dart';
import 'api_config.dart';

class ApiService {
  static final String _baseUrl = getApiBaseUrl();

  // Fetch full system state (activeAlert, contacts, history)
  static Future<Map<String, dynamic>> fetchState() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/sos/state'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print("ApiService.fetchState failed: $e");
    }
    return {};
  }

  // Create active alert on backend
  static Future<bool> createAlert(AlertModel alert) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sos/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(alert.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.createAlert failed: $e");
      return false;
    }
  }

  // Update active alert status / relays on backend
  static Future<bool> updateAlert(Map<String, dynamic> updates) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sos/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.updateAlert failed: $e");
      return false;
    }
  }

  // Clear/dismiss active alert on backend
  static Future<bool> clearActiveAlert() async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/api/sos/clear'));
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.clearActiveAlert failed: $e");
      return false;
    }
  }

  // Add trusted contact on backend
  static Future<bool> addContact(ContactModel contact) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/contacts/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(contact.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.addContact failed: $e");
      return false;
    }
  }

  // Update trusted contact on backend
  static Future<bool> updateContact(ContactModel contact) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/contacts/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(contact.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.updateContact failed: $e");
      return false;
    }
  }

  // Delete trusted contact on backend
  static Future<bool> deleteContact(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/api/contacts/delete/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print("ApiService.deleteContact failed: $e");
      return false;
    }
  }

  // Send location from Relay to backend
  static Future<bool> sendLocation(MeshMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/mesh/location'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService.sendLocation failed: $e');
      return false;
    }
  }

  // Trigger fallback via webhook (WhatsApp automation)
  static Future<bool> triggerFallback() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/webhook/fallback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService.triggerFallback failed: $e');
      return false;
    }
  }

}
