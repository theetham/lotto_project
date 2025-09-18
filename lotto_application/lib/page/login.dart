import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_application/model/request/customer_login_post_req.dart';
import 'package:lotto_application/pageadmin/homepage_admin.dart';
import 'package:lotto_application/pageuser/home_page.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    void register() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    }

    final phoneCtl = TextEditingController();
    final passCtl = TextEditingController();

    Future<void> login() async {
      final req = CustomerLoginPostRequest(
        phone: phoneCtl.text,
        password: passCtl.text,
      );

      var url = Uri.parse("http://192.168.100.106:3000/login"); // API endpoint
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: customerLoginPostRequestToJson(req),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["success"]) {
          String role = data["user"]["role"]; // ดึง role จาก API

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("เข้าสู่ระบบสำเร็จ ✅")));
          if (role == "customer") {
            //pushReplacement จะเป็นการลบ stack ก่อนทำให้กดย้อนไปหน้าก่อนไม่ได้ เหมือน push ธรรมดา
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage_admin()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "เข้าสู่ระบบไม่สำเร็จ ❌"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ ❌")),
        );
      }
    }

    //   return Scaffold(
    //     appBar: AppBar(title: const Text('Login Page')),
    //     body: SingleChildScrollView(
    //       child: Padding(
    //         padding: EdgeInsets.all(16.0),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Image.asset('assets/images/logo.png'),

    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: 30),
    //               child: TextField(
    //                 controller: phoneCtl,
    //                 decoration: InputDecoration(
    //                   hintText: 'กรอกเบอร์โทร',
    //                   filled: true,
    //                   fillColor: Colors.white,
    //                   contentPadding: EdgeInsets.symmetric(
    //                     vertical: 14,
    //                     horizontal: 20,
    //                   ),
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.circular(30),
    //                     borderSide: BorderSide.none,
    //                   ),
    //                 ),
    //               ),
    //             ),

    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 30),
    //               child: TextField(
    //                 controller: passCtl,
    //                 obscureText: true,
    //                 decoration: InputDecoration(
    //                   hintText: 'กรอกรหัสผ่าน',
    //                   filled: true,
    //                   fillColor: Colors.white,
    //                   contentPadding: const EdgeInsets.symmetric(
    //                     vertical: 14,
    //                     horizontal: 20,
    //                   ),
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.circular(30),
    //                     borderSide: BorderSide.none,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.only(right: 40),
    //               child: Align(
    //                 alignment: Alignment.centerRight,
    //                 child: TextButton(
    //                   onPressed: () {},
    //                   child: const Text(
    //                     'ลืมรหัสผ่าน',
    //                     style: TextStyle(color: Color(0xFF4AA3A1)),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Column(
    //               children: [
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Padding(
    //                       padding: EdgeInsets.all(8.0),
    //                       child: TextButton(
    //                         onPressed: register,
    //                         child: Text('ลงทะเบียน'),
    //                       ),
    //                     ),
    //                     Padding(
    //                       padding: EdgeInsets.all(8.0),
    //                       child: FilledButton(
    //                         onPressed: login,

    //                         child: Text('เข้าสู่ระบบ'),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //             //Text(text, style: const TextStyle(fontSize: 20)),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xFF4AA3A1), // สีเขียวเข้ม
              child: const Center(
                child: Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Image.asset(
              'assets/images/lotto_logo.png',
              width: 200,
              height: 200,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: TextField(
                controller: phoneCtl,
                decoration: InputDecoration(
                  hintText: 'กรอกชื่อผู้ใช้',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: TextField(
                controller: passCtl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'กรอกรหัสผ่าน',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4AA3A1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: login,
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(0),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'ลืมรหัสผ่าน',
                    style: TextStyle(color: Color(0xFF4AA3A1)),
                  ),
                ),
              ),
            ),

            // ลิงก์สมัครสมาชิก
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("หากยังไม่มีข้อมูลยังไม่เป็นสมาชิก "),
                TextButton(
                  onPressed: register,
                  child: Text(
                    "ลงทะเบียน",
                    style: TextStyle(color: Color(0xFF4AA3A1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
