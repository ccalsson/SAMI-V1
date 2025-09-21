import 'package:flutter/material.dart';

class SuperDashboardShell extends StatelessWidget {
  const SuperDashboardShell({
    super.key,
    required this.sidebar,
    required this.topBar,
    required this.content,
    this.compactNavigation,
    this.sidebarWidth = 280,
    this.topBarHeight = 72,
    this.compactNavigationHeight = 72,
    this.breakpoint = 960,
    this.backgroundColor,
    this.contentBackgroundColor,
  });

  final Widget sidebar;
  final Widget topBar;
  final Widget content;
  final Widget? compactNavigation;
  final double sidebarWidth;
  final double topBarHeight;
  final double compactNavigationHeight;
  final double breakpoint;
  final Color? backgroundColor;
  final Color? contentBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldColor =
        backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.2);
    final surfaceColor = contentBackgroundColor ?? theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= breakpoint;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: sidebarWidth, child: sidebar),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: topBarHeight, child: topBar),
                        const Divider(height: 1, thickness: 1),
                        Expanded(
                          child: ColoredBox(
                            color: surfaceColor,
                            child: content,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(height: topBarHeight, child: topBar),
                Expanded(
                  child: ColoredBox(
                    color: surfaceColor,
                    child: content,
                  ),
                ),
                if (compactNavigation != null)
                  SizedBox(
                    height: compactNavigationHeight,
                    child: compactNavigation,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
