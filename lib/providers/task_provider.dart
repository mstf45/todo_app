import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;
  bool _showCompletedOnly = false;
  String _searchQuery = '';

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskCategory? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool get showCompletedOnly => _showCompletedOnly;

  // İstatistikler
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get incompleteTasks => _tasks.where((t) => !t.isCompleted).length;
  double get completionRate =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  // Kategoriye göre görev sayısı
  Map<TaskCategory, int> get tasksByCategory {
    final map = <TaskCategory, int>{};
    for (var category in TaskCategory.values) {
      map[category] = _tasks.where((t) => t.category == category).length;
    }
    return map;
  }

  // Önceliğe göre görev sayısı
  Map<TaskPriority, int> get tasksByPriority {
    final map = <TaskPriority, int>{};
    for (var priority in TaskPriority.values) {
      map[priority] = _tasks
          .where((t) => t.priority == priority && !t.isCompleted)
          .length;
    }
    return map;
  }

  // Görevleri yükle
  void loadTasks(String userId) {
    _taskService
        .getUserTasks(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _applyFilters();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Görevler yüklenirken hata: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Yeni görev ekle
  Future<bool> addTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.addTask(task);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Görevi güncelle
  Future<bool> updateTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.updateTask(task);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Görevi sil
  Future<bool> deleteTask(String taskId, String userId) async {
    _setLoading(true);
    try {
      await _taskService.deleteTask(taskId, userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Görevi tamamla/tamamlama
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      await _taskService.toggleTaskCompletion(task);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Kategori filtresi
  void filterByCategory(TaskCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Öncelik filtresi
  void filterByPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  // Tamamlanmış görevleri göster/gizle
  void toggleShowCompleted() {
    _showCompletedOnly = !_showCompletedOnly;
    _applyFilters();
    notifyListeners();
  }

  // Arama
  void searchTasks(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filtreleri uygula
  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      // Kategori filtresi
      if (_selectedCategory != null && task.category != _selectedCategory) {
        return false;
      }

      // Öncelik filtresi
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // Tamamlanma durumu filtresi
      if (_showCompletedOnly && !task.isCompleted) {
        return false;
      }

      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final titleMatch = task.title.toLowerCase().contains(_searchQuery);
        final descMatch = task.description.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !descMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Filtreleri temizle
  void clearFilters() {
    _selectedCategory = null;
    _selectedPriority = null;
    _showCompletedOnly = false;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Yükleme durumu
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Hata mesajı
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Bugünün görevlerini getir
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return dueDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Yaklaşan görevler (7 gün içinde)
  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(weekFromNow);
    }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  // Gecikmiş görevler
  List<Task> get overdueTasks {
    final now = DateTime.now();

    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }
}
