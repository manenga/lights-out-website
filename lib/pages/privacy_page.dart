import 'package:flutter/material.dart';
import '../widgets/app_layout.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        title: 'Privacy Policy',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This privacy policy applies to the Lights Out And Away We Go app (hereby referred to as "Application") for mobile devices that was created by MoodyTech PTY (LTD) (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".',
                ),
                const SizedBox(height: 32),
                Text(
                  '1. Information We Collect',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Application does not obtain any information when you download and use it. Registration is not required to use the Application.',
                ),
                const SizedBox(height: 32),
                Text(
                  '2. How We Use Your Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text('We use the information we collect to:'),
                const SizedBox(height: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Provide and maintain our services'),
                    Text('• Send notifications about races'),
                    Text('• Improve our services'),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  '3. Does the Application collect precise real time location information of the device?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This Application does not collect precise information about the location of your mobile device.',
                ),
                const SizedBox(height: 32),
                Text(
                  '4. Do third parties see and/or have access to information obtained by the Application?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Since the Application does not collect any information, no data is shared with third parties.',
                ),
                const SizedBox(height: 32),
                Text(
                  '5. What are my opt-out rights?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.',
                ),
                const SizedBox(height: 32),
                Text(
                  '6. Children',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Application is not used to knowingly solicit data from or market to children under the age of 13.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'The Service Provider does not knowingly collect personally identifiable information from children. The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services. The Service Provider encourages parents and legal guardians to monitor their children\'s Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to the Service Provider through the Application and/or Services, please contact the Service Provider (manengam@gmail.com) so that they will be able to take the necessary actions. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf).',
                ),
                const SizedBox(height: 32),
                Text(
                  '7. Security',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Service Provider is concerned about safeguarding the confidentiality of your information. However, since the Application does not collect any information, there is no risk of your data being accessed by unauthorized individuals.',
                ),
                const SizedBox(height: 32),
                Text(
                  '8. Changes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to their Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.',
                ),
                const SizedBox(height: 32),
                Text(
                  'This privacy policy is effective as of 19-10-2024.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Text(
                  '9. Your Consent',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by the Service Provider.',
                ),
                const SizedBox(height: 32),
                Text(
                  '10. Contact Us',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at info@moodytech.co.za.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ));
  }
}
