import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

const TextStyle _selectedTextStyle = TextStyle(
  color: Color(0xFF35567D),
  fontSize: 14.0,
  fontWeight: FontWeight.w600,
);

const TextStyle _normalTextStyle = TextStyle(
  color: Color(0x7F000000),
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
);

class MonthStrip extends StatefulWidget {
  final String format;
  final DateTime from;
  final DateTime to;
  final DateTime initialMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final double height;
  final double viewportFraction;
  final TextStyle selectedTextStyle;
  final TextStyle normalTextStyle;
  final ScrollPhysics? physics;

  MonthStrip({
    Key? key,
    this.format = 'MMMM yyyy',
    required this.from,
    required this.to,
    required this.initialMonth,
    required this.onMonthChanged,
    this.physics,
    this.height = 48.0,
    this.viewportFraction = 0.3,
    this.normalTextStyle = _normalTextStyle,
    this.selectedTextStyle = _selectedTextStyle,
  })  : assert(!to.isBefore(from), 'to must be after from'),
        super(key: key);

  @override
  _MonthStripState createState() => _MonthStripState();
}

class _MonthStripState extends State<MonthStrip> {
  late final List<_MonthItem> months;
  late final DateFormat dateFormat;
  late final PageController controller;
  late int _lastReportedPage;

  @override
  void initState() {
    super.initState();

    dateFormat = DateFormat(widget.format);

    months = [];

    int initialPage = 0;
    for (int i = widget.from.year; i <= widget.to.year; i++) {
      for (int j = 1; j <= 12; j++) {
        if (i == widget.from.year && j < widget.from.month) {
          continue;
        }
        if (i == widget.to.year && j > widget.to.month) {
          continue;
        }
        var item = _MonthItem(DateTime(i, j));
        if (widget.initialMonth.year == i && widget.initialMonth.month == j) {
          initialPage = months.length;
          item.selected = true;
        }
        months.add(item);
      }
    }

    controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: initialPage,
    );
    _lastReportedPage = initialPage;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = AxisDirection.right;
    final ScrollPhysics physics =
    _kPagePhysics.applyTo(widget.physics ?? const PageScrollPhysics());

    return Container(
      height: widget.height,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (ScrollEndNotification notification) {
          if (notification.depth == 0) {
            final PageMetrics metrics = notification.metrics as PageMetrics;
            final int currentPage = metrics.page!.round();

            if (currentPage != _lastReportedPage) {
              _lastReportedPage = currentPage;

              setState(() {
                for (var item in months) {
                  item.selected = false;
                }
                var m = months[currentPage];
                m.selected = true;
                widget.onMonthChanged(DateTime(m.time.year, m.time.month));
              });
            }
          }
          return false;
        },
        child: Scrollable(
          axisDirection: axisDirection,
          controller: controller,
          physics: physics,
          viewportBuilder: (BuildContext context, ViewportOffset position) {
            return Viewport(
              axisDirection: axisDirection,
              offset: position,
              slivers: <Widget>[
                SliverFillViewport(
                  viewportFraction: controller.viewportFraction,
                  delegate: SliverChildBuilderDelegate(
                    _buildContent,
                    childCount: months.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    final item = months[index];
    return Container(
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (_lastReportedPage != index) {
              controller.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            child: Text(
              dateFormat.format(item.time),
              style: item.selected
                  ? widget.selectedTextStyle
                  : widget.normalTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthItem {
  final DateTime time;
  bool selected;

  _MonthItem(this.time, {this.selected = false});
}
