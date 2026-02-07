import 'package:yekermo/domain/models.dart';

/// Result of GET /me: customer profile plus email from auth.
class MeProfile {
  const MeProfile({
    required this.customer,
    required this.email,
  });

  final Customer customer;
  final String email;
}
