import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyLottoPage extends StatefulWidget {
  const BuyLottoPage({super.key});

  @override
  State<BuyLottoPage> createState() => _BuyLottoPageState();
}

class _BuyLottoPageState extends State<BuyLottoPage> {
  List<String> lottoNumbers = []; // List to hold fetched lotto numbers
  late List<bool> selected; // To keep track of selected lotto numbers
  String searchQuery = ""; // For search query
  Timer? _debounce; // Timer for debouncing search
  bool isLoading = false; // To show loading indicator
  String? errorMessage; // To display error messages

  @override
  void initState() {
    super.initState();
    selected = List.filled(lottoNumbers.length, false);
    fetchLottoNumbers(); // Fetch lotto numbers when the page loads
  }

  // Fetch the lotto numbers from the API
  Future<void> fetchLottoNumbers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.106:3000/api/lotto/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          lottoNumbers = data.map<String>((item) => item['number'].toString()).toList();
          selected = List.filled(lottoNumbers.length, false); // Reset the selection
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "เกิดข้อผิดพลาด: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "ไม่สามารถเชื่อมต่อกับ API ได้";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter lotto numbers based on the search query
    final filteredLottoNumbers = lottoNumbers
        .where((number) => number.contains(searchQuery))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "เลือกเลขที่ต้องการซื้อ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (query) {
              // Cancel the previous debounce if it's still active
              if (_debounce?.isActive ?? false) _debounce!.cancel();

              // Set a new debounce timer
              _debounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  searchQuery = query; // Update search query after debounce
                });
              });
            },
            decoration: InputDecoration(
              labelText: "ค้นหาหมายเลข",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        // Show error message if any
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        // Show loading indicator while fetching data
        if (isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        // If no results found after filtering
        else if (filteredLottoNumbers.isEmpty)
          const Expanded(child: Center(child: Text("ไม่พบหมายเลขที่ค้นหา")))
        // Show the list of lotto numbers
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredLottoNumbers.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(filteredLottoNumbers[index], style: const TextStyle(fontSize: 18)),
                    trailing: Checkbox(
                      value: selected[lottoNumbers.indexOf(filteredLottoNumbers[index])],
                      activeColor: Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          selected[lottoNumbers.indexOf(filteredLottoNumbers[index])] = value!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Example: Show the number of selected lotto tickets
              final countSelected = selected.where((e) => e).length;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("เลือกซื้อ $countSelected ใบ")),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text("ซื้อที่เลือกไว้", style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Cancel the debounce timer when the widget is disposed
    _debounce?.cancel();
    super.dispose();
  }
}
