import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../etat/project_notifier.dart';
import '../widgets/project_tile.dart';
import 'project_form_screen.dart';
import '../../donnee/models/project.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  String _searchQuery = '';
  ProjectStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(projectProvider.notifier).loadProjects());
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectProvider);

    // --- Filtrage et recherche ---
    final filteredProjects = projects.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == null || p.status == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        actions: [
          // Recherche
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String>(
                context: context,
                delegate: ProjectSearchDelegate(initialQuery: _searchQuery),
              );
              if (query != null) {
                setState(() => _searchQuery = query);
              }
            },
          ),
          //  Filtre status
          PopupMenuButton<ProjectStatus?>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (status) {
              setState(() => _filterStatus = status);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: null,
                child: Text("Tous"),
              ),
              ...ProjectStatus.values.map(
                    (s) => PopupMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: filteredProjects.isEmpty
          ? const Center(child: Text("Aucun element trouvé"))
          : ListView.builder(
        itemCount: filteredProjects.length,
        itemBuilder: (ctx, i) {
          final project = filteredProjects[i];
          return ProjectTile(
            project: project,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(project: project),
                ),
              );
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Supprimer ?"),
                  content: Text("Supprimer  ${project.name} ?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Annuler")),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Supprimer")),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(projectProvider.notifier)
                    .deleteProject(project.id);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProjectSearchDelegate extends SearchDelegate<String> {
  ProjectSearchDelegate({String initialQuery = ''}) {
    query = initialQuery;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Tape l'element a rechercher..."));
  }
}
