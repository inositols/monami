import 'package:flutter/material.dart';
import 'package:monami/custom_widgets/custom_button.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

import 'widget/app_text.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 30,
      ),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Wrap(
        children: <Widget>[
          Row(
            children: [
              const AppText(
                text: "Checkout",
                fontSize: 24,
                fontWeight: FontWeight.w600,
                textAlign: null,
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 25,
                    color: Colors.red.shade900,
                  ))
            ],
          ),
          const SizedBox(
            height: 45,
          ),
          getDivider(),
          checkoutRow("Delivery",
              trailingText: "Select Method",
              trailingWidget: const SizedBox.shrink()),
          getDivider(),
          checkoutRow("Payment",
              trailingWidget: const Icon(
                Icons.payment,
                color: AppColor.blackColor,
              )),
          getDivider(),
          checkoutRow("Promo Code",
              trailingText: "Pick Discount",
              trailingWidget: const SizedBox.shrink()),
          getDivider(),
          checkoutRow("Total Cost",
              trailingText: "\$13.97", trailingWidget: const SizedBox.shrink()),
          getDivider(),
          const SizedBox(
            height: 30,
          ),
          termsAndConditionsAgreement(context),
          Container(
              margin: const EdgeInsets.only(
                top: 25,
              ),
              child: CustomButton(
                text: "Place Order",
                color: Colors.purple.shade900,
                onPressed: () {
                  onPlaceOrderClicked();
                },
              )),
        ],
      ),
    );
  }

  Widget getDivider() {
    return const Divider(
      thickness: 1,
      color: Color(0xFFE2E2E2),
    );
  }

  Widget termsAndConditionsAgreement(BuildContext context) {
    return RichText(
      text: const TextSpan(
          text: 'By placing an order you agree to our',
          style: TextStyle(
            color: Color(0xFF7C7C7C),
            fontSize: 14,
            //font
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
                text: " Terms",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            TextSpan(text: " And"),
            TextSpan(
                text: " Conditions",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ]),
    );
  }

  Widget checkoutRow(String label,
      {String? trailingText, required Widget trailingWidget}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Row(
        children: [
          AppText(
            text: label,
            fontSize: 18,
            color: const Color(0xFF7C7C7C),
            fontWeight: FontWeight.w600,
            textAlign: null,
          ),
          const Spacer(),
          trailingText == null
              ? trailingWidget
              : AppText(
                  text: trailingText,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  textAlign: null,
                ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }

  void onPlaceOrderClicked() {
    Navigator.pop(context);
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return OrderFailedDialogue();
    //     });
  }
}
