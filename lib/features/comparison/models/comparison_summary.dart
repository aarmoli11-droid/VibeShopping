class ComparisonSummary {
  final double cheapestPrice;
  final double highestPrice;
  final double averagePrice;
  final double savings;
  final double percentageDifference;
  final int supermarketsCompared;

  const ComparisonSummary({
    required this.cheapestPrice,
    required this.highestPrice,
    required this.averagePrice,
    required this.savings,
    required this.percentageDifference,
    required this.supermarketsCompared,
  });
}
