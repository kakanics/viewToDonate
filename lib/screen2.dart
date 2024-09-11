import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Import the theme file

class Screen2 extends StatelessWidget {
  // Expose font size and color controls in the code
  final double _fontSize = 16.0;
  final Color _fontColor = AppColors.black100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Replace with your image asset
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
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
                      color: _fontColor,
                      fontSize: _fontSize,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    snapshot.data!['content'],
                    style: TextStyle(
                      fontFamily: AppFonts.pregular,
                      color: _fontColor,
                      fontSize: _fontSize,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
