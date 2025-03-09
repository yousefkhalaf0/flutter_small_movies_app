import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies_app/movie_page.dart';

const String apiKey =
    "aec7a120efc0f2607c66f43ac96e5187";
const String baseUrl = "https://api.themoviedb.org/3";
const String imageUrl = "https://image.tmdb.org/t/p/w500";

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});
  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  Map<int, String> genres = {};
  List nowPlayingMovies = [];
  List popularMovies = [];
  int _currentNowShowingCount = 3;
  bool _isNowShowingExpanded = true;
  int _currentPopularCount = 6;
  bool _isPopularExpanded = true;

  @override
  void initState() {
    super.initState();
    fetchGenres().then((_) => fetchMovies());
  }

  Future<void> fetchGenres() async {
    final response = await http.get(
      Uri.parse("$baseUrl/genre/movie/list?api_key=$apiKey&language=en"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        genres = {for (var genre in data['genres']) genre['id']: genre['name']};
      });
    } else {
      debugPrint("Failed to fetch genres: ${response.statusCode}");
    }
  }

  Future<void> fetchMovies() async {
    final nowPlayingResponse = await http.get(
      Uri.parse("$baseUrl/movie/now_playing?api_key=$apiKey"),
    );
    final popularResponse = await http.get(
      Uri.parse("$baseUrl/movie/popular?api_key=$apiKey"),
    );

    if (nowPlayingResponse.statusCode == 200 &&
        popularResponse.statusCode == 200) {
      setState(() {
        nowPlayingMovies = json.decode(nowPlayingResponse.body)['results'];
        popularMovies = json.decode(popularResponse.body)['results'];
      });
    } else {
      debugPrint(
        "Failed to fetch movies: ${nowPlayingResponse.statusCode}, ${popularResponse.statusCode}",
      );
    }
  }

  List<String> getGenresForMovie(List<int> genreIds) {
    final movieGenres = genreIds.map((id) => genres[id] ?? 'Unknown').toList();
    return movieGenres;
  }

  void _expandNowShowing() {
    setState(() {
      if (_currentNowShowingCount + 3 >= nowPlayingMovies.length) {
        _currentNowShowingCount = nowPlayingMovies.length;
        _isNowShowingExpanded = false;
      } else {
        _currentNowShowingCount += 3;
      }
    });
  }
  void _collapseNowShowing() {
    setState(() {
      _currentNowShowingCount = 3;
      _isNowShowingExpanded = true;
    });
  }

  void _expandPopular() {
    setState(() {
      if (_currentPopularCount + 3 >= popularMovies.length) {
        _currentPopularCount = popularMovies.length;
        _isPopularExpanded = false;
      } else {
        _currentPopularCount += 3;
      }
    });
  }
  void _collapsePopular() {
    setState(() {
      _currentPopularCount = 6;
      _isPopularExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "FilmKu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/Menu.png"),
        ),
        actions: [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              "Now Showing",
              _isNowShowingExpanded,
              _expandNowShowing,
              _collapseNowShowing,
            ),
            SizedBox(height: 16),
            _buildNowShowingList(),
            SizedBox(height: 16),
            _buildSectionTitle(
              "Popular",
              _isPopularExpanded,
              _expandPopular,
              _collapsePopular,
            ),
            SizedBox(height: 16),
            _buildPopularList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }


  //custom widgets
  Widget _buildSectionTitle(
    String title,
    bool isExpanded,
    VoidCallback onExpand,
    VoidCallback onCollapse,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 80,
          height: 35,
          child: OutlinedButton(
            onPressed: isExpanded ? onExpand : onCollapse,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(10)),
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: Color(0xffE5E4EA),
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              elevation: WidgetStatePropertyAll(20),
            ),
            child: Text(
              isExpanded ? "See more" : "See less",
              style: TextStyle(
                fontSize: 12,
                height: 0,
                color: Color(0xffAAA9B1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNowShowingList() {
    final visibleMovies =
        nowPlayingMovies.take(_currentNowShowingCount).toList();
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visibleMovies.length,
        itemBuilder: (context, index) {
          final movie = visibleMovies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  Widget _buildPopularList() {
    final visibleMovies = popularMovies.take(_currentPopularCount).toList();
    return Column(
      children:
          visibleMovies.map((movie) => _buildPopularMovieTile(movie)).toList(),
    );
  }

  Widget _buildMovieCard(Map movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MovieDetailPage(movie: movie, categories: genres),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: "$imageUrl${movie['poster_path']}",
                height: 190,
                width: 150,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 8),
            Text(
              movie['title'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Icon(Icons.star, color: Color(0xffFFC319), size: 16),
                SizedBox(width: 4),
                Text(
                  "${movie['vote_average']}/10 IMDb",
                  style: TextStyle(color: Color(0xff9C9C9C)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMovieTile(Map movie) {
    final genreIds = List<int>.from(movie['genre_ids'] ?? []);
    final movieGenres = getGenresForMovie(genreIds);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MovieDetailPage(movie: movie, categories: genres),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CachedNetworkImage(
                imageUrl: "$imageUrl${movie['poster_path']}",
                height: 140,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xffFFC319), size: 16),
                      SizedBox(width: 4),
                      Text(
                        "${movie['vote_average']}/10 IMDb",
                        style: TextStyle(color: Color(0xff9C9C9C)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        movieGenres.map((genre) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SizedBox(
                              height: 40,
                              child: Chip(
                                side: BorderSide(color: Color(0xffDBE3FF)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: -2,
                                ),
                                visualDensity:
                                    VisualDensity
                                        .compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap,
                                label: Text(genre),
                                backgroundColor: Color(0xffDBE3FF),
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  height: 0.0,
                                  color: Color(0xff88A4E8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, weight: 50),
                      SizedBox(width: 4),
                      Text(
                        "${movie['runtime'] ?? '1h 49m'}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Color(0xff110E47),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset("assets/Bookmark.png"),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/Shape.png", width: 20),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ""),
      ],
    );
  }
}
