// lib/screens/add_time_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Project? _selectedProject;
  Task? _selectedTask;
  DateTime _selectedDate = DateTime.now();
  Duration _selectedDuration = Duration.zero;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime(0)
          .add(_selectedDuration)),
      );

    if (picked != null) {
      setState(() {
        _selectedDuration = Duration(hours: picked.hour, minutes: picked.minute);
      });
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedProject == null ||
          _selectedTask == null ||
          _selectedDuration == Duration.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please Fill in The Filds')),
        );
        return;
      }

      final newEntry = TimeEntry(
        id: const Uuid().v4(),
        project: _selectedProject!,
        task: _selectedTask!,
        date: _selectedDate,
        totalTime: _selectedDuration,
        notes: _notesController.text,
      );

      Provider.of<TimeEntryProvider>(context, listen: false).addEntry(newEntry);

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours Hour و $minutes Minutes";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);
    final projects = provider.projects;
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('add New Time Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Project>(
                value: _selectedProject,
                hint: const Text('choose Project'),
                items: projects.map((project) {
                  return DropdownMenuItem<Project>(
                    value: project,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please Choose project' : null,
              ),
              const SizedBox(height: 16),

              // اختيار المهمة
              DropdownButtonFormField<Task>(
                value: _selectedTask,
                hint: const Text('choose Task'),
                items: tasks.map((task) {
                  return DropdownMenuItem<Task>(
                    value: task,
                    child: Text(task.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTask = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please! choose Task' : null,
              ),
              const SizedBox(height: 16),

              // اختيار التاريخ
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date: ${DateFormat.yMd().format(_selectedDate)}'),
                  ),
                  TextButton(
                    child: const Text('change'),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text('Time Taken: ${_formatDuration(_selectedDuration)}'),
                  ),
                  TextButton(
                    child: const Text('Change'),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveEntry,
                child: const Text('Save entry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}