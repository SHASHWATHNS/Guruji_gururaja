import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guraj_astro/features/purchase/data/purchase_local_service.dart';
import 'package:guraj_astro/features/purchase/domain/entities/subscription_plan.dart';

/// Providers
final purchaseServiceProvider = Provider<PurchaseLocalService>((ref) {
  return PurchaseLocalService();
});

/// Exposes remaining uses + locked flag + plans
final purchaseStateProvider =
AsyncNotifierProvider<PurchaseNotifier, PurchaseState>(PurchaseNotifier.new);

class PurchaseState {
  final int remainingFreeUses;
  final bool isLocked;
  final List<SubscriptionPlan> plans;

  const PurchaseState({
    required this.remainingFreeUses,
    required this.isLocked,
    required this.plans,
  });

  PurchaseState copyWith({
    int? remainingFreeUses,
    bool? isLocked,
    List<SubscriptionPlan>? plans,
  }) =>
      PurchaseState(
        remainingFreeUses: remainingFreeUses ?? this.remainingFreeUses,
        isLocked: isLocked ?? this.isLocked,
        plans: plans ?? this.plans,
      );
}

class PurchaseNotifier extends AsyncNotifier<PurchaseState> {
  static const _plans = <SubscriptionPlan>[
    SubscriptionPlan(
      id: 'basic_monthly',
      title: 'Basic Monthly',
      price: '₹149 / mo',
      tagline: 'Unlock all daily features',
      perks: ['Unlimited access', 'Daily Panchanga & Transit', 'Basic support'],
    ),
    SubscriptionPlan(
      id: 'pro_quarterly',
      title: 'Pro Quarterly',
      price: '₹349 / 3 mo',
      tagline: 'Save more, grow faster',
      perks: ['Everything in Basic', 'Matchmaking & Reports', 'Priority support'],
    ),
    SubscriptionPlan(
      id: 'elite_annual',
      title: 'Elite Annual',
      price: '₹999 / year',
      tagline: 'Best value for power users',
      perks: ['All Pro features', 'Exclusive insights', 'Early feature access'],
    ),
  ];

  @override
  Future<PurchaseState> build() async {
    final svc = ref.read(purchaseServiceProvider);
    final remaining = await svc.remainingFreeUses();
    final locked = await svc.isLocked();
    return PurchaseState(
      remainingFreeUses: remaining,
      isLocked: locked,
      plans: _plans,
    );
  }

  /// Call this when user consumes a "free use"
  Future<void> consumeFreeUse() async {
    state = const AsyncLoading();
    try {
      final svc = ref.read(purchaseServiceProvider);
      await svc.incrementUse();
      final remaining = await svc.remainingFreeUses();
      final locked = await svc.isLocked();
      state = AsyncData(PurchaseState(
        remainingFreeUses: remaining,
        isLocked: locked,
        plans: (state.value?.plans ?? _plans),
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// For testing/resetting trial
  Future<void> resetTrial() async {
    state = const AsyncLoading();
    final svc = ref.read(purchaseServiceProvider);
    await svc.resetUses();
    final remaining = await svc.remainingFreeUses();
    final locked = await svc.isLocked();
    state = AsyncData(PurchaseState(
      remainingFreeUses: remaining,
      isLocked: locked,
      plans: (state.value?.plans ?? _plans),
    ));
  }
}
