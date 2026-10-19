import 'package:flutter/material.dart';
import 'package:lavendera/features/customer/presentation/pages/customer_page.dart';

class Home extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("data")),
      body: Center(
        child: Column(
          children: [
            Text("HOMEEE"),
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => CustomerPage())),
              child: Text("CUSTOMER"),
            ),
          ],
        ),
      ),
    );
  }
}
