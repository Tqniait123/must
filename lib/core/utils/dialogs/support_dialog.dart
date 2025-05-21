import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showSupportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'عندك مشكلة؟',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.r),
            ),
            SizedBox(height: 8.h),
            Text(
              'كلمنا علي',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.r),
            ),
            SizedBox(height: 16.h),
            _buildSupportOption(
              context,
              icon: Icons.phone,
              iconColor: Colors.green,
              title: 'واتساب',
              onTap: () {
                // Handle WhatsApp action
              },
            ),
            SizedBox(height: 12.h),
            _buildSupportOption(
              context,
              icon: Icons.facebook,
              iconColor: Colors.blue,
              title: 'فيسبوك',
              onTap: () {
                // Handle Facebook action
              },
            ),
            SizedBox(height: 12.h),
            _buildSupportOption(
              context,
              icon: Icons.phone,
              iconColor: Colors.grey,
              title: 'مكالمة',
              onTap: () {
                // Handle Call action
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'إغلاق',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSupportOption(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 24.r),
          SizedBox(width: 16.w),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.r),
          ),
        ],
      ),
    ),
  );
}
