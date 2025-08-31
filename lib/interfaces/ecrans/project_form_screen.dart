import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../donnee/models/project.dart';
import '../../etat/project_notifier.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  ProjectStatus _status = ProjectStatus.draft;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _amountController =
        TextEditingController(text: widget.project?.amount.toString() ?? '');
    _status = widget.project?.status ?? ProjectStatus.draft;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newProject = Project(
      id: widget.project?.id ?? '',
      name: _nameController.text.trim(),
      status: _status,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );

    final notifier = ref.read(projectProvider.notifier);

    if (widget.project == null) {
      await notifier.addProject(newProject);
    } else {
      await notifier.updateProject(newProject);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier un projet" : "Nouveau projet"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom du projet"),
                validator: (v) => v == null || v.isEmpty ? "Nom requis" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                items: ProjectStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: "Statut"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Montant"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Montant requis";
                  if (double.tryParse(v) == null) return "Montant invalide";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? "Mettre à jour" : "Créer"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
