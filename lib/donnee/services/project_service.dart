import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../models/project.dart';

class ProjectService {
  late final String baseUrl;

  ProjectService() {
    // 🌍 Détection de la plateforme
    if (kIsWeb) {
      // Web → localhost direct
      baseUrl = "http://localhost:3000/projects";
    } else if (Platform.isAndroid) {
      // Android Emulator → localhost = 10.0.2.2
      baseUrl = "http://10.0.2.2:3000/projects";
    } else if (Platform.isIOS) {
      // iOS Simulator → localhost direct
      baseUrl = "http://localhost:3000/projects";
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop → localhost direct
      baseUrl = "http://localhost:3000/projects";
    } else {
      // fallback (exemple: device physique Android/iOS sur réseau local)
      baseUrl = "http://192.168.1.100:3000/projects"; // adapte ton IP locale
    }

    debugPrint("API baseUrl utilisé : $baseUrl");
  }

  Future<List<Project>> fetchProjects() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Project.fromJson(e)).toList();
    } else {
      throw Exception("Erreur API: ${res.statusCode}");
    }
  }

  Future<Project> createProject(Project p) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Project.fromJson(jsonDecode(res.body));
    }
    throw Exception("Impossible de créer le projet");
  }

  Future<Project> updateProject(Project p) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${p.id}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (res.statusCode == 200) {
      return Project.fromJson(jsonDecode(res.body));
    }
    throw Exception("Impossible de mettre à jour le projet");
  }

  Future<void> deleteProject(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Impossible de supprimer le projet");
    }
  }
}