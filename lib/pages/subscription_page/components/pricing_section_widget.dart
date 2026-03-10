import 'package:flutter/material.dart';
import 'package:stockall/pages/subscription_page/components/pricing_container_widget.dart';

class PricingSectionWidget extends StatelessWidget {
  const PricingSectionWidget({
    super.key,
    required this.fullComparisonSection,
  });

  final GlobalKey<State<StatefulWidget>>
  fullComparisonSection;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        PricingContainerWidget(
          plan: 0,
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          plan: 1,
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          plan: 2,
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          plan: 3,
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          plan: 4,
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          plan: 5,
          fullComparisonSection: fullComparisonSection,
        ),
      ],
    );
  }
}
