import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';

class EventPage extends StatelessWidget {
  final String eventTitle;
  final String eventDescription;
  final String eventLocation;
  final String eventMode;
  final String eventDate;
  final String eventTime;
  final String eventDeadline;
  final String eventImageUrl;
  final List<Map<String, String>> eventLinks;

  const EventPage({
    super.key,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventLocation,
    required this.eventMode,
    required this.eventDate,
    required this.eventTime,
    required this.eventDeadline,
    required this.eventImageUrl,
    required this.eventLinks,
  });

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(eventImageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF75BDC4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          eventTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showFullImage(context),
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Image.network(
                    eventImageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(19),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(height: 8),
                      Text(
                        eventDescription,
                        style: const TextStyle(fontSize: 19, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow("Location", eventLocation, Icons.location_on_outlined),
                      _buildDetailRow("Mode", eventMode, Icons.computer_outlined),
                      _buildDetailRow("Date", eventDate, Icons.calendar_today_outlined),
                      _buildDetailRow("Time", eventTime, Icons.access_time_outlined),
                      _buildDetailRow("Deadline", eventDeadline, Icons.event_busy_outlined),
                      const SizedBox(height: 20),
                      Text(
                        "Event Links",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      if (eventLinks.isNotEmpty) ...[
  const SizedBox(height: 10),
  ...eventLinks.map((link) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${link['label']}: ",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final Uri url = Uri.parse(link['url']!);
              print(url);
              launchUrl(Uri.parse(link['url']!));
            },
            child: Text(
              link['url']!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    ),
  )),
] else ...[
  const Text(
    "No event links provided",
    style: TextStyle(
      fontSize: 18,
      fontStyle: FontStyle.italic,
      color: Colors.black54,
    ),
  )
]

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 19),
            ),
          )
        ],
      ),
    );
  }
}
