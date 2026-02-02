class TrustCopy {
  static const String supportConfirmationTitle = "We'll look into this.";
  static const String supportConfirmationBody =
      "You won't be charged while we review.\n\nThanks for letting us know.";

  static const String paymentNotCharged = 'Nothing was charged.';
  static const String paymentTryAgain = 'You can try again.';

  static const String orderStatusChecking = "We're checking on this.";
  static const String orderStatusNoAction = 'No action needed right now.';
  static const Duration orderStatusStaleThreshold = Duration(minutes: 20);

  static const String receiptMissingPrices =
      'Some item prices may be unavailable.';
  static const String receiptPdfStub = 'PDF download is coming soon.';
}
