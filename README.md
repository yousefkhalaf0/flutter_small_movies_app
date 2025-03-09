# Movie App

A simple Flutter app that displays a list of now-playing and popular movies using the TMDb API. Users can view movie details, including genres, ratings, and cast information.

## Features
- **Now Playing Movies**: Displays a list of movies currently in theaters.
- **Popular Movies**: Shows a list of popular movies.
- **Movie Details**: Provides detailed information about a selected movie, including genres, ratings, runtime, and cast.
- **Responsive Design**: Works seamlessly on both mobile and tablet devices.

## Screenshots
   ![image](https://github.com/user-attachments/assets/1420a1b1-cab0-44bb-bc77-4112bf445e54)
   ![image](https://github.com/user-attachments/assets/994e79a7-0332-4096-bbe3-7add37609371)
   ![image](https://github.com/user-attachments/assets/b378b822-5304-4715-976a-d1c389d9111c)
   ![image](https://github.com/user-attachments/assets/5d526a85-49a9-4049-a2b1-1b9332859f72)

## Packages Used
- **[http](https://pub.dev/packages/http)**: ^0.13.3  
  Used for making HTTP requests to the TMDb API to fetch movie data.
- **[cached_network_image](https://pub.dev/packages/cached_network_image)**: ^3.0.0  
  Used to load and cache movie poster images from the web.

## Setup Instructions

### Prerequisites
- Flutter SDK installed (version 3.0.0 or higher).
- An API key from [The Movie Database (TMDb)](https://www.themoviedb.org/).

### Steps to Run the App
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yousefkhalaf0/flutter_small_movies_app.git
   cd movie-app
   ```

2. **Add Your TMDb API Key**:
   - Open the `home_page.dart` file.
   - Replace the placeholder `apiKey` with your actual TMDb API key:
     ```dart
     const String apiKey = "your_api_key_here";
     ```

3. **Install Dependencies**:
   Run the following command to install the required packages:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   Connect an emulator or physical device and run the app:
   ```bash
   flutter run
   ```

## Folder Structure
```
movie-app/
├── lib/
│   ├── main.dart                # Entry point of the app
│   ├── home_page.dart           # Home screen with movie lists
│   ├── movie_page.dart          # Movie details screen
├── android/                     # Android-specific files
├── ios/                         # iOS-specific files
├── pubspec.yaml                 # Dependencies and app metadata
└── README.md                    # This file
```

---

## API Used
This app uses the [The Movie Database (TMDb) API](https://developers.themoviedb.org/3) to fetch movie data. You can sign up for a free API key on their website.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
