import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static Future<void> sendCredentials({
    required String recipientEmail,
    required String recipientName,
    required String enrolleeNumber,
    required String password,
  }) async {
    if (kIsWeb) {
      // Web implementation using EmailJS
      const serviceId = 'YOUR_EMAILJS_SERVICE_ID';
      const templateId = 'YOUR_EMAILJS_TEMPLATE_ID';
      const userId = 'YOUR_EMAILJS_USER_ID';
      
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'to_email': recipientEmail,
              'to_name': recipientName,
              'enrollee_number': enrolleeNumber,
              'password': password,
            },
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send email: ${response.body}');
        }
        
      } catch (e) {
        print('Error sending email: $e');
        rethrow;
      }
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
          <p>Dear {{to_name}},</p>
          <p>Your account has been successfully created. Here are your login credentials:</p>
          <p><strong>Enrollee Number:</strong> {{enrollee_number}}</p>
          <p><strong>Password:</strong> {{password}}</p>
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