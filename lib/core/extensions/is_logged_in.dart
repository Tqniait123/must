import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';

extension UserCubitX on BuildContext {
  UserCubit get userCubit => UserCubit.get(this);

  bool get isLoggedIn => userCubit.isLoggedIn();
  bool get isVerified => user.verified ?? false;
  void setCurrentUser(User user) => userCubit.setCurrentUser(user);
  void updateUserPoints(int points) => userCubit.updateUserPoints(points);
  User get user => UserCubit.get(this).currentUser!;

  /// Checks user verification and guest status, executes function if verified and logged in
  /// Otherwise shows appropriate bottom sheet
  void checkVerifiedAndGuestOrDo(VoidCallback onVerifiedAction) {
    if (!isLoggedIn) {
      _showGuestModeBottomSheet();
    } else if (isVerified) {
      _showNotVerifiedBottomSheet();
    } else {
      onVerifiedAction();
    }
  }

  void _showGuestModeBottomSheet() {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GuestModeBottomSheet(),
    );
  }

  void _showNotVerifiedBottomSheet() {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotVerifiedBottomSheet(),
    );
  }
}

class GuestModeBottomSheet extends StatelessWidget {
  const GuestModeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: Icon(Icons.person_outline, size: 40, color: Colors.blue[600]),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            LocaleKeys.guestModeTitle.tr(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            LocaleKeys.guestModeDescription.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to login/register screen
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LocaleKeys.signIn.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class NotVerifiedBottomSheet extends StatelessWidget {
  const NotVerifiedBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          // Icon and Title Row
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                child: Icon(Icons.verified_user_outlined, size: 30, color: Colors.orange[600]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.accountNotVerified.tr(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LocaleKeys.verifyAccountSubtitle.tr(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Steps Title
          Text(
            LocaleKeys.verificationSteps.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          // Verification Steps
          _buildVerificationStep(context, 1, Icons.credit_card, LocaleKeys.uploadNationalIdFront.tr()),
          const SizedBox(height: 12),
          _buildVerificationStep(context, 2, Icons.credit_card, LocaleKeys.uploadNationalIdBack.tr()),
          const SizedBox(height: 12),
          _buildVerificationStep(context, 3, Icons.drive_eta, LocaleKeys.uploadDrivingLicenseFront.tr()),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LocaleKeys.later.tr(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to edit profile screen
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LocaleKeys.verifyNow.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(BuildContext context, int stepNumber, IconData icon, String title) {
    return Row(
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(color: Colors.orange[700], fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Icon
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),

        // Step title
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
