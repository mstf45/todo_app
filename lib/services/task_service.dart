import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Task>> getUserTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Task>> getIncompleteTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Task>> getCompletedTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Task>> getTasksByCategory(String userId, TaskCategory category) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category.index)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toFirestore());
      await _updateUserStats(task.userId, increment: true);
    } catch (e) {
      throw 'Görev eklenirken hata oluştu: $e';
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(task.toFirestore());
    } catch (e) {
      throw 'Görev güncellenirken hata oluştu: $e';
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      await _updateUserStats(userId, increment: false);
    } catch (e) {
      throw 'Görev silinirken hata oluştu: $e';
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
      await _updateUserCompletionStats(
        task.userId,
        increment: !task.isCompleted,
      );
    } catch (e) {
      throw 'Görev durumu değiştirilirken hata oluştu: $e';
    }
  }

  Future<void> _updateUserStats(
    String userId, {
    required bool increment,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'totalTasks': FieldValue.increment(increment ? 1 : -1),
    });
  }

  Future<void> _updateUserCompletionStats(
    String userId, {
    required bool increment,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'completedTasks': FieldValue.increment(increment ? 1 : -1),
    });
  }

  Stream<List<Task>> getTodayTasks(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Task>> getTasksByPriority(String userId, TaskPriority priority) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('priority', isEqualTo: priority.index)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }
}
