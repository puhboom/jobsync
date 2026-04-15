import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_model.dart';
import 'bloc/jobs_bloc.dart';
import 'bloc/jobs_event.dart';
import 'bloc/jobs_state.dart';

class JobFormScreen extends StatefulWidget {
  final JobModel? job;

  const JobFormScreen({super.key, this.job});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _salaryController;
  late TextEditingController _descriptionController;
  late TextEditingController _requirementsController;
  late TextEditingController _keywordsController;
  late JobStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _companyController = TextEditingController(text: job?.company ?? '');
    _positionController = TextEditingController(text: job?.position ?? '');
    _locationController = TextEditingController(text: job?.location ?? '');
    _salaryController = TextEditingController(text: job?.salary ?? '');
    _descriptionController =
        TextEditingController(text: job?.description ?? '');
    _requirementsController =
        TextEditingController(text: job?.requirements.join(', ') ?? '');
    _keywordsController =
        TextEditingController(text: job?.keywords.join(', ') ?? '');
    _selectedStatus = job?.status ?? JobStatus.saved;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.job == null
                  ? 'Job added successfully'
                  : 'Job updated successfully'),
            ),
          );
          Navigator.pop(context);
        } else if (state is JobsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.job == null ? 'Add Job' : 'Edit Job'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JobStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: JobStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(
                    labelText: 'Requirements (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _keywordsController,
                  decoration: const InputDecoration(
                    labelText: 'Keywords (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<JobsBloc, JobsState>(
                  builder: (context, state) {
                    final isLoading = state is JobsLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.job == null ? 'Add Job' : 'Save Changes'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final requirements = _requirementsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final keywords = _keywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = {
        'company': _companyController.text,
        'position': _positionController.text,
        'location':
            _locationController.text.isEmpty ? null : _locationController.text,
        'salary':
            _salaryController.text.isEmpty ? null : _salaryController.text,
        'status': _selectedStatus.name,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'requirements': requirements,
        'keywords': keywords,
      };

      if (widget.job != null) {
        context.read<JobsBloc>().add(
              JobsUpdateRequested(
                id: widget.job!.id,
                data: data,
              ),
            );
      } else {
        context.read<JobsBloc>().add(
              JobsCreateRequested(data: data),
            );
      }
    }
  }
}
