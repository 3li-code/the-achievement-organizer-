// lib/screens/project_task_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_achievement_organizer/models/project.dart';
import '../providers/time_entry_provider.dart';

class ProjectTaskManagementScreen extends StatefulWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  State<ProjectTaskManagementScreen> createState() =>
      _ProjectTaskManagementScreenState();
}

class _ProjectTaskManagementScreenState
    extends State<ProjectTaskManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddItemDialog(BuildContext context, TimeEntryProvider provider) {
    final textController = TextEditingController();
    final bool isProjectTab = _tabController.index == 0;
    final String title = isProjectTab ? 'Add a new project' : 'Add a new Task';
    final String label = isProjectTab ? 'project name' : ' Task name';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(labelText: label),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final name = textController.text;
                if (name.isNotEmpty) {
                  if (isProjectTab) {
                    provider.addProject(name);
                  } else {
                    provider.addTask(name);
                  }
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    TimeEntryProvider provider,
    dynamic item,
  ) {
    final textController = TextEditingController();
    textController.text = item.name;

    final bool isProject = item is Project;
    final String title = isProject ? 'Edit Project ' : 'Edit Task';
    final String label = isProject ? 'project name ' : 'task name ';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(labelText: label),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Edit save'),
              onPressed: () {
                final name = textController.text;
                if (name.isNotEmpty) {
                  if (isProject) {
                    provider.editProject(item.id, name);
                  } else {
                    provider.editTask(item.id, name);
                  }
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects and Tasks'),
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'projects',
              icon: Icon(Icons.business_center, color: Colors.white),
            ),
            Tab(
              text: 'tasks',
              icon: Icon(Icons.task_alt, color: Colors.white),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManagementList(context, isProjectList: true),
          _buildManagementList(context, isProjectList: false),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 20),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: Text(
                    _tabController.index == 0
                        ? 'ADD NEW PROJECT'
                        : 'ADD NEW TASK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => _showAddItemDialog(context, provider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementList(
    BuildContext context, {
    required bool isProjectList,
  }) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        final List<dynamic> items = isProjectList
            ? provider.projects
            : provider.tasks;

        if (items.isEmpty) {
          return Center(
            child: Text(
              'Not Found  ${isProjectList ? 'Projects' : 'Tasks'}. Add one !',
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                if (isProjectList) {
                  provider.deleteProject(item.id);
                } else {
                  provider.deleteTask(item.id);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted  "${item.name}"')),
                );
              },
              child: ListTile(
                title: Text(item.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _showEditItemDialog(context, provider, item);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
