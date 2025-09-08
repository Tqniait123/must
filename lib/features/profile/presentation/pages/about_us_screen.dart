import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/html_extension.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/profile/data/models/about_us_model.dart';
import 'package:must_invest/features/profile/presentation/cubit/pages_cubit.dart';
import 'package:must_invest/features/profile/presentation/cubit/pages_state.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  final String? language;

  const AboutUsScreen({super.key, this.language});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with TickerProviderStateMixin {
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

    // Load about us with language parameter
    PagesCubit.get(context).getAboutUs(lang: widget.language);
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
                  final htmlContent = state.data as AboutUsModel;
                  _fadeController.forward();
                  return _buildAboutContent(htmlContent.content);
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
                  child: LogoWidget(size: 60),
                  // child: const Icon(Icons.privacy_tip_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.about_us.tr(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.learn_more_about_us.tr(),
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
            LocaleKeys.loading_about_us.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.please_wait_loading_about_us.tr(),
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
            LocaleKeys.failed_to_load_about_us.tr(),
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
            onPressed: () => PagesCubit.get(context).getAboutUs(lang: widget.language),
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
            child: Icon(Icons.info_outline_rounded, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.no_about_us_available.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.no_about_us_available_description.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // This is now much simpler thanks to the extension!
  Widget _buildAboutContent(String htmlContent) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: htmlContent.toHtml(
          context: context,
          config: HtmlConfig(
            backgroundColor: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            padding: const EdgeInsets.all(20),
            fontSize: 16,
            lineHeight: 1.6,
            onLinkTap: _launchUrl,
            showDebugLogs: true, // Set to false in production
          ),
        ),
      ),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
