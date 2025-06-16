import 'package:apppp1/view/RegisterView.dart';
import 'package:apppp1/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:apppp1/database/database_helper.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _generateRandomPassword(int length) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final dbHelper = DatabaseHelper.instance;
      try {
        final users = await dbHelper.getAllUsers();
        final user = users.firstWhere(
              (u) => u['email'] == email,
          orElse: () => throw Exception('Email not found'),
        );

        final newPassword = _generateRandomPassword(8);
        // Cập nhật mật khẩu thay vì chèn bản ghi mới
        await dbHelper.update(
          'users',
          {'password': newPassword},
          where: 'email = ?',
          whereArgs: [email],
        );

        // Cấu hình SMTP (thay bằng email và mật khẩu thực tế của bạn)
        String username = 'namtran.040104n@gmail.com'; // Thay bằng email của bạn
        String password = '  nuhb erev iskl zaho';
        final smtpServer = gmail(username, password);

        final message = Message()
          ..from = Address(username, 'Ứng dụng UTC2')
          ..recipients.add(email)
          ..subject = 'Khôi phục mật khẩu'
          ..text = 'Mật khẩu mới của bạn là: $newPassword\nVui lòng sử dụng để đăng nhập.';

        try {
          await send(message, smtpServer);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mật khẩu mới đã được gửi đến email của bạn')),
            );
          }
          _emailController.clear();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi gửi email: $e')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email không tồn tại hoặc lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo và tiêu đề
              Container(
                width: double.infinity,
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo.png'), // Thay bằng logo thực tế
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/logo1.png', // Thay bằng logo thực tế
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'Chào mừng trở lại',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Đăng nhập để tiếp tục',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Trường Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                    return 'Email không hợp lệ';
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Nút Gửi
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Gửi',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              // Liên kết Quên mật khẩu (tắt vì đang ở trang này)
              TextButton(
                onPressed: () {
                  // Không cần hành động vì đã ở trang quên mật khẩu
                },
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              // Liên kết Đăng ký ngay
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterView()),
                  );
                },
                child: Text(
                  'Đăng ký ngay',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                },
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}