import 'package:clubaikya/screens/EventPage.dart';
import 'package:clubaikya/screens/eventselection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:clubaikya/screens/PostannouncementPage.dart';
class ClubDetailPage extends StatefulWidget {
  final String clubName;
  final String clubDescription;
  final String clubLogo;
  final String? instagramLink;
  final String? websiteLink;
  final token;

  const ClubDetailPage({
    super.key,
    this.token,
    required this.clubName,
    required this.clubDescription,
    required this.clubLogo,
    this.instagramLink,
    this.websiteLink,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  List<dynamic> events = [];
  bool isLoading = true;
  String userRole = '';
   bool _isFabExpanded = false;
  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchRole();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse(
        'https://28583fa5cdb0.ngrok-free.app/api/clubs/${widget.clubName}/events');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          events = jsonData['events'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

Future<void> fetchRole() async {
  try {
    if (widget.token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No token found. Please log in again.")),
      );
      return;
    }

    final url = Uri.parse(
        'https://28583fa5cdb0.ngrok-free.app/profile');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 &&
        data != null &&
        data['success'] == true &&
        data['user'] != null &&
        data['user']['role'] != null) {
      setState(() {
        userRole = data['user']['role'];
        isLoading = false;
      });
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch role');
    }
  } catch (err) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${err.toString()}')),
    );
  }
}



  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text(widget.clubName),
      backgroundColor: const Color(0xff75bdc4),
    ),
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(widget.clubLogo),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.clubName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.clubDescription,
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.instagramLink != null || widget.websiteLink != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Follow Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  if (widget.instagramLink != null)
                    ElevatedButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse(widget.instagramLink!)),
                      icon: const FaIcon(FontAwesomeIcons.instagram),
                      label: const Text("Instagram"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  if (widget.websiteLink != null)
                    ElevatedButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse(widget.websiteLink!)),
                      icon: const Icon(Icons.language),
                      label: const Text("Official Website"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              'Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                    ? const Text("No events found.")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventPage(
                                      eventTitle: event['title'] ?? 'No Title',
                                      eventDescription: event['description'] ?? 'No Description',
                                      eventLocation: event['location'] ?? 'No Location',
                                      eventMode: event['mode'] ?? 'Not specified',
                                      eventDate: event['date']?.toString().substring(0, 10) ?? 'Unknown Date',
                                      eventTime: event['time'] ?? 'Unknown Time',
                                      eventDeadline: event['registrationDeadline']?.toString().substring(0, 10) ?? 'No Deadline',
                                      eventImageUrl: event['imageUrl'] ?? '',
                                      eventLinks: (event['associatedLinks'] as List<dynamic>)
                                          .map((link) => {
                                                'label': link['label'].toString(),
                                                'url': link['url'].toString(),
                                              })
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (event['imageUrl'] != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            event['imageUrl'],
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      Text(
                                        event['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        event['description'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (event['date'] != null)
                                        Text(
                                          'Date: ${event['date'].toString().substring(0, 10)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              onLongPress: () async {
  if (userRole != 'Admin') return;

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Event"),
      content: const Text("Are you sure you want to delete this event?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    final eventId = event['_id']; // 👈 this is the MongoDB ID
    final url = Uri.parse("https://28583fa5cdb0.ngrok-free.app/api/events/$eventId");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        events.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete event")),
      );
    }
  }
},
                            ),
                          );
                        },
                      )
            ],
          ),
        ),
        if (userRole == 'Admin')
        if (_isFabExpanded)
  Positioned.fill(
    child: GestureDetector(
      onTap: () {
        setState(() {
          _isFabExpanded = false;
        });
      },
      child: Container(
        color: Colors.black54, // Semi-transparent black
      ),
    ),
  ),
  Positioned(
    bottom: 16,
    right: 16,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _isFabExpanded ? 1.0 : 0.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: _isFabExpanded ? 1.0 : 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: const Text('Create Event', style: TextStyle(color: Colors.black)),
        ),
        FloatingActionButton(
          heroTag: 'event',
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClubPage(
                  clubName: widget.clubName,
                  token: widget.token,
                ),
              ),
            );
          },
          elevation: 6,
          child: const Icon(Icons.event, color: Color(0xff75bdc4)),
        ),
      ],
                ),
                const SizedBox(height: 10),
                Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: const Text('Post Announcement', style: TextStyle(color: Colors.black)),
        ),
        FloatingActionButton(
          heroTag: 'announcement',
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostAnnouncementPage(
                  clubName: widget.clubName,
                ),
              ),
            );
          },
          elevation: 6,
          child: const Icon(Icons.announcement, color: Color(0xff75bdc4)),
        ),
      ],
    ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: 'main',
          backgroundColor: const Color(0xff75bdc4),
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
          },
          elevation: 8,
          child: Icon(_isFabExpanded ? Icons.close : Icons.add),
        ),
      ],
    ),
  ),

      ],
    ),
  );
}
}
