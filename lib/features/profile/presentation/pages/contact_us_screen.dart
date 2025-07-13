import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/profile/data/models/contact_us_model.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  final String? language;

  const ContactUsScreen({super.key, this.language});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = FadeTransition(opacity: _fadeController, child: Container()).opacity;

    _scrollController.addListener(_scrollListener);

    // Load contact us data with language parameter
    PagesCubit.get(context).getContactUs(lang: widget.language);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200) {
      if (!_showBackToTopButton) {
        setState(() {
          _showBackToTopButton = true;
        });
      }
    } else {
      if (_showBackToTopButton) {
        setState(() {
          _showBackToTopButton = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: BlocBuilder<PagesCubit, PagesState>(
              builder: (context, state) {
                if (state is PagesLoading) {
                  return _buildLoadingWidget();
                } else if (state is PagesError) {
                  return _buildErrorWidget(state.message);
                } else if (state is PagesSuccess) {
                  final contactData = state.data as ContactUsModel;
                  _fadeController.forward();
                  return _buildContactContent(contactData);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.contact_support_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.contact_us.tr(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.get_in_touch_with_us.tr(),
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.loading_contact_info.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.please_wait_loading_contact_info.tr(),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.failed_to_load_contact_info.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => PagesCubit.get(context).getContactUs(lang: widget.language),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(LocaleKeys.try_again.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.contact_support_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.no_contact_info_available.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.no_contact_info_available_description.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactContent(ContactUsModel contactData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone Card
            _buildContactCard(
              icon: Icons.phone_rounded,
              title: LocaleKeys.phone_number.tr(),
              content: contactData.phone,
              subtitle: LocaleKeys.tap_to_call.tr(),
              onTap: () => _makePhoneCall(contactData.phone),
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Email Card
            _buildContactCard(
              icon: Icons.email_rounded,
              title: LocaleKeys.email_address.tr(),
              content: contactData.email,
              subtitle: LocaleKeys.tap_to_email.tr(),
              onTap: () => _sendEmail(contactData.email),
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Address Card
            _buildContactCard(
              icon: Icons.location_on_rounded,
              title: LocaleKeys.address.tr(),
              content: contactData.address,
              subtitle: LocaleKeys.tap_to_view_map.tr(),
              onTap: () => _openMap(contactData.address),
              color: Colors.orange,
            ),
            const SizedBox(height: 32),

            // Additional Actions
            // _buildAdditionalActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: color.withOpacity(0.05),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon Container with subtle shadow
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with subtle uppercase
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Main Content
                    Text(
                      content,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900], height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    // Subtitle with accent color
                    Text(subtitle, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // Arrow icon with animation
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.quick_actions.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.copy_rounded,
                    label: LocaleKeys.copy_info.tr(),
                    onPressed: _copyContactInfo,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share_rounded,
                    label: LocaleKeys.share.tr(),
                    onPressed: _shareContactInfo,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _scrollToTop,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.keyboard_arrow_up_rounded),
      label: Text(LocaleKeys.back_to_top.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar(LocaleKeys.cannot_make_call.tr());
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email, query: 'subject=${LocaleKeys.contact_inquiry.tr()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar(LocaleKeys.cannot_send_email.tr());
    }
  }

  Future<void> _openMap(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(LocaleKeys.cannot_open_map.tr());
    }
  }

  void _copyContactInfo() {
    final contactData = context.read<PagesCubit>().state;
    if (contactData is PagesSuccess) {
      final data = contactData.data as ContactUsModel;
      final String info = '''${LocaleKeys.contact_information.tr()}:
${LocaleKeys.phone_number.tr()}: ${data.phone}
${LocaleKeys.email_address.tr()}: ${data.email}
${LocaleKeys.address.tr()}: ${data.address}''';

      Clipboard.setData(ClipboardData(text: info));
      _showSnackBar(LocaleKeys.contact_info_copied.tr());
    }
  }

  void _shareContactInfo() {
    final contactData = context.read<PagesCubit>().state;
    if (contactData is PagesSuccess) {
      final data = contactData.data as ContactUsModel;
      final String info = '''${LocaleKeys.contact_information.tr()}:
${LocaleKeys.phone_number.tr()}: ${data.phone}
${LocaleKeys.email_address.tr()}: ${data.email}
${LocaleKeys.address.tr()}: ${data.address}''';

      // Note: You'll need to add share_plus package if not already added
      // Share.share(info, subject: LocaleKeys.contact_us.tr());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
