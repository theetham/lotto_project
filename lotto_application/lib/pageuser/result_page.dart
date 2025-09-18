import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<String> purchasedNumbers; // ✅ รับเลขที่ซื้อจากหน้าก่อน

  const ResultPage({super.key, required this.purchasedNumbers});

  // Mock ผลรางวัล
  final List<Map<String, dynamic>> results = const [
    {"number": "123456", "prize": "รางวัลที่ 1", "amount": 6000000},
    {"number": "654321", "prize": "รางวัลที่ 2", "amount": 200000},
    {"number": "111222", "prize": "รางวัลที่ 3", "amount": 80000},
    {"number": "014", "prize": "รางวัลเลขท้าย 3 ตัว", "amount": 9000},
    {"number": "10", "prize": "รางวัลเลขท้าย 2 ตัว", "amount": 2000},
  ];

  // สีพื้นหลังตามรางวัล
  Color _getCardColor(String prize) {
    switch (prize) {
      case "รางวัลที่ 1":
        return Colors.amber.shade700;
      case "รางวัลที่ 2":
        return Colors.orange.shade400;
      case "รางวัลที่ 3":
        return Colors.deepOrange.shade300;
      case "รางวัลเลขท้าย 3 ตัว":
        return Colors.teal.shade300;
      case "รางวัลเลขท้าย 2 ตัว":
        return Colors.blueGrey.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  // ขนาดฟอนต์ตามรางวัล
  double _getFontSize(String prize) {
    switch (prize) {
      case "รางวัลที่ 1":
        return 22;
      case "รางวัลที่ 2":
        return 20;
      case "รางวัลที่ 3":
        return 18;
      default:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ หาผลลัพธ์ที่ผู้ใช้ถูกรางวัล
    final List<Map<String, dynamic>> matched = results
        .where((result) => purchasedNumbers.contains(result['number']))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // ✅ แสดงข้อความว่า "คุณถูกรางวัล!" ถ้ามีเลขตรง
          if (matched.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "🎉 คุณถูกรางวัล ${matched.length} รายการ!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: const [
                  Icon(Icons.sentiment_dissatisfied, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "คุณไม่ถูกรางวัลในงวดนี้",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // ✅ แสดงรายการรางวัลทั้งหมด
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                final isWin = purchasedNumbers.contains(result['number']);

                return Card(
                  color: _getCardColor(result['prize']),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(
                      result['prize'],
                      style: TextStyle(
                        fontSize: _getFontSize(result['prize']),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "เลข: ${result['number']}\nจำนวนเงิน ${result['amount']} บาท",
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (isWin)
                          const Text(
                            "🎉 คุณถูกรางวัลนี้!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                      ],
                    ),
                    leading: const Icon(Icons.stars, color: Colors.white, size: 30),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
