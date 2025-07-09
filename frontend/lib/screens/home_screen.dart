import 'package:clubaikya/screens/ClubDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:clubaikya/screens/clubinfo.dart';
import 'package:clubaikya/screens/profilepage.dart';
import 'package:http/http.dart' as http;
import 'package:clubaikya/screens/announcementspage.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen(this.token, {Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> todaysEvents = [];
  String searchQuery = "";
  List<Map<String, dynamic>> announcements = [];

  @override
  void initState() {
    super.initState();
    fetchTodaysEvents();
    fetchAnnouncements();
  }

  Future<void> fetchTodaysEvents() async {
    final response = await http.get(Uri.parse('https://d0ab-2405-201-c42a-4810-806f-1bdc-ff0f-a417.ngrok-free.app/events/today'));
    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      setState(() {
        todaysEvents.clear();
        for (var e in events) {
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

  Future<void> fetchAnnouncements() async {
    final url =
        Uri.parse('https://3d83feea18ab.ngrok-free.app/api/announcements/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['announcements'];

        setState(() {
          announcements = data.map((item) {
            final existing = announcements.firstWhere(
              (a) =>
                  a['title'] == item['title'] &&
                  a['date']?.toString().substring(0, 10) ==
                      item['date']?.toString().substring(0, 10),
              orElse: () => {},
            );

            return {
              'title': item['title'],
              'message': item['description'] ?? '',
              'eventName': item['eventName'],
              'date': item['date']?.toString().substring(0, 10) ?? '',
              'isNew': existing.isEmpty ? true : existing['isNew'],
            };
          }).toList();
        });
      } else {
        print("Announcement error: ${response.body}");
      }
    } catch (e) {
      print("Announcement fetch error: $e");
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
        backgroundColor: const Color(0xff75bdc4),
        title: const Text('Explore Clubs', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        actions: [
          badges.Badge(
            showBadge: announcements.any((a) => a['isNew'] == true),
            position: badges.BadgePosition.topEnd(top: 2, end: 4),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(6),
            ),
            badgeContent: const SizedBox.shrink(),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
                );
                setState(() {
                  for (var a in announcements) {
                    a['isNew'] = false;
                  }
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
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
        onRefresh: () async {
          await fetchTodaysEvents();
          await fetchAnnouncements();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    prefixIcon: const Icon(Icons.search),
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
              SizedBox(
                height: 200,
                child: todaysEvents.isEmpty
                    ? Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
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
                                  margin: const EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 7,
                                  child: Container(
                                    width: 280,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          event['title'] == 'null'
                                              ? 'untitled'
                                              : event['title']!.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          event['description'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text("Time: ${event['time']}",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                            )),
                                        Text("Club: ${event['club']}",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                            )),
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
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            backgroundImage:
                                AssetImage(filteredClubs[index]['logo']!),
                            radius: 70,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              filteredClubs[index]['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
