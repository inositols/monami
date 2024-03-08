import 'package:flutter/material.dart';
import 'package:monami/custom_widgets/column_separator.dart';
import 'package:monami/custom_widgets/custom_button.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

import '../domain/cart_model.dart';
import 'cart_check_out.dart';
import 'widget/cart_widget.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: const Text(
          "My Cart",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Column(
                children: getChildrenWithSeperator(
                  addToLastChild: false,
                  widgets: demoItems.map((e) {
                    return Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: 600,
                      child: ChartItemWidget(
                        item: e,
                      ),
                    );
                  }).toList(),
                  seperator: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              getCheckoutButton(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget getCheckoutButton(BuildContext context) {
    return CustomButton(
      text: "Go To Check Out",
      color: Colors.purple.shade900,
      textColor: AppColor.whiteColor,
      onPressed: () {
        showBottomSheet(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: getButtonPriceWidget(),
          ),
        ],
      ),
    );
  }

  Widget getButtonPriceWidget() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        // color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "\$12.96",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColor.whiteColor,
        ),
      ),
    );
  }

  void showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return const CheckoutBottomSheet();
        });
  }
}
