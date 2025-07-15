import 'package:flutter/material.dart';

class BookJournalDemo extends StatelessWidget {
  static const Color backgroundColor = Color(0xFF919B80);
  static const Color gradient1 = Color(0xFFf3f4f1);
  static const Color gradient2 = Color.fromRGBO(245, 243, 240, 1.0);
  static const Color gradient3 = Color.fromRGBO(116, 76, 76, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Book Journal"),
        backgroundColor: gradient3,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient1, gradient2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Book Title: The Alchemist",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: gradient3,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Author: Paulo Coelho",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradient3,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text("Mark as Read"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
