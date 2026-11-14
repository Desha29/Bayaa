class FeatureInsightsSpec {
  const FeatureInsightsSpec(
      {required this.trendTitle,
      required this.trendTitleAr,
      required this.distributionTitle,
      required this.distributionTitleAr,
      required this.trend,
      required this.labels,
      required this.labelsAr,
      required this.distribution});
  final String trendTitle;
  final String trendTitleAr;
  final String distributionTitle;
  final String distributionTitleAr;
  final List<double> trend;
  final List<String> labels;
  final List<String> labelsAr;
  final List<double> distribution;
}
