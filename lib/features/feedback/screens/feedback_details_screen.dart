import 'package:flutter/material.dart';

class FeedbackDetailsScreen extends StatelessWidget {
  const FeedbackDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
        title: Text("Chi tiết phản hồi"),
        centerTitle: true,
        actions: [],
      ),

      body: Container(color: Colors.amber),
    );
  }
}
