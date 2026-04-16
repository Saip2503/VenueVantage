# VenueVantage: Smart Stadium Companion

VenueVantage is a premium, mobile-first web application designed to drastically improve the attendee experience at large-scale sporting and events venues. Providing interactive wayfinding, live crowd density metrics, in-seat ordering, contextual AI assistance, and real-time emergency routing, VenueVantage solves the chaos of massive crowds.

## 🏆 Chosen Challenge Vertical
**Smart Venue & Fan Experience Optimization**
We focused on solving pain points within large venues: finding seats, dealing with long food queues, locating restrooms without massive lines, and staying informed during emergencies or special alerts.

## 🧠 Approach & Logic
Our solution operates on a centralized reactive architecture using Flutter and Provider framework:
- **State Management (`AppState`)**: Serves as the single source of truth for the user's location (seat), cart, order status, and real-time venue metrics.
- **Contextual Decision Making**: The "smart, dynamic assistant" feature leverages the **Gemini API** to provide conversational support. Instead of generic assistance, the Gemini model is dynamically prompted with the user's *exact seat location*, current *venue wait times*, and *crowd levels* via hidden system instructions. This ensures that when a user asks "Where should I get food?", the AI dynamically calculates the answer based on real-time data relative to their specific section.
- **Dynamic Routing (AuthGate)**: A custom AuthGate instantly evaluates Firebase Auth streams and local SharedPreferences to seamlessly route the user without reloading, preserving the deep-app state.

## 🚀 Meaningful Use of Google Services
We heavily utilized the Google Cloud Platform and Firebase ecosystems to ensure secure, resilient operations:
- **Firebase Authentication (Google Sign-In)**: Frictionless onboard for users via their existing Google profiles.
- **Cloud Firestore**: Real-time listeners bind directly to our UI. Order checkouts write securely to `users/{uid}/orders`, updating the live history screen instantly using `snapshots()`.
- **Firebase Hosting**: High-speed, cached static delivery of the Flutter web compilation.
- **Google Cloud Run & Cloud Build**: Multi-stage Docker containerization built automatically in the cloud, serving high-throughput requests gracefully.
- **Google Generative AI (Gemini Flash)**: Our smart assistant powers real-time fan questions by blending Google's LLM capabilities with our real-time venue data streams.

## 🏗️ How to Run & Test
### Prerequisites
- Flutter SDK (`^3.8.0`)
- A Firebase Project configured for Web.
- A Google AI Studio API Key (for Gemini).

### Steps
1. Clone the repository.
2. Run `flutter pub get`.
3. Provide your Gemini API key and run the app:
   ```bash
   flutter run -d chrome --dart-define=GEMINI_API_KEY="AIzaSyYourAPIKeyHere..."
   ```

*(Note: If the key is omitted, the AI Assistant falls back to a graceful mock mode for UI evaluation).*

## 📌 Assumptions Made
- Venues have stable 4G/5G or WiFi. If internet drops, Firestore's offline persistence handles caching, while core maps fall back to statically rendered cached zones.
- Seat locations (Section, Row, Seat) can be cleanly mapped to coordinate structures within our internal pathfinding algorithm.
- Users generally remain in their selected seat. Contextual AI and food routing algorithms assume the user's "origin" is their saved seat.

## ✅ Evaluation Focus Met
*   **Code Quality**: Extracted logic into discrete Services, Models, and Providers. Strict linting observed.
*   **Security**: Firestore security rules restrict order history to `request.auth.uid`. No exposed API credentials in source.
*   **Accessibility**: Premium dark-mode interface with high contrast ratios, semantic `Semantics` tags over navigation, and scalable typography (Google Fonts Inter).
