class MenuItem {
  final String title;
  final String route;
  final bool isFullWidth;
  final bool isHighlighted;

  const MenuItem({
    required this.title,
    required this.route,
    this.isFullWidth = false,
    this.isHighlighted = false,
  });
}
