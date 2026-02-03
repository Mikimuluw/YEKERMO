/// Immutable referral: code is fixed; counts are informational only. No gamification.
class Referral {
  const Referral({
    required this.code,
    this.sentCount = 0,
    this.redeemedCount = 0,
  });

  final String code;
  final int sentCount;
  final int redeemedCount;

  Referral copyWith({
    int? sentCount,
    int? redeemedCount,
  }) {
    return Referral(
      code: code,
      sentCount: sentCount ?? this.sentCount,
      redeemedCount: redeemedCount ?? this.redeemedCount,
    );
  }
}
