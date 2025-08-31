import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../donnee/models/project.dart';
import '../donnee/services/project_service.dart';

final projectProvider =
StateNotifierProvider<ProjectNotifier, List<Project>>((ref) {
  return ProjectNotifier(ProjectService());
});

class ProjectNotifier extends StateNotifier<List<Project>> {
  final ProjectService service;
  final Box<Project> _box = Hive.box<Project>('projectsBox');

  ProjectNotifier(this.service) : super([]);

  Future<void> loadProjects() async {
    try {
      // on essaie de charger depuis API
      final projects = await service.fetchProjects();
      state = projects;

      // mettre en cache
      await _box.clear();
      await _box.addAll(projects);
    } catch (e) {
      // fallback si pas de connexion
      state = _box.values.toList();
    }
  }

  Future<void> addProject(Project p) async {
    try {
      final created = await service.createProject(p);
      state = [...state, created];
      await _box.add(created);
    } catch (_) {
      // offline : stocke temporairement
      state = [...state, p];
      await _box.add(p);
    }
  }

  Future<void> updateProject(Project p) async {
    try {
      final updated = await service.updateProject(p);
      state = state.map((e) => e.id == p.id ? updated : e).toList();
      await _saveAllToCache();
    } catch (_) {
      state = state.map((e) => e.id == p.id ? p : e).toList();
      await _saveAllToCache();
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await service.deleteProject(id);
    } catch (_) {
      // si offline, on supprime quand même du cache
    }
    state = state.where((e) => e.id != id).toList();
    await _saveAllToCache();
  }

  Future<void> _saveAllToCache() async {
    await _box.clear();
    await _box.addAll(state);
  }
}