import 'package:flutter/material.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

void showAccountActivationBottomSheet({
  required BuildContext context,
  required Function() onCompleteProfile,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (context) =>
            AccountActivationBottomSheet(onCompleteProfile: onCompleteProfile),
  );
}

class AccountActivationBottomSheet extends StatelessWidget {
  final Function() onCompleteProfile;

  const AccountActivationBottomSheet({
    super.key,
    required this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Text(
            "حسابك غير مفعل بعد!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            "أكمل بياناتك الشخصية لتفعيل حسابك والاستمتاع بجميع المميزات",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Complete Data Button
          CustomElevatedButton(
            title: "اكمل البيانات",
            onPressed: onCompleteProfile,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Example usage
void showExampleAccountActivation(BuildContext context) {
  showAccountActivationBottomSheet(
    context: context,
    onCompleteProfile: () {
      print("Navigate to profile completion screen");
      // Navigate to complete data screen
      // Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfileScreen()));
    },
  );
}
