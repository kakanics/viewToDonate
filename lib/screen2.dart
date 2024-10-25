import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Import the theme file

class Screen2 extends StatelessWidget {
  final double _fontSize = 20.0; // Article text font size
  final Color _fontColor = AppColors.gray100; // Text color
  final double marginTop =
      50.0; // Variable to control top margin for the heading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
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
                .doc('articleId') // Replace with your actual document ID
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

              String heading = snapshot.data!['heading'] ?? 'No Heading';
              String content = snapshot.data!['text'] ?? 'No Content';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: marginTop), // Apply top margin
                    Text(
                      heading,
                      style: TextStyle(
                        fontFamily: AppFonts.pextrabold,
                        color: AppColors.white,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: TextStyle(
                            fontFamily: AppFonts.pregular,
                            color: _fontColor,
                            fontSize: _fontSize,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
