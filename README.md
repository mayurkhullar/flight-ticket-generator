# ✈️ Flight Ticket Generator

A comprehensive Flutter application for generating flight tickets with PDF export functionality, built with Firebase backend and GetX state management.

## 🚀 Features

### Core Functionality
- **✈️ Ticket Creation**: Manual form-based ticket creation with comprehensive flight details
- **📄 PDF Generation**: Clean, professional PDF tickets with airline logos
- **🗂️ Ticket History**: View, edit, delete, and re-export tickets
- **🛠️ Flight Assets Manager**: Upload and manage airline logos
- **🧠 Flight Data Learning**: Auto-complete suggestions from previously entered flight data

### Technical Features
- **🔥 Firebase Integration**: Firestore for data storage, Firebase Storage for logos
- **📱 Cross-Platform**: Web and Android support
- **🎨 Clean UI**: Minimalist black/white/gray design
- **📋 Form Validation**: IATA code and time format validation
- **💾 Local PDF Storage**: Generated PDFs saved locally (not in Firebase)

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter (Web + Android)
- **State Management**: GetX
- **Backend**: Firebase (Firestore + Storage)
- **PDF Generation**: `pdf` package
- **Storage**: Local PDF files

### Project Structure
```
lib/
├── controllers/          # GetX controllers for state management
│   ├── saved_flights_controller.dart
│   └── ticket_form_controller.dart
├── models/              # Data models
│   ├── flight_model.dart
│   ├── saved_flight_model.dart
│   └── ticket_model.dart
├── services/            # Service classes
│   └── pdf_service.dart
├── theme/               # App theming and configuration
│   └── app_config.dart
├── utils/               # Utility classes
│   └── pdf_generator.dart
├── views/               # UI screens
│   ├── home_view.dart
│   ├── create_ticket/
│   ├── saved_data/
│   └── tickets/
└── main.dart           # App entry point
```

## 📋 Core Features Detail

### 1. Ticket Creation
- **Fields**: Airline Name, Code, Flight Number, From/To Airport, Times, Terminal, Category
- **Multiple Passengers**: Add/remove passenger entries
- **Stopovers**: Optional stopover management
- **Auto-generated PNR**: 6-digit alphanumeric identifier
- **Validations**: IATA codes, 24-hour time format

### 2. PDF Generation
- **Clean Layout**: Minimal, professional design
- **Logo Integration**: Fetches airline logos from Firebase Storage
- **Complete Details**: PNR, flight info, passengers, notes
- **Local Storage**: Saves as `ticket_<pnr>.pdf`
- **Overwrite Support**: Updates existing PDFs on edit

### 3. Ticket Management
- **History View**: List all created tickets
- **Actions**: View, Edit, Delete, Export PDF
- **Real-time Updates**: Firebase Firestore integration
- **Search & Filter**: Easy ticket discovery

### 4. Flight Assets Manager
- **Logo Upload**: PNG logos tagged with airline codes
- **Storage Path**: `airline_logos/{airlineCode}.png`
- **Duplicate Prevention**: Checks for existing codes
- **Metadata Storage**: Name, code, timestamp in Firestore

### 5. Flight Data Learning
- **Auto-learning**: Saves flight combinations from new tickets
- **Smart Suggestions**: Auto-complete from saved flight data
- **Logo Matching**: Automatic airline logo association

## 🔧 Setup & Installation

### Prerequisites
- Flutter SDK (3.7.2+)
- Firebase project with Firestore and Storage enabled
- Android Studio / VS Code

### Firebase Setup
1. Create a Firebase project
2. Enable Firestore Database
3. Enable Firebase Storage
4. Download `google-services.json` to `android/app/`
5. Configure Firebase rules for your use case

### Installation Steps
```bash
# Clone the repository
git clone <repository-url>
cd flight_tickets

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Configuration
The app uses these Firebase collections:
- `tickets`: Stores ticket data
- `saved_flights`: Stores learned flight data
- `airline_logos`: Stores logo metadata

Storage structure:
- `airline_logos/{airlineCode}.png`: Airline logo files

## 🎨 Design Philosophy

### UI/UX Principles
- **Minimalist Design**: Clean black, white, and gray color scheme
- **Functionality First**: Focus on core features over visual complexity
- **Responsive Layout**: Works on both web and mobile
- **Intuitive Navigation**: Clear user flow between features

### Color Scheme
- **Background**: White (#FFFFFF)
- **Surface**: Light Gray (#F9F9F9)
- **Text**: Black (#000000) / Medium Gray (#666666)
- **Accent**: Dark Gray (#444444)
- **Actions**: Red for delete, Green for success

## 📱 Platform Support

### Android
- **Package**: `com.kholidaymaps.flight_tickets`
- **Min SDK**: As per Flutter requirements
- **Features**: Full functionality including PDF generation

### Web
- **Responsive**: Adapts to different screen sizes
- **PDF Support**: Browser-based PDF generation
- **Firebase**: Full web SDK integration

## 🔐 Security & Privacy

### Data Storage
- **Tickets**: Stored in Firestore with user-specific access
- **PDFs**: Generated and stored locally only
- **Logos**: Public storage with controlled upload

### Validation
- **Input Validation**: IATA codes, time formats
- **File Validation**: Image type checking for logos
- **Error Handling**: Comprehensive error management

## 🚀 Deployment

### Android Build
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### Web Build
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- GetX for state management
- PDF package contributors

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

**Built with ❤️ using Flutter & Firebase**
