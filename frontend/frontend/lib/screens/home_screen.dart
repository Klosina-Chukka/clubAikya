import 'package:flutter/material.dart';
import 'package:clubaikya/screens/ClubDetailPage.dart';
import 'package:clubaikya/screens/clubinfo.dart';

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
      appBar: PreferredSize(
  preferredSize: Size.fromHeight(70),
  child: Container(
    decoration: BoxDecoration(
      color: Color(0xff75bdc4),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),  // gentle rounding
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore Clubs',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontFamily: 'Helvetica',
                fontSize: 22,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black87),
                  onPressed: () {
                    // TODO: search logic
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.black87),
                  onPressed: () {
                    // TODO: notifications page
                  },
                ),
                Hero(
                  tag: 'profile-hero',
                  child: IconButton(
                    icon: Icon(Icons.account_circle, color: Colors.black87, size: 28),
                    onPressed: () {
                      // TODO: profile page navigation
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  ),
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
          return ClubCard(
            clubName: clubs[index]["name"]!,
            imagePath: clubs[index]["image"]!,

          );
        },
      ),
    );
  }
}

class ClubCard extends StatefulWidget {
  final String clubName;
  final String imagePath;

  ClubCard({required this.clubName, required this.imagePath});

  @override
  _ClubCardState createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 600),
      opacity: _opacity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailPage(
                clubName: widget.clubName,
                clubDescription: getClubDescription(widget.clubName),
                clubLogo: widget.imagePath,
                pastEvents: getClubEvents(widget.clubName),
                instagramLink: getInstagramLink(widget.clubName),
                websiteLink: getWebsiteLink(widget.clubName),
              ),
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
                  widget.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.clubName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}