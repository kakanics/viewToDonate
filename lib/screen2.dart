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
              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
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

              // Retrieve all documents
              List<DocumentSnapshot> articles = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    // Extract heading and content from each document
                    String heading = articles[index]['heading'] ?? 'No Heading';
                    String content = articles[index]['text'] ?? 'No Content';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: index == 0 ? marginTop : 20), // Apply top margin only to first article
                        Text(
                          heading,
                          style: TextStyle(
                            fontFamily: AppFonts.pextrabold,
                            color: AppColors.red,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          content,
                          style: TextStyle(
                            fontFamily: AppFonts.pregular,
                            color: _fontColor,
                            fontSize: _fontSize,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 20), // Space between articles
                        Divider(color: AppColors.gray100),
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
