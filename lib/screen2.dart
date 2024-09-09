import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 2'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('articles')
            .doc('articleId')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(child: Text('No article found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(snapshot.data!['content']),
          );
        },
      ),
    );
  }
}
