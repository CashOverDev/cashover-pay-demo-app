import 'package:cashover_pay_demo_app/createOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //connectServicesToFirebaseEmulator();
  runApp(const MyApp());
}

Future<void> connectServicesToFirebaseEmulator() async {
  if (true) {
    try {
      // Cloud Firestore
      FirebaseFirestore.instance.settings = const Settings(
        host: 'localhost:8086',
        sslEnabled: false,
        persistenceEnabled: false,
      );
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8086);
    } catch (e) {
      print(e);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashOver E-commerce Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Products'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                    height: 300,
                    width: 300,
                    "https://media.istockphoto.com/id/187310279/photo/brown-leather-shoe.jpg?s=612x612&w=0&k=20&c=N-G1SP8dDojp3M_ykS7tQuYI8OVPWM0XA8_knBiWRtY="),
              ),
            ),
          ),
          const Text(
            "Niche shoes made for luxury",
            style: TextStyle(
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Just for 100 USD",
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          TextButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return CreateOrder();
                    });
              },
              child: Text("Pay with cashOver")),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .orderBy("orderId", descending: true)
                  .snapshots(),
              builder: (
                context,
                data,
              ) {
                if (data.hasError) {
                  return Center(
                    child: Text("Error: ${data.error}"),
                  );
                }
                if (!data.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Column(
                  children: List.generate(data.data!.docs.length, (index) {
                    return ListTile(
                        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                                int.parse(
                                    data.data!.docs[index].data()["orderId"]))
                            .toString()),
                        tileColor:
                            index.isEven ? Colors.green : Colors.blueAccent,
                        title: Text(
                          "OrderId: ${data.data!.docs[index].data()["orderId"]}/Payment status: ${data.data!.docs[index].data()["paymentStatus"]}/ Order status: ${data.data!.docs[index].data()["orderStatus"]}",
                        ));
                  }),
                );
              })
        ],
      ),
    );
  }
}
