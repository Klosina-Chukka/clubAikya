import 'package:clubaikya/screens/eventselection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:url_launcher/url_launcher.dart';

  class ClubDetailPage extends StatelessWidget {
  final String clubName;
  final String clubDescription;
  final String clubLogo;
  final List<Map<String, String>> pastEvents;
  final String? instagramLink;
  final String? websiteLink;

  const ClubDetailPage({
  super.key,
  required this.clubName,
  required this.clubDescription,
  required this.clubLogo,
  required this.pastEvents,
  this.instagramLink,
  this.websiteLink,
  });

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(clubName),
        backgroundColor: Color(0xff75bdc4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(clubLogo),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    clubName,
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
              clubDescription,
              style: const TextStyle(fontSize: 16),
            ),

            // ======= ADD YOUR SOCIAL LINKS BLOCK HERE =======
            if (instagramLink != null || websiteLink != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Follow Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  if (instagramLink != null)
                    if (instagramLink != null)
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(instagramLink!)),
                        icon: FaIcon(FontAwesomeIcons.instagram),
                        label: Text("Instagram"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                  if (websiteLink != null)
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(websiteLink!)),
                      icon: Icon(Icons.language),
                      label: Text("Official Website"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            // ======= END SOCIAL LINKS BLOCK =======

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Previous Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
  ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(), // because page already scrolls
  padding: const EdgeInsets.all(5),
  itemCount: pastEvents.length,
  itemBuilder: (context, index) {
  final event = pastEvents[index];
  return Padding(
  padding: const EdgeInsets.symmetric(vertical: 5), // space between cards
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
  ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.asset(
  event['image']!, // your event image
  width: double.infinity,
  height: 150,
  fit: BoxFit.cover,
  ),
  ),
  const SizedBox(height: 10),
  Text(
  event['name']!,
  style: const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  ),
  ),
  const SizedBox(height: 8),
  Container(
  height: 60, // height for scrollable description
  child: SingleChildScrollView(
  physics: BouncingScrollPhysics(),
  child: Text(
  event['info']!,
  style: const TextStyle(
  fontSize: 14,
  color: Colors.black87,
  ),
  ),
  ),
  ),
  
  ],
  ),
  ),
  ),
  );
  },
    ),
   ], ),],),),
     floatingActionButton: FloatingActionButton(
    onPressed: () {
      // TODO: Navigate to schedule event page or show bottom sheet
      Navigator.push(context, MaterialPageRoute(builder: (context) => ClubPage(clubName: clubName)));
    },
    backgroundColor: Color(0xff75bdc4),
    child: Icon(Icons.add), // You can use Icons.add or other icons too
    tooltip: 'Schedule Event',
  ),
   );
  }
  }