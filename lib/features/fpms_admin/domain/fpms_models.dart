class FpmsDomain {
  final String id;
  final String title;
  final String code;
  final String description;
  final String iconName;
  final String status;

  FpmsDomain({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.iconName,
    required this.status,
  });
}

class PlatformKpiMetric {
  final String label;
  final String value;
  final String changeText;
  final bool isPositive;

  PlatformKpiMetric({
    required this.label,
    required this.value,
    required this.changeText,
    required this.isPositive,
  });
}
