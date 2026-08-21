// Web-only implementation. Loaded via conditional import from
// cal_com_embed.dart when compiling for the web platform.
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class CalComEmbedImpl extends StatefulWidget {
  final String calLink;
  final double height;

  const CalComEmbedImpl({
    super.key,
    required this.calLink,
    this.height = 600,
  });

  @override
  State<CalComEmbedImpl> createState() => _CalComEmbedImplState();
}

class _CalComEmbedImplState extends State<CalComEmbedImpl> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'cal-com-${widget.calLink.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int id) {
      final iframe = html.IFrameElement()
        ..src = 'https://cal.com/${widget.calLink}?embed=true&layout=month_view&theme=dark'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
