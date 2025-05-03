//import 'package:clubaikya/screens/clubpage.dart';

String? getInstagramLink(String clubName) {
  switch (clubName) {
    case "Coding Club":
      return "https://www.instagram.com/jntuhucesth_coding_club";
    case "Ragavarsha Club":
      return "https://www.instagram.com/raagavarsha.jntuhceh";
    case "Watts Guild Club":
      return "https://www.instagram.com/watts_guild.jntuhucesth";
    case "Film and Videography Club":
      return "https://www.instagram.com/_clickshot";
    case "Photography Club":
      return "https://instagram.com/photoclub";
    case "Elite Feet":
      return "https://instagram.com/elite.feet.jntuhceh";
    case "Art Meraki":
      return "https://www.instagram.com/art_meraki.jntuh";
    case "Environmental Club":
      return "https://instagram.com/environmentalclub";
    default:
      return null;
  }
}

String? getWebsiteLink(String clubName) {
  switch (clubName) {
    case "Coding Club":
      return "https://jntuhceh.ac.in/coding_club";
    case "Ragavarsha Club":
      return "https://jntuhceh.ac.in/ragavarsha_club";
    case "Watts Guild Club":
      return "https://jntuhceh.ac.in/watts_guild_club";
    case "Film and Videography Club":
      return "https://jntuhceh.ac.in/film_and_videography_club";
    case "Photography Club":
      return "https://jntuhceh.ac.in/photography_club";
    case "Elite Feet":
      return "https://jntuhceh.ac.in/elite_feet";
    case "Art Meraki":
      return "https://jntuhceh.ac.in/art_meraki";
    case "Environmental Club":
      return "https://jntuhceh.ac.in/environmental_committee_club";
    default:
      return null;
  }
}
String getClubDescription(String clubName) {
  switch (clubName) {
    case "Coding Club":
      return "Coding Club, established in 2017, aims to foster logical thinking and a passion for coding among students of all programs.We promote regular practice and a strong spirit of competitive programming.";
    case "Ragavarsha Club":
      return "In a club like raghavarsha many students can show their talent to the world through our college as their first stage. As well as studies we will be encouraging people who are into singing.Celebrating cultural rhythms and traditional artistry.";
    case "Watts Guild Club":
      return "The Watts guild club targets in encouraging students to explore the practical possibilities enshelled in development of a mechanical design and manufacturing.A home for electronics and circuit enthusiasts.";
    case "Film and Videography Club":
      return "Lights, camera, creativity! We capture stories.To encourage students in the fields of acting, editing, writing and direction";
    case "Photography Club":
      return "To spread awareness about Photography and its importance.To help students improve their photography and editing skills.Framing moments and painting with light.";
    case "Elite Feet":
      return "This is a beautiful platform for every dancer who lives and breathes dance. Our agenda is to help in increasing one's flexibility, strength, and control throughout the body by learning various techniques, style and characteristics of dance forms.";
    case "Art Meraki":
      return "o create artistic environment in our college and develop an appreciation of art in the student’s community.Our club provides an opportunity to the students to let their imagination run wild and provides them with the site to see the things in a different way.";
    case "Environmental Club":
      return "We gardening club, want to make Awareness among the people and introduce new gardening methods like giving saplings to every department, improve cleaning system, introducing dustbins at crowdy places.";
    default:
      return "Welcome to our club!";
  }
}

List<Map<String, String>> getClubEvents(String clubName) {
  switch (clubName) {
    case "Coding Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/blindcode.jpg',
          'info': 'Blind Code is a unique programming competition where you write code without looking at the screen! Participants are given a coding problem and a limited time to solve it with their screens turned off.'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Code Shuffle is the ultimate coding competition designed to challenge your coding skills, logical thinking, and problem-solving abilities under intense time constraints.'
        },
      ];
    case "Ragavarsha Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Watts Guild Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Film and Videography Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Photography Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Elite Feet":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Art Meraki":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/shuffle.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    case "Environmental Club":
      return [
        {
          'name': 'Blind Code',
          'image': 'assets/events/blindcode.jpg',
          'info': 'A thrilling coding contest where participants code blindfolded!'
        },
        {
          'name': 'Code Shuffle',
          'image': 'assets/events/shuffle.jpg',
          'info': 'Decode shuffled code snippets and race against the clock.'
        },
      ];
    default:
      return [];
  }
}
