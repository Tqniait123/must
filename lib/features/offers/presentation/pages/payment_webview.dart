import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';

class PaymentWebview extends StatefulWidget {
  final String url;

  const PaymentWebview({super.key, required this.url});

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  String? _lastVisitedUrl;
  DateTime? _lastVisitTime;

  @override
  Widget build(BuildContext context) {
    void handleBackAction(bool success) {
      final now = DateTime.now();
      if (_lastVisitedUrl == widget.url &&
          _lastVisitTime != null &&
          now.difference(_lastVisitTime!).inMilliseconds < 1000) {
        return;
      }
      _lastVisitedUrl = widget.url;
      _lastVisitTime = now;
      context.pop(success);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  "${widget.url}?mobile=true&lang=${context.locale.toString()}",
                ), // Load the initial checkout URL
              ),
              onLoadStop: (controller, url) async {
                // Triggered when page loading stops
                // log("Page loaded, current URL: $url");

                if (url.toString().contains("status=success")) {
                  // // Handle success redirect
                  // log("Payment Successful");
                  handleBackAction(true);
                } else if (url.toString().contains("status=failed")) {
                  handleBackAction(false);
                  // // Handle failure redirect
                  // log("Payment Failed");
                }
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                // Triggered when the URL is changed
                // log("Redirect detected: $url");

                if (url.toString().contains("status=success")) {
                  // Handle success redirect
                  // log("Payment Successful");
                  handleBackAction(true);
                } else if (url.toString().contains("status=failed")) {
                  handleBackAction(false);
                  // Handle failure redirect
                  // log("Payment Failed");
                }
              },
            ),
            const PositionedDirectional(start: 20, top: 20, child: CustomBackButton()),
          ],
        ),
      ),
    );
  }
}
