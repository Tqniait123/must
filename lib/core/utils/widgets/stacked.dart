import 'dart:math';

import 'package:flutter/material.dart';

class HorizontalStackedCardCarousel extends StatefulWidget {
  HorizontalStackedCardCarousel({
    super.key,
    required List<Widget> items,
    this.type = StackedCardCarouselType.cardsStack,
    this.initialOffset = 40.0,
    this.spaceBetweenItems = 200,
    this.applyTextScaleFactor = true,
    PageController? pageController,
    this.onPageChanged,
  })  : assert(items.isNotEmpty),
        _items = items,
        _pageController = pageController ?? PageController();

  final List<Widget> _items;
  final StackedCardCarouselType type;
  final double initialOffset;
  final double spaceBetweenItems;
  final bool applyTextScaleFactor;
  final PageController _pageController;
  final OnPageChanged? onPageChanged;

  @override
  _HorizontalStackedCardCarouselState createState() =>
      _HorizontalStackedCardCarouselState();
}

class _HorizontalStackedCardCarouselState
    extends State<HorizontalStackedCardCarousel> {
  double _pageValue = 0.0;

  @override
  Widget build(BuildContext context) {
    widget._pageController.addListener(() {
      if (mounted) {
        setState(() {
          _pageValue = widget._pageController.page ?? 0.0;
        });
      }
    });

    return Stack(
      children: <Widget>[
        _stackedCards(context),
        PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: widget._pageController,
          itemCount: widget._items.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (BuildContext context, int index) {
            return Container();
          },
        ),
      ],
    );
  }

  Widget _stackedCards(BuildContext context) {
    double textScaleFactor = 1.0;
    if (widget.applyTextScaleFactor) {
      final double mediaQueryFactor = MediaQuery.of(context).textScaleFactor;
      if (mediaQueryFactor > 1.0) {
        textScaleFactor = mediaQueryFactor;
      }
    }

    final List<Widget> positionedCards = widget._items.asMap().entries.map(
      (MapEntry<int, Widget> item) {
        double position = -widget.initialOffset;
        if (_pageValue < item.key) {
          position += (_pageValue - item.key) *
              widget.spaceBetweenItems *
              textScaleFactor;
        }

        switch (widget.type) {
          case StackedCardCarouselType.fadeOutStack:
            double opacity = 1.0;
            double scale = 1.0;
            if (item.key - _pageValue < 0) {
              final double factor = 1 + (item.key - _pageValue);
              opacity = factor < 0.0 ? 0.0 : pow(factor, 1.5).toDouble();
              scale = factor < 0.0 ? 0.0 : pow(factor, 0.1).toDouble();
            }
            return Positioned.fill(
              left: -position,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: item.value,
                  ),
                ),
              ),
            );
          case StackedCardCarouselType.cardsStack:
            double scale = 1.0;
            if (item.key - _pageValue < 0) {
              final double factor = 1 + (item.key - _pageValue);
              scale = 0.95 + (factor * 0.1 / 2);
            }
            return Positioned.fill(
              left: -position + (0.0 * item.key),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.scale(
                  scale: scale,
                  child: item.value,
                ),
              ),
            );
        }
      },
    ).toList();

    return Stack(
      alignment: Alignment.center,
      children: positionedCards,
    );
  }
}

enum StackedCardCarouselType {
  cardsStack,
  fadeOutStack,
}

typedef OnPageChanged = void Function(int pageIndex);
