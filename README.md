# 🏟️ VenueVantage

**VenueVantage** is a premium, AI-driven digital companion designed for large-scale sporting and entertainment venues. It bridges the gap between digital convenience and physical stadium experiences by providing real-time wayfinding, in-seat commerce, live crowd density tracking, and proactive event notifications.

---

## 🎯 Chosen Vertical: Live Sports & Entertainment Venues
The chosen vertical for this project is the **Live Sports and Entertainment industry**, specifically focusing on the in-stadium fan experience. 

Large-scale events inherently suffer from poor crowd flow, long wait times for concessions, and difficult navigation. VenueVantage solves these friction points by transforming the attendee's smartphone into a personalized, hyper-local stadium guide.

---

## 🚀 Approach and Logic
Our approach is built around **"Contextual Proximity and Smart Routing."** We believe the fan experience is maximized when they spend less time in lines and more time in their seats enjoying the event.

**Core Logic Pillars:**
1. **Dynamic Wayfinding:** Standard maps are static. VenueVantage queries the Google Maps and Places APIs to continuously calculate the "Best Exit" and shortest routes based on real-time pedestrian travel time, not just physical distance.
2. **Context-Aware Commerce:** The application asks for the user's specific seat information during onboarding. This acts as an anchor point, allowing the app to calculate wait times for nearby concessions and enable direct-to-seat delivery.
3. **AI-Driven Assistance:** Navigating a massive stadium can be overwhelming. We integrated a conversational AI assistant (powered by Google's Generative AI) that acts as a concierges, answering questions like "Where is the nearest medical aid?" or "Which exit is fastest right now?" based on structured venue data.
4. **Predictive Crowd Management:** By aggregating passive data points (simulated via Firestore streams), the app provides a "Live Crowd Density" pulse, encouraging users to defer moving during peak rush times.

---

## ⚙️ How the Solution Works
VenueVantage is built on a modern **Flutter** frontend, leveraging a reactive **Provider-based state management** system, backed by **Firebase/Firestore** for real-time data sync.

1. **Authentication:** Users can sign in securely via Google OAuth or opt for a frictionless "Guest" mode.
2. **Onboarding & Localization:** Upon entry, users input their Section, Row, and Seat. This data is synced to Firestore and locally via `SharedPreferences`.
3. **The Dashboard (Home Screen):** 
   - A reactive UI listens to `AppState` to render live data.
   - The **Live Stats** section constantly monitors crowd density and temperature (via OpenWeather API).
   - The **Smart Exit** card constantly queries the Maps Directions API against all available stadium exits to recommend the fastest path out.
4. **Google Maps Integration:** The app uses the Google Maps SDK to render an interactive map (`MapScreen`) loaded with custom Points of Interest (POIs) such as restrooms, exits, and food stalls.
5. **In-Seat Ordering:** Users can browse menus, build a cart, and place orders. A local timer handles mock order-tracking steps (Placed -> Preparing -> On the Way -> Delivered). 

---

## 💡 Assumptions Made
During development, several key assumptions were made to scope the project effectively:

1. **Stadium Data Availability:** We assumed that the governing venue provides exact Latitude/Longitude coordinates for all primary exits, which are currently hardcoded in `venue_data.dart`.
2. **Network Reliability:** We assumed that a large-scale venue has sufficient Wi-Fi, 5G, or local network mesh capabilities to support real-time WebSocket/Firestore data streams. If offline, the app degrades gracefully by relying on `SharedPreferences` and initial seed data.
3. **API Integrity:** The dynamic routing assumes the Google Maps Directions API is aware of pedestrian pathways within and immediately surrounding the stadium blueprint.
4. **Mocked Services:** Since we cannot attach to a live POS (Point of Sale) stadium system yet, the "Wait Times", "In-Seat Delivery logistics", and actual "Live Crowd Tracking" values are generated via randomized simulated data streams on Firestore. 
5. **CORS on Web:** It is assumed that the app is consumed as a Mobile Application. Running on Flutter Web directly in the browser encounters CORS errors when directly pinging Google APIs from the client device; for a web-only production deployment, a server-side proxy would be implemented.

---



### 1. Code Quality (Structure, Readability, Maintainability)
- **Modular Architecture:** The codebase follows a strict separation of concerns. UI, Providers (State), Models, and Services are decoupled. Massive widgets like `HomeScreen` are broken down using custom stateless components (`_QuickAction`, `_StatCard`).
- **Clean State Management:** Utilizes Provider (`ChangeNotifier`) for reactive and predictable state propagation without deeply nested callbacks or "prop-drilling."
- **Consistent Styling:** A unified `AppTheme` class manages all colors, gradients, and radiuses globally, making sweeping design changes trivial.
- **Thorough Documentation:** Public classes, methods, and complex widget trees include DartDoc `///` documentation for seamless developer onboarding.

### 2. Security (Safe and Responsible Implementation)
- **Environment Variables:** API keys (like Google Maps/Places) are strictly kept out of source code and injected safely via `flutter_dotenv` (`.env`).
- **Input Sanitization:** The onboarding forms (Seat Selection) strictly enforce active Regex validation ensuring alphanumeric input, preventing nasty data injections.
- **Fail-Safe API Wrappers:** All Network/API requests are wrapped in robust `try/catch` blocks. If Google Cloud calls fail (or quotas are exceeded), the UI gracefully falls back to cached UI mock data without application crashes. 

### 3. Efficiency (Optimal Use of Resources)
- **Smart Re-renders:** Flutter build trees are heavily optimized. Extensive use of `const` constructors ensures Flutter limits the widget diffing overhead during UI animations. 
- **Targeted State Rebuilds:** Usage of `Selector` and specific `ChangeNotifier` updates prevent the entire application from rebuilding when isolated data (like a cart item increment) changes.
- **Asynchronous Optimization:** Heavy network requests (Maps Directions, Weather, Firestore snapshots) run asynchronously without blocking the main UI thread.

### 4. Testing (Validation of Functionality)
- **Unit Testing Suite:** Contains a robust set of tests validating core Logic. `app_state_test.dart` mathematically validates Cart operations, SharedPreferences loading, and theme toggling.
- **Mocked Dependencies:** `auth_state_test.dart` utilizes Mock Dependency Injection (`MockAuthService`), proving the architecture supports isolated logic testing independent of live Firebase backends.

### 5. Accessibility (Inclusive and Usable Design)
- **Semantic Wrappers:** Critical touch/interactive targets (like "Continue with Google", map routing buttons, or quick actions) are wrapped in specialized Flutter `Semantics` widgets (`button: true`, `label: "..."`), providing immediate support for screen-readers natively.
- **Legibility:** UI enforces high-contrast text ratios for `AppTheme.dark` and utilizes scalable fonts (`GoogleFonts.inter`) for readability outdoors.
- **Touch Targets:** All clickable IconButtons and GestureDetectors exceed the minimum touch target requirement (48x48) ensuring ease of use while moving.

### 6. Google Services (Meaningful Integration)
- **Google Maps Platform:** Deeply integrated Maps SDK driving the core "Smart Routing" utility. Leverages `Places API` for concession discovery and `Directions API` to dynamically calculate pedestrian exit ETAs.
- **Google Generative AI:** Integrated a conversational stadium assistant powered by Gemini. By supplying system prompts with venue context, users can dynamically ask real-time questions (e.g., "Where is Medical?").
- **Firebase Ecosystem:** Implements Firebase Authentication (Google OAuth), Cloud Firestore for reactive live telemetry (Wait Times, Orders), and is staged for FCM Push Notifications.

---
*Built with Flutter, Firebase, and Google Cloud APIs.*
