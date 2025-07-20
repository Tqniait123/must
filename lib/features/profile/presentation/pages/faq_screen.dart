import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/profile/data/models/faq_model.dart';
import 'package:must_invest/features/profile/presentation/cubit/pages_cubit.dart';
import 'package:must_invest/features/profile/presentation/cubit/pages_state.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<FAQModel> _filteredFaqs = [];
  List<FAQModel> _allFaqs = [];
  bool _isSearching = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = FadeTransition(opacity: _fadeController, child: Container()).opacity;

    PagesCubit.get(context).getFaq();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = _allFaqs;
      } else {
        _filteredFaqs =
            _allFaqs
                .where((faq) => faq.question.toLowerCase().contains(query) || faq.answer.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(
            child: BlocBuilder<PagesCubit, PagesState>(
              builder: (context, state) {
                if (state is PagesLoading) {
                  return _buildLoadingWidget();
                } else if (state is PagesError) {
                  return _buildErrorWidget(state.message);
                } else if (state is PagesSuccess) {
                  _allFaqs = state.data as List<FAQModel>;
                  if (_filteredFaqs.isEmpty && _searchController.text.isEmpty) {
                    _filteredFaqs = _allFaqs;
                  }
                  _fadeController.forward();
                  return _buildFAQList(_filteredFaqs);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
                  child: const Icon(Icons.help_center_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.frequently_asked_questions.tr(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.find_answers_to_common_questions.tr(),
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
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearching ? 80 : 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: LocaleKeys.search_faqs.tr(),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      height: 400,
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
            LocaleKeys.loading_faqs.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(LocaleKeys.please_wait_while_fetching.tr(), style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
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
            LocaleKeys.oops_something_went_wrong.tr(),
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
            onPressed: () => PagesCubit.get(context).getFaq(),
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
      height: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.help_outline_rounded, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.no_faqs_found.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            _searchController.text.isNotEmpty
                ? LocaleKeys.no_faqs_match_search.tr()
                : LocaleKeys.no_faqs_available_at_moment.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList(List<FAQModel> faqs) {
    if (faqs.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          PagesCubit.get(context).getFaq();
        },
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: _buildFAQItem(faqs[index], index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQModel faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.quiz_rounded, color: Theme.of(context).primaryColor, size: 20),
          ),
          title: Text(
            faq.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
          ),
          iconColor: Theme.of(context).primaryColor,
          collapsedIconColor: Colors.grey[400],
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(faq.answer, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Scroll to top
        Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.keyboard_arrow_up_rounded),
      label: Text(LocaleKeys.back_to_top.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
