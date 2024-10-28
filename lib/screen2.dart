import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Import the theme file

class Screen2 extends StatelessWidget {
  final double _fontSize = 20.0; // Article text font size
  final Color _fontColor = AppColors.gray100; // Text color
  final double marginTop = 50.0; // Variable to control top margin for the heading

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
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('articles').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No articles found',
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
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var article = snapshot.data!.docs[index];
                    String heading = article['heading'] ?? 'No Heading';
                    String content = article['text'] ?? 'No Content';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index > 0) // Add the line separator between articles, not before the first one
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(
                              color: AppColors.secondary,
                              thickness: 1,
                            ),
                          ),
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
                        Text(
                          content,
                          style: TextStyle(
                            fontFamily: AppFonts.pregular,
                            color: AppColors.gray100,
                            fontSize: _fontSize,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
