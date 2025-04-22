import 'package:flutter/material.dart';
import 'package:clubaikya/screens/clubpage.dart';
class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> clubs = [
    {"name": "Ragavarsha Club", "image": "assets/clublogos/ragclub.png"},
    {"name": "Watts Guild Club", "image": "assets/clublogos/watts.jpg"},
    {"name": "Film and Videography Club", "image": "assets/clublogos/filmclub.jpg"},
    {"name": "Coding Club", "image": "assets/clublogos/codeclub.jpg"},
    {"name": "Photography Club", "image": "assets/clublogos/photo.jpg"},
    {"name": "Elite Feet", "image": "assets/clublogos/club1.jpg"},
    {"name": "Art Meraki", "image": "assets/clublogos/artclub.png"},
    {"name": "Environmental Club", "image": "assets/clublogos/evnclub.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Clubs'),
        backgroundColor: Color(0xff75bdc4),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClubPage(clubName: clubs[index]["name"]!),
                ),
              );
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      clubs[index]["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      clubs[index]["name"]!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}