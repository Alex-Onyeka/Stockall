import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      constraints: BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          spacing: 10,
          children: [
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'What happens when my subscription expires?',
                body:
                    'When your subscription expires, you will be redirected to a restricted view until you either choose a new subscription plan or switch back to the free plan. All features may be temporarily unavailable until a valid plan is active.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'What happens to my data on the cloud when I use the free mode?',
                body:
                    'In free mode, your business data is stored online for a 1 month duration. After this period, any data exceeding the free mode limits will be automatically deleted from the cloud. It\'s important to regularly back up your records to avoid losing important information.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'What happens to my data if I downgrade from a paid plan to a lower plan or free mode?',
                body:
                    'If you switch to a plan with lower limits than your current usage, any data exceeding the new plan\'s limits will become temporarily inaccessible. After a grace period of one month, the excess data will be automatically deleted from the cloud, leaving only the number of records allowed by your current plan.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'Can I recover deleted data if I downgrade or my subscription expires?',
                body:
                    'Once data is automatically deleted after the grace period, it cannot be recovered. To avoid losing important records, we recommend backing up your data regularly or maintaining an active subscription plan that accommodates your usage.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'How do I upgrade or change my subscription plan?',
                body:
                    'You can upgrade or change your subscription plan anytime from your account settings. Upgrading immediately unlocks additional features and increases your usage limits, while downgrading applies new limits and restrictions after the current billing cycle.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'Are my records safe if I have an active paid subscription?',
                body:
                    'Yes! While your paid subscription is active, all your records are securely stored in the cloud and accessible across all supported devices.',
              ),
            ),
            FaqTabContainer(
              faq: FaqClass(
                title:
                    'How is my subscription billing handled?',
                body:
                    'Subscriptions are billed according to the plan you choose. Payments are processed securely via our payment gateway. You can manage billing, view invoices, and update payment details from your account settings.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqClass {
  final String title;
  final String body;

  FaqClass({required this.title, required this.body});
}

class FaqTabContainer extends StatefulWidget {
  final FaqClass faq;
  const FaqTabContainer({super.key, required this.faq});

  @override
  State<FaqTabContainer> createState() =>
      _FaqTabContainerState();
}

class _FaqTabContainerState extends State<FaqTabContainer> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                setState(() {
                  isOpen = !isOpen;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 5,
                ),
                child: Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.faq.title,
                      ),
                    ),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons
                              .keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: Colors.grey.shade200,
                    height: 20,
                    thickness: 0.4,
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                    ),
                    widget.faq.body,
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
