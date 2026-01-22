import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help center screen with FAQs and support options
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency section
          _buildEmergencyCard(context),
          
          const SizedBox(height: 24),
          
          // FAQs section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFAQSection(
            title: 'Getting Started',
            faqs: [
              _FAQ(
                question: 'How do I register as a driver?',
                answer: 'Select "Driver" during registration and provide your vehicle information, driver\'s license details, and upload required documents.',
              ),
              _FAQ(
                question: 'How do I register as a company?',
                answer: 'Select "Company" during registration and provide your company details including registration number and business address.',
              ),
              _FAQ(
                question: 'How long does verification take?',
                answer: 'Document verification typically takes 24-48 hours. You\'ll receive a notification once your account is verified.',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildFAQSection(
            title: 'For Drivers',
            faqs: [
              _FAQ(
                question: 'How do I receive ride requests?',
                answer: 'Set your availability status to "Available" in your dashboard. You\'ll receive notifications for ride requests within 5km of your location.',
              ),
              _FAQ(
                question: 'How do I accept a ride?',
                answer: 'When you receive a ride request notification, tap on it to view details and tap "Accept Ride" to confirm.',
              ),
              _FAQ(
                question: 'How do I notify the company I\'ve arrived?',
                answer: 'Once you reach the pickup location, tap the "I Am Here" button in the active ride screen.',
              ),
              _FAQ(
                question: 'How do I complete a trip?',
                answer: 'After dropping off the passenger, tap the "Trip Complete" button. You\'ll then be prompted to rate the company.',
              ),
              _FAQ(
                question: 'When do I receive payment?',
                answer: 'Payments are processed automatically after trip completion. You can view your earnings in the dashboard.',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildFAQSection(
            title: 'For Companies',
            faqs: [
              _FAQ(
                question: 'How do I request a ride?',
                answer: 'Tap the "Request Ride" button, select your pickup location, and choose from available drivers within 5km.',
              ),
              _FAQ(
                question: 'How do I track my driver?',
                answer: 'Once a driver accepts your request, you\'ll see their live location on the map with real-time ETA updates.',
              ),
              _FAQ(
                question: 'Can I chat with my driver?',
                answer: 'Yes, once a ride is accepted, you can use the in-app chat feature to communicate with your driver.',
              ),
              _FAQ(
                question: 'How do I pay for rides?',
                answer: 'Add your payment method in Settings. Payment is processed automatically after trip completion.',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildFAQSection(
            title: 'Safety & Security',
            faqs: [
              _FAQ(
                question: 'What should I do in an emergency?',
                answer: 'Use the Emergency Contact button in the active ride screen to call 911. Your location will be shared with emergency services.',
              ),
              _FAQ(
                question: 'How is my data protected?',
                answer: 'We use industry-standard encryption to protect your personal information and payment details.',
              ),
              _FAQ(
                question: 'Can I report a safety concern?',
                answer: 'Yes, contact our support team immediately through the app or email support@taxidispatch.com.',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contact support section
          _buildContactSupportCard(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Colors.red.shade700, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Emergency Assistance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'If you\'re in immediate danger or need emergency assistance, use the Emergency Contact button in your active ride screen or call 911 directly.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('tel:911');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call 911'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection({
    required String title,
    required List<_FAQ> faqs,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(_FAQ faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Need more help? Our support team is here for you.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.email,
              label: 'Email Support',
              value: 'support@taxidispatch.com',
              onTap: () async {
                final url = Uri.parse('mailto:support@taxidispatch.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.phone,
              label: 'Call Support',
              value: '1-800-TAXI-HELP',
              onTap: () async {
                final url = Uri.parse('tel:18008294435');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ({
    required this.question,
    required this.answer,
  });
}
