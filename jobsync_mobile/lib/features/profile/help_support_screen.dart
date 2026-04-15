import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        children: [
          _buildSectionHeader('FAQ'),
          ExpansionTile(
            title: const Text('How do I add a new job?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tap the + button on the Jobs tab to add a new job application. '
                  'You can enter the company name, position, and other details manually, '
                  'or paste a job description and let AI parse the details for you.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How does AI resume generation work?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Upload example resumes to use as content reference, then go to a job '
                  'application and click "Generate Resume". The AI will tailor your resume '
                  'to match the job requirements.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('What is ATS analysis?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'ATS (Applicant Tracking System) analysis checks your resume against '
                  'the job description to see how well it will score in automated screening. '
                  'It checks keyword matching, formatting, and relevance.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How does offline mode work?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'When enabled, JobSync caches your jobs locally so you can view them '
                  'without internet. Changes you make offline are queued and synced '
                  'when you reconnect.',
                ),
              ),
            ],
          ),
          const Divider(),
          _buildSectionHeader('Contact Us'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Support'),
            subtitle: const Text('support@ronning.systems'),
            onTap: () => _launchEmail('support@ronning.systems'),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a Bug'),
            subtitle: const Text('Help us improve JobSync'),
            onTap: () => _launchEmail('bugs@ronning.systems'),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Request a Feature'),
            subtitle: const Text('Suggest new features'),
            onTap: () => _launchEmail('features@ronning.systems'),
          ),
          const Divider(),
          _buildSectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () => _launchUrl('https://ronning.systems/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () => _launchUrl('https://ronning.systems/terms'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}