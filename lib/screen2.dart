import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Import the theme file

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screen 2',
          style: TextStyle(
            fontFamily: AppFonts.pbold,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/background.jpg'), // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
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
              return Center(
                child: Text(
                  'No article found',
                  style: TextStyle(
                    fontFamily: AppFonts.pregular,
                    color: AppColors.black100,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                snapshot.data!['content'],
                style: TextStyle(
                  fontFamily: AppFonts.pregular,
                  color: AppColors.black100,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
