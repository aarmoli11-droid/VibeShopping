class StoreBudgetSummary {
  final String storeId;
  final String storeName;
  final double amount;
  final double percentage;

  const StoreBudgetSummary({
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.percentage,
  });

  factory StoreBudgetSummary.fromJson(Map<String, dynamic> json) {
    return StoreBudgetSummary(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'amount': amount,
      'percentage': percentage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreBudgetSummary && other.storeId == storeId;
  }

  @override
  int get hashCode => storeId.hashCode;

  @override
  String toString() => 'StoreBudgetSummary($storeName: ₡$amount)';
}

class SavingsOpportunity {
  final String tip;
  final double estimatedSavings;

  const SavingsOpportunity({
    required this.tip,
    required this.estimatedSavings,
  });

  factory SavingsOpportunity.fromJson(Map<String, dynamic> json) {
    return SavingsOpportunity(
      tip: json['tip'] as String,
      estimatedSavings: (json['estimatedSavings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tip': tip,
      'estimatedSavings': estimatedSavings,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsOpportunity &&
        other.tip == tip &&
        other.estimatedSavings == estimatedSavings;
  }

  @override
  int get hashCode => Object.hash(tip, estimatedSavings);

  @override
  String toString() => 'SavingsOpportunity(₡$estimatedSavings — $tip)';
}

class BudgetAnalysis {
  final double totalSpending;
  final String currency;
  final String period;
  final List<StoreBudgetSummary> byStore;
  final List<String> warnings;

  const BudgetAnalysis({
    required this.totalSpending,
    required this.currency,
    required this.period,
    required this.byStore,
    required this.warnings,
  });

  BudgetAnalysis copyWith({
    double? totalSpending,
    String? currency,
    String? period,
    List<StoreBudgetSummary>? byStore,
    List<String>? warnings,
  }) {
    return BudgetAnalysis(
      totalSpending: totalSpending ?? this.totalSpending,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      byStore: byStore ?? this.byStore,
      warnings: warnings ?? this.warnings,
    );
  }

  factory BudgetAnalysis.fromJson(Map<String, dynamic> json) {
    return BudgetAnalysis(
      totalSpending: (json['totalSpending'] as num).toDouble(),
      currency: json['currency'] as String,
      period: json['period'] as String,
      byStore: (json['byStore'] as List<dynamic>)
          .map((e) => StoreBudgetSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      warnings: (json['warnings'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSpending': totalSpending,
      'currency': currency,
      'period': period,
      'byStore': byStore.map((e) => e.toJson()).toList(),
      'warnings': warnings,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetAnalysis &&
        other.totalSpending == totalSpending &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(totalSpending, period);

  @override
  String toString() {
    return 'BudgetAnalysis(₡$totalSpending $currency, $period)';
  }
}
