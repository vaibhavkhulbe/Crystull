import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

TabBar getTabBar(List<String> tabs, TabController _tabController,
    int _cachedFromIdx, int _cachedToIdx) {
  return TabBar(
    tabs: tabs
        .asMap()
        .entries
        .map(
          (entry) => AnimatedBuilder(
            animation: _tabController.animation as Listenable,
            builder: (ctx, snapshot) {
              final forward = _tabController.offset > 0;
              final backward = _tabController.offset < 0;
              int _fromIndex;
              int _toIndex;
              double progress;

              // This value is true during the [animateTo] animation that's triggered when the user taps a [TabBar] tab.
              // It is false when [offset] is changing as a consequence of the user dragging the [TabBarView].
              if (_tabController.indexIsChanging) {
                _fromIndex = _tabController.previousIndex;
                _toIndex = _tabController.index;
                _cachedFromIdx = _tabController.previousIndex;
                _cachedToIdx = _tabController.index;
                progress =
                    (_tabController.animation!.value - _fromIndex).abs() /
                        (_toIndex - _fromIndex).abs();
              } else {
                if (_cachedFromIdx == _tabController.previousIndex &&
                    _cachedToIdx == _tabController.index) {
                  // When user tap on a tab bar and the animation is completed, it will execute this block
                  // This block will not be called when user draging the TabBarView
                  _fromIndex = _cachedFromIdx;
                  _toIndex = _cachedToIdx;
                  progress = 1;
                  _cachedToIdx = 0;
                  _cachedFromIdx = 0;
                } else {
                  _cachedToIdx = 0;
                  _cachedFromIdx = 0;
                  _fromIndex = _tabController.index;
                  _toIndex = forward
                      ? _fromIndex + 1
                      : backward
                          ? _fromIndex - 1
                          : _fromIndex;
                  progress =
                      (_tabController.animation!.value - _fromIndex).abs();
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: entry.key == _fromIndex
                      ? Color.lerp(const Color(0xFFE7F7FF),
                          const Color(0xFFF4F4F4), progress)
                      : entry.key == _toIndex
                          ? Color.lerp(const Color(0xFFF4F4F4),
                              const Color(0xFFE7F7FF), progress)
                          : Color.lerp(const Color(0xFFF4F4F4),
                              const Color(0xFFF4F4F4), progress),
                  borderRadius: BorderRadius.circular(56),
                ),
                child: Text(entry.value.toString(),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    )),
              );
            },
          ),
        )
        .toList(),
    controller: _tabController,
    isScrollable: true,
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorWeight: 0,
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(56),
    ),
    physics: const ClampingScrollPhysics(),
    unselectedLabelColor: color808080,
    labelColor: const Color(0xFF42C2FF),
  );
}
