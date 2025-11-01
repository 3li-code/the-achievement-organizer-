// lib/providers/time_entry_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class TimeEntryProvider with ChangeNotifier {
  late final SharedPreferences _prefs;

  final String _entriesKey = 'time_entries';
  final String _projectsKey = 'projects';
  final String _tasksKey = 'tasks';

  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  Map<Project, List<TimeEntry>> get groupedEntries {
    if (_projects.isEmpty) return {};
    return groupBy(_entries, (TimeEntry entry) => entry.project.id).map((
      projectId,
      entries,
    ) {
      final projectKey = _projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () {
          return Project(id: 'unknown', name: 'Deleted Project');
        },
      );
      return MapEntry(projectKey, entries);
    });
  }

  Future<void> initProvider() async {
    _prefs = await SharedPreferences.getInstance();

    // 1Download Time Entries
    final entriesString = _prefs.getString(_entriesKey);
    if (entriesString != null) {
      try {
        final List<dynamic> decodedData =
            jsonDecode(entriesString) as List<dynamic>;
        _entries = decodedData
            .map((item) => TimeEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("خطأ قراءة TimeEntries: $e");
        _entries = [];
      }
    }

    // Download project
    final projectsString = _prefs.getString(_projectsKey);
    if (projectsString != null) {
      try {
        final List<dynamic> decodedData =
            jsonDecode(projectsString) as List<dynamic>;
        _projects = decodedData
            .map((item) => Project.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Error reading Projects: $e");
        _projects = [];
      }
    }
    if (_projects.isEmpty) {
      _projects = [
        Project(id: const Uuid().v4(), name: 'Project A'),
        Project(id: const Uuid().v4(), name: 'Project B'),
      ];
      await _saveProjects();
    }

    // 3. Download Tasks
    final tasksString = _prefs.getString(_tasksKey);
    if (tasksString != null) {
      try {
        final List<dynamic> decodedData =
            jsonDecode(tasksString) as List<dynamic>;
        _tasks = decodedData
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Error reading  Tasks: $e");
        _tasks = [];
      }
    }
    if (_tasks.isEmpty) {
      _tasks = [
        Task(id: const Uuid().v4(), name: ' 1 (analysis)'),
        Task(id: const Uuid().v4(), name: ' 2 (Design)'),
      ];
      await _saveTasks();
    }

    notifyListeners();
  }

  // 5. Update Funcation Save
  Future<void> _saveEntries() async {
    final List<Map<String, dynamic>> data = _entries
        .map((entry) => entry.toJson())
        .toList();
    await _prefs.setString(_entriesKey, jsonEncode(data));
  }

  Future<void> _saveProjects() async {
    final List<Map<String, dynamic>> data = _projects
        .map((p) => p.toJson())
        .toList();
    await _prefs.setString(_projectsKey, jsonEncode(data));
  }

  Future<void> _saveTasks() async {
    final List<Map<String, dynamic>> data = _tasks
        .map((t) => t.toJson())
        .toList();
    await _prefs.setString(_tasksKey, jsonEncode(data));
  }

  // Funcation Management
  Future<void> addEntry(TimeEntry entry) async {
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> addProject(String name) async {
    final newProject = Project(id: const Uuid().v4(), name: name);
    _projects.add(newProject);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    final newTask = Task(id: const Uuid().v4(), name: name);
    _tasks.add(newTask);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> editProject(String id, String newName) async {
    try {
      final project = _projects.firstWhere((p) => p.id == id);
      project.name = newName;
      await _saveProjects();
      notifyListeners();
    } catch (e) {
      print("Error in Edit in the Project : $e");
    }
  }

  Future<void> editTask(String id, String newTaskName) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.name = newTaskName;
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      print("Error! Edit in the task : $e");
    }
  }
}
