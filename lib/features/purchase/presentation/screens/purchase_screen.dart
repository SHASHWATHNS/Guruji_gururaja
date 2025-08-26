import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guraj_astro/features/purchase/domain/entities/subscription_plan.dart';
import 'package:guraj_astro/features/purchase/presentation/viewmodels/purchase_view_model.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(purchaseStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade & Trial')),
      backgroundColor: const Color(0xFFFFF3CD),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(purchaseStateProvider),
        ),
        data: (state) => _Body(state: state),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final PurchaseState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialBanner = _TrialBanner(
      remaining: state.remainingFreeUses,
      isLocked: state.isLocked,
      onUseNow: state.isLocked
          ? null
          : () async {
        await ref.read(purchaseStateProvider.notifier).consumeFreeUse();
        if (!(await ref.read(purchaseServiceProvider).isLocked())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Free use consumed. Enjoy!')),
          );
        }
      },
    );

    final plans = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Choose your plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        ...state.plans.map((p) => _PlanCard(plan: p)).toList(),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () {
              // Terms/Privacy navigation hook
            },
            child: const Text('Terms • Privacy • Restore purchases'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    return ListView(
      children: [
        const SizedBox(height: 12),
        trialBanner,
        const SizedBox(height: 8),
        if (state.isLocked)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your free trial is over. Subscribe to continue using all features.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        const SizedBox(height: 8),
        plans,
      ],
    );
  }
}

class _TrialBanner extends StatelessWidget {
  final int remaining;
  final bool isLocked;
  final VoidCallback? onUseNow;

  const _TrialBanner({
    required this.remaining,
    required this.isLocked,
    required this.onUseNow,
  });

  @override
  Widget build(BuildContext context) {
    final usesText = isLocked
        ? 'Free trial ended'
        : 'Free trial: $remaining use${remaining == 1 ? '' : 's'} left (of 5)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 8, spreadRadius: 0, offset: Offset(0, 2), color: Color(0x33000000))],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                usesText,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onUseNow,
              child: Text(isLocked ? 'Subscribe' : 'Use now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                Text(plan.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.tagline, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            ...plan.perks.map((p) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(p)),
              ],
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // 🔗 Hook your payment flow here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${plan.title}. Integrate payment here.')),
                  );
                },
                child: const Text('Subscribe'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 40),
      const SizedBox(height: 8),
      Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Try again'),
      ),
    ]),
  );
}
