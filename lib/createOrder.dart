import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool loadingOrderCreation = false;
  bool requestingPayment = false;
  var orderId = "";
  // Create the order the way you see fit, either through your api or direct db CRUD
  Future<void> createOrderAndPay() async {
    orderId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      loadingOrderCreation = true;
    });
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).set({
        "items": [
          {"amount": 10, "quantity": 2, "description": "High end shoes"},
          {"amount": 5, "quantity": 4, "description": "Keyboard lenovo"}
        ],
        "totalAmount": 40,
        "paymentStatus": "pending",
        "orderStatus": "pending",
        "orderId": orderId
      });
      setState(() {
        loadingOrderCreation = false;
        requestingPayment = true;
      });

      try {
        await openDeepLink(currency: 'USD', amount: 40, metadata: {
          'orderId': orderId,
          'description':
              "Paying through cashOver payment for special edition joggers size 42"
        }, webhookIds: [
          "1",
        ]);
      } catch (e) {
        print(e);
      }
      setState(() {
        requestingPayment = false;
      });
    } catch (e) {
      print(e);
      loadingOrderCreation = false;
    }
  }

  Future<void> openDeepLink({
    Map<String, dynamic>? metadata,
    required num amount,
    required String currency,
    List<String>? webhookIds,
  }) async {
    final jsonStringEncodedMetadata =
        metadata != null ? jsonEncode(metadata) : null;
    final url = Uri.parse(
        'cashover://cashover.money/quickPay?username=salah.naoushi&amount=$amount&currency=$currency${webhookIds != null ? '&webhookIds=$webhookIds' : ''}${jsonStringEncodedMetadata != null ? '&metadata=$jsonStringEncodedMetadata' : ''}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (Platform.isAndroid) {
      final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data:
              url.toString(), // replace com.example.app with your applicationId
          arguments: {
            "metadata": {
              "orderId": DateTime.now().millisecondsSinceEpoch.toString(),
              "description": "Buying local shoes through cashOver payments"
            }
          });
      await intent.launch();
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loadingOrderCreation = true;
    });
    createOrderAndPay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          if (loadingOrderCreation) Text("Creating order..."),
          if (requestingPayment) Text('Requesting payment, please wait...'),
          if (!loadingOrderCreation)
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Orders")
                    .doc(orderId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Unable to fetch order');
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data?.exists != true) {
                    return const Center(
                      child: Text("Order does not exist"),
                    );
                  }
                  return Text(
                      'Current payment status: ${snapshot.data!.data()?['paymentStatus']}');
                })
        ],
      ),
    );
  }
}
