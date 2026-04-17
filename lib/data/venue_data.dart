import '../models/venue.dart';

final Venue currentVenue = Venue(
  name: "Dr D.Y. Patil Stadium",
  lat: 19.0423934,
  lng: 73.0265071,
  placeId: "ChIJWyUeO8XD5zsRM4IRQjq3qD8",
  imagePath: "assets/images/stadium.png",
  nwLat: 19.0438,
  nwLng: 73.0248,
  seLat: 19.0410,
  seLng: 73.0282,

  // 🔥 YOU DEFINE EXITS (Google doesn’t give this)
  exits: [
    {
      "name": "Exit A",
      "lat": 19.0435,
      "lng": 73.0275,
    },
    {
      "name": "Exit B",
      "lat": 19.0415,
      "lng": 73.0255,
    },
    {
      "name": "Exit C",
      "lat": 19.0420,
      "lng": 73.0285,
    },
  ],
);
