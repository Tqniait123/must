import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:must_invest/core/theme/colors.dart';

enum PaginationDirection { top, bottom }

enum PaginationLayoutType { list, grid }

class PaginationWidget<T> extends StatefulWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMorePages;
  final Function() loadMoreItems;
  final Function()? loadPreviousItems;
  final PaginationDirection paginationDirection;
  final PaginationLayoutType layoutType;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? loadingIndicator;
  final Widget? emptyStateWidget; // Widget to show when the list is empty
  final int gridCrossAxisCount; // Number of columns in the grid
  final double gridChildAspectRatio; // Aspect ratio of grid items

  const PaginationWidget({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMorePages,
    required this.loadMoreItems,
    this.loadPreviousItems,
    this.paginationDirection = PaginationDirection.bottom,
    this.layoutType = PaginationLayoutType.list,
    required this.itemBuilder,
    this.loadingIndicator,
    this.emptyStateWidget,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 1.0,
  });

  @override
  _PaginationWidgetState<T> createState() => _PaginationWidgetState<T>();
}

class _PaginationWidgetState<T> extends State<PaginationWidget<T>> {
  bool isRequesting = false; // Track if a request is in progress
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isBottom = _controller.position.pixels == 0;
        if (isBottom) {
          log('At the bottom');
        } else {
          log('At the top');
          if (widget.hasMorePages &&
              widget.paginationDirection == PaginationDirection.top) {
            _handlePagination(isAtBottom: false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the list is empty and return the empty state widget if it is
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyStateWidget ??
          const Center(child: Text('No items found'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!widget.isLoading && !isRequesting) {
          switch (widget.paginationDirection) {
            case PaginationDirection.bottom:
              // Pagination at the bottom
              if (widget.hasMorePages &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _handlePagination(isAtBottom: true);
              }
              break;
            case PaginationDirection.top:
              break;
          }
        }
        return false;
      },
      child:
          widget.layoutType == PaginationLayoutType.list
              ? _buildListView()
              : _buildGridView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.items.length + (widget.hasMorePages ? 1 : 0),
      controller: _controller,
      reverse: widget.paginationDirection == PaginationDirection.top,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return widget.loadingIndicator ??
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SpinKitRotatingCircle(
                  size: 15,
                  color: AppColors.primary,
                ),
              );
        }
        return widget.itemBuilder(context, widget.items[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.items.length + (widget.hasMorePages ? 1 : 0),
      controller: _controller,
      reverse: widget.paginationDirection == PaginationDirection.top,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridCrossAxisCount,
        childAspectRatio: widget.gridChildAspectRatio,
      ),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return widget.loadingIndicator ??
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SpinKitRotatingCircle(
                  size: 15,
                  color: AppColors.primary,
                ),
              );
        }
        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }

  void _handlePagination({required bool isAtBottom}) {
    setState(() {
      isRequesting = true;
    });

    if (isAtBottom) {
      widget.loadMoreItems();
    } else {
      widget.loadPreviousItems!();
    }

    Future.delayed(const Duration(seconds: 2)).then((_) {
      setState(() {
        isRequesting = false;
      });
    });
  }
}
