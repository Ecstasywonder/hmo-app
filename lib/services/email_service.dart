import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:universal_html/html.dart' as html;

class EmailService {
  static Future<void> sendCredentials({
    required String recipientEmail,
    required String recipientName,
    required String enrolleeNumber,
    required String password,
  }) async {
    if (kIsWeb) {
      // Web implementation using mailto
      final emailContent = '''
Subject: Welcome to CareLink HMO - Your Login Credentials

Dear $recipientName,

Your account has been successfully created. Here are your login credentials:

Enrollee Number: $enrolleeNumber
Password: $password

For security reasons, please change your password after your first login.

Best regards,
The CareLink HMO Team
''';
      
      final mailtoLink = 'mailto:$recipientEmail?subject=${Uri.encodeComponent('Welcome to CareLink HMO - Your Login Credentials')}&body=${Uri.encodeComponent(emailContent)}';
      html.window.location.href = mailtoLink;
      
    } else {
      // Native platform implementation using SMTP
      final smtpServer = gmail(
        'ecstasywonder93@gmail.com',
        'Repympresident',
      );

      final message = Message()
        ..from = const Address('ecstasywonder93@gmail.com', 'CareLink HMO')
        ..recipients.add(recipientEmail)
        ..subject = 'Welcome to CareLink HMO - Your Login Credentials'
        ..html = '''
          <h2>Welcome to CareLink HMO!</h2>
          <p>Dear $recipientName,</p>
          <p>Your account has been successfully created. Here are your login credentials:</p>
          <p><strong>Enrollee Number:</strong> $enrolleeNumber</p>
          <p><strong>Password:</strong> $password</p>
          <p>For security reasons, please change your password after your first login.</p>
          <p>You can log in to your account at <a href="https://carelink-hmo.com">carelink-hmo.com</a></p>
          <p>If you have any questions, please don't hesitate to contact our support team.</p>
          <br>
          <p>Best regards,</p>
          <p>The CareLink HMO Team</p>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        print('Email sent: ${sendReport.toString()}');
      } catch (e) {
        print('Error sending email: $e');
        rethrow;
      }
    }
  }
} 