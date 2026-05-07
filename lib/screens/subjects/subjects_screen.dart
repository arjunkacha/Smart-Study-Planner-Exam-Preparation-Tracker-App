import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../models/subject_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/subject_card.dart';
import '../../widgets/common_widgets.dart';

/// Screen listing all subjects
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/subjects/add'),
            tooltip: 'Add Subject',
          ),
        ],
      ),
      body: subjects.isEmpty
          ? EmptyStateWidget(
              icon: Icons.library_books_outlined,
              title: 'No Subjects Yet',
              subtitle: 'Add your first subject to get started with planning',
              actionLabel: 'Add Subject',
              onAction: () => context.push('/subjects/add'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: subjects.map((subject) {
                final subjectTopics =
                    topics.where((t) => t.subjectId == subject.id).toList();
                return SubjectCard(
                  subject: subject,
                  topics: subjectTopics,
                  onTap: () => context.push('/subjects/${subject.id}'),
                  onEdit: () => context.push('/subjects/edit/${subject.id}'),
                  onDelete: () => _confirmDelete(context, ref, subject),
                  animationDelay: subjects.indexOf(subject) * 80,
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subjects/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, SubjectModel subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Subject?'),
        content: Text(
            'Are you sure you want to delete "${subject.name}"? All associated topics and sessions will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              ref.read(subjectProvider.notifier).deleteSubject(subject.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subject.name} deleted'),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Screen for adding/editing a subject
class AddEditSubjectScreen extends ConsumerStatefulWidget {
  final String? subjectId;

  const AddEditSubjectScreen({super.key, this.subjectId});

  @override
  ConsumerState<AddEditSubjectScreen> createState() =>
      _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends ConsumerState<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedColorValue = AppTheme.subjectColors.first.value;
  String _selectedIconName = 'book';
  bool _isLoading = false;

  SubjectModel? get _existingSubject =>
      widget.subjectId != null
          ? ref.read(subjectProvider).cast<SubjectModel?>().firstWhere(
              (s) => s?.id == widget.subjectId,
              orElse: () => null)
          : null;

  @override
  void initState() {
    super.initState();
    final existing = _existingSubject;
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedColorValue = existing.colorValue;
      _selectedIconName = existing.iconName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subjectId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(_selectedColorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Color(_selectedColorValue).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(_selectedColorValue).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppConstants.getIconData(_selectedIconName),
                          color: Color(_selectedColorValue),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : 'Subject Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(_selectedColorValue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                const Text('Subject Name',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Mathematics, Physics...',
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Color picker
                const Text('Subject Color',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: AppTheme.subjectColors.map((color) {
                    final isSelected = color.value == _selectedColorValue;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorValue = color.value),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Icon picker
                const Text('Subject Icon',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.subjectIcons.map((iconMap) {
                    final name = iconMap['name'] as String;
                    final icon = iconMap['icon'] as IconData;
                    final isSelected = name == _selectedIconName;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIconName = name),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue).withOpacity(0.15)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Color(_selectedColorValue),
                                  width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : AppTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Update Subject' : 'Add Subject'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.subjectId != null) {
        final existing = _existingSubject;
        if (existing != null) {
          await ref.read(subjectProvider.notifier).updateSubject(
                existing.copyWith(
                  name: _nameController.text.trim(),
                  colorValue: _selectedColorValue,
                  iconName: _selectedIconName,
                ),
              );
        }
      } else {
        await ref.read(subjectProvider.notifier).addSubject(
              name: _nameController.text.trim(),
              colorValue: _selectedColorValue,
              iconName: _selectedIconName,
            );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.subjectId != null
                ? 'Subject updated successfully'
                : 'Subject added successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
