import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'İş';
      case TaskCategory.personal:
        return 'Kişisel';
      case TaskCategory.shopping:
        return 'Alışveriş';
      case TaskCategory.health:
        return 'Sağlık';
      case TaskCategory.other:
        return 'Diğer';
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.shopping:
        return Colors.orange;
      case TaskCategory.health:
        return Colors.green;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Düşük';
      case TaskPriority.medium:
        return 'Orta';
      case TaskPriority.high:
        return 'Yüksek';
      case TaskPriority.urgent:
        return 'Acil';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel İstatistikler
            Text(
              'Genel Bakış',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Toplam Görev',
                    taskProvider.totalTasks.toString(),
                    Icons.list_alt,
                    Colors.blue,
                  ).animate().slideX(begin: -0.2, delay: 100.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Tamamlanan',
                    taskProvider.completedTasks.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ).animate().slideX(begin: 0.2, delay: 100.ms),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Aktif Görev',
                    taskProvider.incompleteTasks.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ).animate().slideX(begin: -0.2, delay: 200.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Tamamlanma',
                    '${taskProvider.completionRate.toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.purple,
                  ).animate().slideX(begin: 0.2, delay: 200.ms),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Kategoriye Göre Dağılım
            Text(
              'Kategoriye Göre Dağılım',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            if (taskProvider.totalTasks > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getCategorySections(taskProvider),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(delay: 400.ms)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Henüz görev yok',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            // Kategori Legendleri
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: TaskCategory.values.map((category) {
                final count = taskProvider.tasksByCategory[category] ?? 0;
                return _buildLegendItem(
                  _getCategoryName(category),
                  count,
                  _getCategoryColor(category),
                );
              }).toList(),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            // Önceliğe Göre Dağılım
            Text(
              'Önceliğe Göre Aktif Görevler',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 16),

            if (taskProvider.incompleteTasks > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: TaskPriority.values.map((priority) {
                      final count = taskProvider.tasksByPriority[priority] ?? 0;
                      final percentage = taskProvider.incompleteTasks > 0
                          ? (count / taskProvider.incompleteTasks) * 100
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getPriorityName(priority),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$count görev (${percentage.toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                _getPriorityColor(priority),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ).animate().slideY(begin: 0.2, delay: 700.ms)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Aktif görev yok',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 32),

            // Yaklaşan Görevler
            Text(
              'Yaklaşan Görevler (7 gün)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(
                      context,
                      'Bugün',
                      taskProvider.todayTasks.length.toString(),
                      Icons.today,
                      Colors.blue,
                    ),
                    _buildQuickStat(
                      context,
                      'Yaklaşan',
                      taskProvider.upcomingTasks.length.toString(),
                      Icons.upcoming,
                      Colors.orange,
                    ),
                    _buildQuickStat(
                      context,
                      'Gecikmiş',
                      taskProvider.overdueTasks.length.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ).animate().scale(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections(TaskProvider provider) {
    return TaskCategory.values.map((category) {
      final count = provider.tasksByCategory[category] ?? 0;
      final percentage = provider.totalTasks > 0
          ? (count / provider.totalTasks) * 100
          : 0.0;

      return PieChartSectionData(
        value: count.toDouble(),
        title: count > 0 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: _getCategoryColor(category),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label ($count)'),
      ],
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
