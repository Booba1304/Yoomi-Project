import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../donnee/models/project.dart';

class ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectTile({
    super.key,
    required this.project,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(project.name),
        subtitle: Text(
            "${project.amount} FCFA • ${project.status.name.toUpperCase()}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat.yMd().format(project.createdAt)),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}