import 'package:flutter/material.dart';

import 'buy_lotto_page.dart';
import 'purchased_page.dart';
import 'result_page.dart';
import 'wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // สมมติ userId ของสมาชิก (แทนที่จะส่ง walletAmount)
  final int userId = 7;

  final List<Widget> _pages = [
    const BuyLottoPage(),
    const PurchasedPage(),
    ResultPage(purchasedNumbers: const []),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'ซื้อหวย'
              : _selectedIndex == 1
                  ? 'หวยที่ซื้อแล้ว'
                  : 'ผลล็อตโต้',
        ),
        backgroundColor: Colors.teal,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        // เปลี่ยนให้กดที่ยอดเงินเปิด WalletPage พร้อม userId
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalletPage(userId: userId), // ส่ง userId แทน walletAmount
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
              // แสดงข้อความ loading หรือค่าเริ่มต้น (ถ้าอยากให้แสดงยอดเงินในนี้ด้วยจริงๆ ต้องดึงข้อมูล API ก่อน)
              label: const Text(
                '... ฿',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'ซื้อ'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'ซื้อแล้ว'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'ผล'),
        ],
      ),
    );
  }
}
