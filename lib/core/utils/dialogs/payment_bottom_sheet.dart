import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/auth/data/models/payment_request_model.dart';

void showPaymentRequestBottomSheet({
  required BuildContext context,
  required PaymentRequestModel request,
  required Function() onApprove,
  required Function(String reason) onReject,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => PaymentRequestBottomSheet(
          request: request,
          onApprove: onApprove,
          onReject: onReject,
        ),
  );
}

class PaymentRequestBottomSheet extends StatefulWidget {
  final PaymentRequestModel request;
  final Function() onApprove;
  final Function(String reason) onReject;

  const PaymentRequestBottomSheet({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PaymentRequestBottomSheet> createState() =>
      _PaymentRequestBottomSheetState();
}

class _PaymentRequestBottomSheetState extends State<PaymentRequestBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController reasonController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _showRejectField = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _slideAnimation.value * 0.1,
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black26],
                ),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.darkBlue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.payment,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "طلب دفع جديد",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      widget.request.requesterName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                // Amount Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.darkBlue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF667eea,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "المبلغ المطلوب",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${widget.request.amount.toStringAsFixed(2)} جنيه",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "يعادل ${widget.request.pointsEquivalent} نقطة",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Details Cards
                                _buildDetailCard(
                                  icon: Icons.local_parking_rounded,
                                  title: "الموقف",
                                  value: widget.request.parkingName,
                                  color: Colors.orange,
                                ),

                                const SizedBox(height: 16),

                                _buildDetailCard(
                                  icon: Icons.location_on_rounded,
                                  title: "الموقع",
                                  value: widget.request.location,
                                  color: Colors.green,
                                ),

                                const SizedBox(height: 32),

                                // Reject Field (if shown)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: _showRejectField ? null : 0,
                                  child:
                                      _showRejectField
                                          ? Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller: reasonController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "اكتب سبب الرفض (اختياري)",
                                                    hintStyle: TextStyle(
                                                      color:
                                                          Colors.red.shade400,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    prefixIcon: Icon(
                                                      Icons.edit_rounded,
                                                      color:
                                                          Colors.red.shade400,
                                                    ),
                                                  ),
                                                  maxLines: 3,
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          )
                                          : null,
                                ),

                                // Action Buttons
                                Row(
                                  children: [
                                    // Approve Button
                                    Expanded(
                                      child: _buildActionButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.onApprove();
                                        },
                                        icon: Icons.check_circle_rounded,
                                        label: "موافق",
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.green,
                                            Colors.lightGreen,
                                          ],
                                        ),
                                        shadowColor: Colors.green,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Reject Button
                                    Expanded(
                                      child: _buildActionButton(
                                        onPressed: () {
                                          if (_showRejectField) {
                                            Navigator.pop(context);
                                            widget.onReject(
                                              reasonController.text.trim(),
                                            );
                                          } else {
                                            setState(() {
                                              _showRejectField = true;
                                            });
                                          }
                                        },
                                        icon:
                                            _showRejectField
                                                ? Icons.close_rounded
                                                : Icons.cancel_rounded,
                                        label: _showRejectField ? "رفض" : "رفض",
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.red,
                                            Colors.redAccent,
                                          ],
                                        ),
                                        shadowColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
