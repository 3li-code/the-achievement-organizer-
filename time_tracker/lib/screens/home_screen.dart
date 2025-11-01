import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/add_time_entry_screen.dart';
import '../screens/project_task_management_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/time_entry_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Time Monitor'),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),

              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const ProjectTaskManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          body: Consumer<TimeEntryProvider>(
            builder: (context, provider, child) {
              final groupedEntries = provider.groupedEntries;

              if (groupedEntries.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Text(
                        'No time entries yet. Add a new entry!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final projects = groupedEntries.keys.toList();

              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (ctx, index) {
                  final project = projects[index];
                  final entries = groupedEntries[project]!;

                  final totalProjectTime = entries.fold(
                    Duration.zero,
                    (prev, entry) => prev + entry.totalTime,
                  );

                  return ExpansionTile(
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Total Time: ${_formatDuration(totalProjectTime)}',
                    ),
                    initiallyExpanded: true,
                    children: entries.map((entry) {
                      return Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          provider.deleteEntry(entry.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Done Deleted !')),
                          );
                        },
                        child: ListTile(
                          title: Text(entry.task.name),
                          subtitle: Text(
                            '${DateFormat.yMd().format(entry.date)} - ${entry.notes}',
                          ),
                          trailing: Text(
                            _formatDuration(entry.totalTime),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
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
                          const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(
                        'ADD TIME ENTRY',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const AddTimeEntryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
