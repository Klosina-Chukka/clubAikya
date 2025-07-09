import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubaikya/screens/EventPage.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  List<String> seenTitles = [];

  @override
  void initState() {
    super.initState();
    loadSeenAndFetch();
  }

  Future<void> loadSeenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    seenTitles = prefs.getStringList('seenAnnouncements') ?? [];
    await fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    final url = Uri.parse('https://3d83feea18ab.ngrok-free.app/api/announcements/all');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['announcements'];

        setState(() {
          announcements = data.map((item) {
            String id = item['title'] ?? 'no-title';

            return {
              'title': item['title'] ?? 'No Title',
              'message': item['description'] ?? '',
              'eventName': item['eventName'] ?? '',
              'eventDescription': item['eventDescription'] ?? '',
              'eventLocation': item['eventLocation'] ?? 'Unknown Location',
              'eventMode': item['eventMode'] ?? '',
              'eventDate': item['eventDate'] ?? '',
              'eventTime': item['eventTime'] ?? '',
              'eventDeadline': item['eventDeadline'] ?? '',
              'eventImageUrl': item['eventImageUrl'] ?? '',
              'eventLinks': (item['eventLinks'] as List?)?.map((link) => Map<String, String>.from(link)).toList() ?? [],
              'date': item['date']?.toString().substring(0, 10) ?? '',
              'isNew': !seenTitles.contains(id),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
          announcements = [];
        });
      }
    } catch (e) {
      print("❌ Exception while fetching: $e");
      setState(() {
        isLoading = false;
        announcements = [];
      });
    }
  }

  Future<void> markAsSeen(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final title = announcements[index]['title'] ?? '';

    if (!seenTitles.contains(title)) {
      seenTitles.add(title);
      await prefs.setStringList('seenAnnouncements', seenTitles);
    }

    setState(() {
      announcements[index]['isNew'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff75bdc4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: themeColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : announcements.isEmpty
              ? const Center(
                  child: Text(
                    'No announcements',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final a = announcements[index];
                    final isValidEvent = (a['eventName'] as String).trim().isNotEmpty;

                    return GestureDetector(
                      onTap: () async {
                        if (!isValidEvent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This announcement is not linked to a valid event.'),
                            ),
                          );
                          return;
                        }

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPage(
                              eventTitle: a['eventName'],
                              eventDescription: a['eventDescription'],
                              eventLocation: a['eventLocation'],
                              eventMode: a['eventMode'],
                              eventDate: a['eventDate'],
                              eventTime: a['eventTime'],
                              eventDeadline: a['eventDeadline'],
                              eventImageUrl: a['eventImageUrl'],
                              eventLinks: List<Map<String, String>>.from(a['eventLinks']),
                            ),
                          ),
                        );
                        await markAsSeen(index);
                      },
                      child: badges.Badge(
                        showBadge: a['isNew'],
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red,
                          padding: const EdgeInsets.all(4),
                        ),
                        position: badges.BadgePosition.topEnd(top: 4, end: 4),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a['message'],
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Event: ${a['eventName']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    a['date'],
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
