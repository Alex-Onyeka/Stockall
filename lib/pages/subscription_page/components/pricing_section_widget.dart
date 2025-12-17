import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/plan_pricing_class.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
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
          pricingClass: PlanPricingClass(
            dataStorageDuration: 1,
            plan: 0,
            planName: 'Free',
            planDesc: 'Perfect for Testing Out',
            discount:
                returnSubPaymentProvider(context).discount,
            price:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .price,
            duration:
                returnSubPaymentProvider(
                  context,
                ).currentDuration,
            numberOfItems:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .itemsAuth
                    .numberOfItems,
            barcode:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .itemsAuth
                    .useOfBarcode,
            invoiceManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .salesAuth
                    .invoiceManagement,
            receiptManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .salesAuth
                    .printReceipt,
            useCalculator:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .calculatorAuth
                    .useCalculator,
            numberOfStaffs:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .employeesAuth
                    .numberOfEmployees,
            useOffline:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .generalSettingsAuth
                    .allowOfflineUse,
            numberOfBranches:
                subPlans
                    .firstWhere((pl) => pl.plan == 0)
                    .multipleStoresAuth
                    .numberOfStores,
          ),
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          pricingClass: PlanPricingClass(
            dataStorageDuration: 1000001,
            plan: 1,
            planName: 'Basic',
            planDesc: 'Perfect for Running Small Business',
            discount:
                returnSubPaymentProvider(context).discount,
            price:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .price,
            duration:
                returnSubPaymentProvider(
                  context,
                ).currentDuration,
            numberOfItems:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .itemsAuth
                    .numberOfItems,
            barcode:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .itemsAuth
                    .useOfBarcode,
            invoiceManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .salesAuth
                    .invoiceManagement,
            receiptManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .salesAuth
                    .printReceipt,
            useCalculator:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .calculatorAuth
                    .useCalculator,
            numberOfStaffs:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .employeesAuth
                    .numberOfEmployees,
            useOffline:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .generalSettingsAuth
                    .allowOfflineUse,
            numberOfBranches:
                subPlans
                    .firstWhere((pl) => pl.plan == 1)
                    .multipleStoresAuth
                    .numberOfStores,
          ),
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          pricingClass: PlanPricingClass(
            dataStorageDuration: 1000001,
            plan: 2,
            planName: 'Standard',
            planDesc:
                'For Running Moderately Large Businesses',
            discount:
                returnSubPaymentProvider(context).discount,
            price:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .price,
            duration:
                returnSubPaymentProvider(
                  context,
                ).currentDuration,
            numberOfItems:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .itemsAuth
                    .numberOfItems,
            barcode:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .itemsAuth
                    .useOfBarcode,
            invoiceManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .salesAuth
                    .invoiceManagement,
            receiptManagement:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .salesAuth
                    .printReceipt,
            useCalculator:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .calculatorAuth
                    .useCalculator,
            numberOfStaffs:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .employeesAuth
                    .numberOfEmployees,
            useOffline:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .generalSettingsAuth
                    .allowOfflineUse,
            numberOfBranches:
                subPlans
                    .firstWhere((pl) => pl.plan == 2)
                    .multipleStoresAuth
                    .numberOfStores,
          ),
          fullComparisonSection: fullComparisonSection,
        ),
        PricingContainerWidget(
          pricingClass: PlanPricingClass(
            dataStorageDuration: 1000001,
            plan: 3,
            planName: 'Premium',
            planDesc: 'For Running Large Businesses',
            discount:
                returnSubPaymentProvider(context).discount,
            price: 5000,
            duration:
                returnSubPaymentProvider(
                  context,
                ).currentDuration,
            numberOfItems: 2000000,
            barcode: true,
            invoiceManagement: true,
            receiptManagement: true,
            useCalculator: true,
            numberOfStaffs: 10,
            useOffline: true,
            numberOfBranches: 30,
          ),
          fullComparisonSection: fullComparisonSection,
        ),
      ],
    );
  }
}
