import 'package:flutter/material.dart';

class SharedScaffold extends StatelessWidget {
  final Widget Function(Size size) builder;
  final Color? backgroundColor;
  final AppBar? appBar;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;
  final Function? onWillPop;
  final Function? onTap;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const SharedScaffold({
    Key? key,
    required this.builder,
    this.appBar,
    this.drawer,
    this.backgroundColor,
    this.onWillPop,
    this.onTap,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size constraint = Size(constraints.maxWidth, constraints.maxHeight);
      return PopScope(
        onPopInvoked: (bool didpop) {
          if (onWillPop != null) {
            onWillPop!();
          } else {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("content")));
        },
        child: Scaffold(
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          backgroundColor:
              backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          drawer: drawer,
          body: Builder(
            builder: (_) => builder(constraint),
          ),
        ),
      );
    });
  }
}
