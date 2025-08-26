import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  final String id;          // e.g., "basic_monthly"
  final String title;       // e.g., "Basic Monthly"
  final String price;       // display only, e.g., "₹149 / mo"
  final String tagline;     // e.g., "Unlock all features"
  final List<String> perks; // bullet points

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.tagline,
    required this.perks,
  });
}
