import 'package:clubaikya/screens/ClubDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:clubaikya/screens/clubinfo.dart';
import 'package:clubaikya/screens/profilepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  final token;
  const HomeScreen(this.token);
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> todaysEvents = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchTodaysEvents();
  }

  Future<void> fetchTodaysEvents() async {
    final response = await http.get(Uri.parse('https://4274-2405-201-c42a-4810-30a2-fb9e-81e0-e319.ngrok-free.app/events/today'));
    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      print("Fetched ${events.length} events");
      setState(() {
        todaysEvents.clear();
        for (var e in events) {
          print("Title: ${e['title']}, Time: ${e['time']}, Club: ${e['clubName']},'description': ${e['description']}");
          todaysEvents.add({
            'title': e['title'],
            'time': e['time'],
            'club': e['clubName'],
            'description': e['description'],
          });
        }
      });
    } else {
      print('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClubs = clubs
        .where((club) => club["name"]!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff75bdc4),
        title: Text('Explore Clubs', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodaysEvents,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Container(
                height: 200,
                child: todaysEvents.isEmpty
                    ? Card(
                        margin: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No events today',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: todaysEvents.length,
                        itemBuilder: (context, index) {
                          final event = todaysEvents[index];
                          final club = clubs.firstWhere(
                            (c) => c['name'] == event['club'],
                            orElse: () => {},
                          );
                          return GestureDetector(
                            onTap: () {
                              if (club.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClubDetailPage(
                                      clubName: club['name'],
                                      clubDescription: club['description'],
                                      clubLogo: club['logo'],
                                      instagramLink: club['instagram'],
                                      websiteLink: club['website'],
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                Card(
                                  margin: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 7,
                                  child: Container(
                                    width: 280,
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          event['title'] == 'null'
                                              ? 'untitled'
                                              : event['title']!.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    Text("${event['description']}",style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),),
                                        Text("Time: ${event['time']}",style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),),
                                        Text("Club: ${event['club']}",style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),),
                                      ],
                                    ),
                                  ),
                                ),
                                if (club.isNotEmpty && club['logo'] != null)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(club['logo']),
                                      radius: 35,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              GridView.builder(
                padding: EdgeInsets.all(10),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredClubs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClubDetailPage(
                            clubName: filteredClubs[index]['name'],
                            clubDescription: filteredClubs[index]['description'],
                            clubLogo: filteredClubs[index]['logo'],
                            instagramLink: filteredClubs[index]['instagram'],
                            websiteLink: filteredClubs[index]['website'],
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(filteredClubs[index]['logo']!),
                            radius: 70,
                          ),
                          SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              filteredClubs[index]['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
