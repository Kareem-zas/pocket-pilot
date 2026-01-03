import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile',
        style: TextStyle(
          color: GlobalColors.textColor2,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}