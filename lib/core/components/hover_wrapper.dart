import 'package:flutter/material.dart';

class HoverWrapper extends StatefulWidget {
  final Widget Function(bool hovering) builder;
 const HoverWrapper({super.key, required this.builder});

  @override
  State<HoverWrapper> createState() => HoverWrapperState();
}

class HoverWrapperState extends State<HoverWrapper> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: widget.builder(hovering),
    );
  }
}
