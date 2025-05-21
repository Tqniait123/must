import 'package:fluttertoast/fluttertoast.dart';
import 'package:must_invest/core/utils/dialogs/custom_toast.dart';

void showErrorToast(context, String message) {
  FToast fToast;

  fToast = FToast();
  fToast.init(context);

  fToast.showToast(
    isDismissible: true,
    toastDuration: const Duration(seconds: 3),
    child: CustomToast(message: message),
  );
}

void showSuccessToast(context, String message) {
  FToast fToast;

  fToast = FToast();
  fToast.init(context);

  fToast.showToast(
    isDismissible: true,
    toastDuration: const Duration(seconds: 3),
    child: SuccessToast(message: message),
  );
}

// void showCustomErrorToast(BuildContext context, String message) {
//   final overlay = Overlay.of(context);
//   final overlayEntry = OverlayEntry(
//     builder: (context) => Positioned(
//       bottom: 50.0,
//       left: 24.0,
//       right: 24.0,
//       child: CustomToast(message: message),
//     ),
//   );

//   overlay.insert(overlayEntry);

//   Future.delayed(const Duration(seconds: 3), () {
//     overlayEntry.remove();
//   });
// }
