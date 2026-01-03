import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/home_body.dart';
import 'package:pockect_pilot/view/add_body.dart';
import 'package:pockect_pilot/view/add_income_body.dart';
import 'package:pockect_pilot/view/profile_body.dart';
import 'package:pockect_pilot/services/receipt_ocr_service.dart';

class HomePage extends StatefulWidget {
  final double currentBalance;
  final double expenses;

  const HomePage({
    super.key,
    required this.currentBalance,
    this.expenses = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isIncome = false;

  Key _addBodyKey = UniqueKey();

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning receipt...')),
    );

    final text = await ReceiptOCRService.extractText(
      File(image.path),
    );

    setState(() {
      AddBody.ocrTextCache = text;
      _addBodyKey = UniqueKey();
      _isIncome = false;
      _currentIndex = 1;
    });
  }

  void _showExpenseOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlobalColors.mainColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _option(
                icon: Icons.edit,
                text: 'Manual',
                color: GlobalColors.buttonColor,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isIncome = false;
                    _currentIndex = 1;
                  });
                },
              ),
              const SizedBox(height: 12),
              _option(
                icon: Icons.camera_alt,
                text: 'Camera',
                color: GlobalColors.buttonColor,
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlobalColors.mainColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _option(
                icon: Icons.remove_circle_outline,
                text: 'Add Expense',
                color: GlobalColors.expensesColor,
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, _showExpenseOptions);
                },
              ),
              const SizedBox(height: 12),
              _option(
                icon: Icons.add_circle_outline,
                text: 'Add Income',
                color: GlobalColors.buttonColor,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isIncome = true;
                    _currentIndex = 1;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _option({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GlobalColors.textColor2, size: 17),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: GlobalColors.textColor2,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
          child: IndexedStack(
            index: _currentIndex,
            children: [
              HomeBody(
                currentBalance: widget.currentBalance,
                expenses: widget.expenses,
              ),
              _isIncome
                  ? const AddIncomeBody()
                  : AddBody(key: _addBodyKey),
              const ProfileBody(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: GlobalColors.mainColor,
        selectedItemColor: GlobalColors.buttonColor,
        unselectedItemColor: GlobalColors.textColor,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        onTap: (index) {
          if (index == 1) {
            _showAddOptions();
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}