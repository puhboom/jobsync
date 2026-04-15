import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/error_view.dart';
import 'bloc/resumes_bloc.dart';
import 'bloc/resumes_event.dart';
import 'bloc/resumes_state.dart';

class ResumesScreen extends StatefulWidget {
  const ResumesScreen({super.key});

  @override
  State<ResumesScreen> createState() => _ResumesScreenState();
}

class _ResumesScreenState extends State<ResumesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load resumes on init
    context.read<ResumesBloc>().add(const ResumesLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Examples'),
            Tab(text: 'Templates'),
            Tab(text: 'Generated'),
          ],
        ),
      ),
      body: BlocConsumer<ResumesBloc, ResumesState>(
        listener: (context, state) {
          if (state is ResumeUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ResumeExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exported to: ${state.filePath}'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ResumesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ResumesLoading) {
            return const LoadingIndicator();
          }

          if (state is ResumesError) {
            return ErrorView(
              message: state.message,
              actionText: 'Retry',
              onAction: () {
                context.read<ResumesBloc>().add(const ResumesLoadRequested());
              },
            );
          }

          if (state is ResumesLoaded ||
              state is ResumeUploadSuccess ||
              state is ResumeGenerated ||
              state is ResumeExportSuccess) {
            final exampleResumes = state is ResumesLoaded
                ? state.exampleResumes
                : state is ResumeUploadSuccess
                    ? state.exampleResumes
                    : state is ResumeGenerated
                        ? state.exampleResumes
                        : state is ResumeExportSuccess
                            ? state.exampleResumes
                            : [];

            final templates = state is ResumesLoaded
                ? state.templates
                : state is ResumeUploadSuccess
                    ? state.templates
                    : state is ResumeGenerated
                        ? state.templates
                        : state is ResumeExportSuccess
                            ? state.templates
                            : [];

            final generatedResumes = state is ResumesLoaded
                ? state.generatedResumes
                : state is ResumeUploadSuccess
                    ? state.generatedResumes
                    : state is ResumeGenerated
                        ? state.generatedResumes
                        : state is ResumeExportSuccess
                            ? state.generatedResumes
                            : [];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildResumeList(
                  exampleResumes,
                  'example',
                  'No example resumes uploaded yet.\nUpload resumes to use as content reference for AI generation.',
                ),
                _buildResumeList(
                  templates,
                  'template',
                  'No templates uploaded yet.\nUpload DOCX templates for resume formatting.',
                ),
                _buildGeneratedList(generatedResumes),
              ],
            );
          }

          return const LoadingIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResumeList(
    List resumes,
    String fileType,
    String emptyMessage,
  ) {
    if (resumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resumes.length,
      itemBuilder: (context, index) {
        final resume = resumes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              fileType == 'example' ? Icons.article : Icons.description,
              color: AppColors.primary,
            ),
            title: Text(resume.filename),
            subtitle: Text(
              'Uploaded: ${_formatDate(resume.createdAt)}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context, resume.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratedList(List resumes) {
    if (resumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No generated resumes yet.\nGenerate resumes from job applications.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resumes.length,
      itemBuilder: (context, index) {
        final resume = resumes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
            ),
            title: Text('Resume for Job #${resume.jobId}'),
            subtitle: Text(
              'Generated: ${_formatDate(resume.createdAt)}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => _viewResume(context, resume.content),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: AppColors.accent),
                  onPressed: () {
                    context.read<ResumesBloc>().add(
                          ResumesExportRequested(
                            generatedResumeId: resume.id,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Upload Example Resume'),
            subtitle: const Text('Used for AI content reference'),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUpload('example');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Upload Template'),
            subtitle: const Text('DOCX format for resume formatting'),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUpload('template');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Google Drive'),
            subtitle: const Text('Coming soon'),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.cloud_circle),
            title: const Text('OneDrive'),
            subtitle: const Text('Coming soon'),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(String fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: fileType == 'template' ? ['docx'] : ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        if (!mounted) return;
        context.read<ResumesBloc>().add(
              ResumesUploadRequested(
                filePath: file.path!,
                fileType: fileType,
              ),
            );
      }
    }
  }

  void _confirmDelete(BuildContext context, String resumeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text('Are you sure you want to delete this resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ResumesBloc>().add(
                    ResumesDeleteRequested(id: resumeId),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _viewResume(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generated Resume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: SelectableText(content),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
