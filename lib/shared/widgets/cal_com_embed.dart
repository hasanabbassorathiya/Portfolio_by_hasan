import 'package:flutter/material.dart';

import 'cal_com_embed_stub.dart'
    if (dart.library.html) 'cal_com_embed_web.dart';

class CalComEmbed extends StatelessWidget {
  final String calLink;
  final double height;

  const CalComEmbed({
    super.key,
    required this.calLink,
    this.height = 600,
  });

  @override
  Widget build(BuildContext context) {
    return CalComEmbedImpl(calLink: calLink, height: height);
  }
}
