import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_chip_widget.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline;
      case TaskCategory.personal:
        return Icons.person_outline;
      case TaskCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TaskCategory.health:
        return Icons.favorite_outline;
      case TaskCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevlerim'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Arama
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Görev ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              taskProvider.searchTasks('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    taskProvider.searchTasks(value);
                  },
                ).animate().fadeIn(),

                const SizedBox(height: 12),

                // Kategori Filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: 'Tümü',
                        isSelected: taskProvider.selectedCategory == null,
                        onSelected: (_) => taskProvider.filterByCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...TaskCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChipWidget(
                            label: _getCategoryName(category),
                            icon: _getCategoryIcon(category),
                            isSelected:
                                taskProvider.selectedCategory == category,
                            onSelected: (_) =>
                                taskProvider.filterByCategory(category),
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, delay: 100.ms),

                const SizedBox(height: 8),

                // Öncelik ve Durum Filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: taskProvider.showCompletedOnly
                            ? 'Tamamlananlar'
                            : 'Tümü',
                        icon: taskProvider.showCompletedOnly
                            ? Icons.check_circle
                            : Icons.list,
                        isSelected: taskProvider.showCompletedOnly,
                        onSelected: (_) => taskProvider.toggleShowCompleted(),
                      ),
                      const SizedBox(width: 8),
                      ...TaskPriority.values.map((priority) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChipWidget(
                            label: _getPriorityName(priority),
                            isSelected:
                                taskProvider.selectedPriority == priority,
                            onSelected: (_) =>
                                taskProvider.filterByPriority(priority),
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().slideX(begin: -0.1, delay: 200.ms),
              ],
            ),
          ),

          // İstatistik Kartları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Toplam',
                    taskProvider.totalTasks.toString(),
                    Icons.list_alt,
                    Colors.blue,
                  ).animate().scale(delay: 300.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Aktif',
                    taskProvider.incompleteTasks.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ).animate().scale(delay: 400.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Tamamlanan',
                    taskProvider.completedTasks.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ).animate().scale(delay: 500.ms),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Görev Listesi
          Expanded(
            child: taskProvider.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz görev yok',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yeni bir görev eklemek için + butonuna tıklayın',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ).animate().fadeIn(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(task: task),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 50 * index),
                      );
                    },
                  ),
          ),
        ],
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
        ),
      ),
    );
  }
}
