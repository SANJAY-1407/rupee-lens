import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;

  const PieChartWidget({
    super.key,
    required this.data,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int touchedIndex = -1;

  final List<Color> chartColors = [
    const Color(0xFF4F7CFF),
    const Color(0xFF22C55E),
    const Color(0xFFFF9F43),
    const Color(0xFFFF5C7A),
    const Color(0xFF9B6DFF),
    const Color(0xFF14B8A6),
    const Color(0xFFEC4899),
    const Color(0xFF8B7355),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return "🍔";
      case "shopping":
        return "🛍️";
      case "travel":
        return "✈️";
      case "entertainment":
        return "🎬";
      case "medical":
        return "💊";
      case "bills":
        return "💡";
      default:
        return "💰";
    }
  }

  String formatAmount(double amount) {
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    }

    if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(1)}K";
    }

    return "₹${amount.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    final entries = widget.data.entries.toList();

    final double total = widget.data.values.fold<double>(
      0,
          (sum, value) => sum + value,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue = Curves.easeOutCubic.transform(
          _controller.value,
        );

        return Column(
          children: [
            _buildChartCard(
              context,
              entries,
              total,
              animationValue,
            ),
            const SizedBox(height: 18),
            _buildLegend(
              context,
              entries,
              total,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(
      BuildContext context,
      List<MapEntry<String, double>> entries,
      double total,
      double animationValue,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    final double chartSize = width < 380 ? 220 : 255;

    final selectedEntry =
    touchedIndex >= 0 && touchedIndex < entries.length
        ? entries[touchedIndex]
        : null;

    final selectedPercentage = selectedEntry == null || total == 0
        ? 0.0
        : (selectedEntry.value / total) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF18201D),
            const Color(0xFF101513),
          ]
              : [
            const Color(0xFFFFFFFF),
            const Color(0xFFF5FAF7),
          ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.07,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Color(0xFF22C55E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spending Overview",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${entries.length} categories",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (touchedIndex >= 0)
                IconButton(
                  onPressed: () {
                    setState(() {
                      touchedIndex = -1;
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                  tooltip: "Clear selection",
                ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: chartSize,
            height: chartSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: chartSize * 0.29,
                    sectionsSpace: 3,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() {
                            touchedIndex = -1;
                          });
                          return;
                        }

                        setState(() {
                          touchedIndex = response!
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(
                      entries.length,
                          (index) {
                        final entry = entries[index];

                        final isSelected = touchedIndex == index;

                        final radius =
                            (chartSize * 0.28) *
                                (isSelected ? 1.12 : 1.0) *
                                animationValue;

                        return PieChartSectionData(
                          value: entry.value,
                          color: chartColors[
                          index % chartColors.length],
                          radius: radius,
                          showTitle: false,
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.9),
                            width: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  swapAnimationDuration:
                  const Duration(milliseconds: 450),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),

                IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.85,
                            end: 1,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: selectedEntry == null
                        ? Column(
                      key: const ValueKey("total"),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "TOTAL SPENT",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatAmount(total),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${entries.length} categories",
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                        : Column(
                      key: ValueKey(selectedEntry.key),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getEmoji(selectedEntry.key),
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          selectedEntry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatAmount(selectedEntry.value),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                        Text(
                          "${selectedPercentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              selectedEntry == null
                  ? "Tap a category to explore"
                  : "Tap another category to compare",
              key: ValueKey(selectedEntry?.key ?? "hint"),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
      BuildContext context,
      List<MapEntry<String, double>> entries,
      double total,
      ) {
    return Column(
      children: List.generate(
        entries.length,
            (index) {
          final entry = entries[index];

          final percentage =
          total == 0 ? 0.0 : (entry.value / total) * 100;

          final isSelected = touchedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TweenAnimationBuilder<double>(
              duration: Duration(
                milliseconds: 500 + (index * 70),
              ),
              curve: Curves.easeOutCubic,
              tween: Tween(
                begin: 0,
                end: 1,
              ),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      12 * (1 - value),
                    ),
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    touchedIndex = isSelected ? -1 : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isSelected
                        ? chartColors[index % chartColors.length]
                        .withValues(alpha: 0.12)
                        : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    border: Border.all(
                      color: isSelected
                          ? chartColors[
                      index % chartColors.length]
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        width: isSelected ? 15 : 12,
                        height: isSelected ? 15 : 12,
                        decoration: BoxDecoration(
                          color: chartColors[
                          index % chartColors.length],
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: chartColors[
                              index %
                                  chartColors.length]
                                  .withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ]
                              : null,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Text(
                        getEmoji(entry.key),
                        style: const TextStyle(
                          fontSize: 21,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${percentage.toStringAsFixed(1)}% of total",
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${entry.value.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            isSelected
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 17,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E)
                  .withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              size: 34,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Expense Data",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            "Add some expenses to see your spending breakdown.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}