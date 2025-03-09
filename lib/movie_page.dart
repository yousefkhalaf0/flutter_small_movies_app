import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieDetailPage extends StatelessWidget {
  final Map movie;
  final Map<int, String> categories;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    List<String> movieGenres =
        (movie['genre_ids'] as List<dynamic>?)
            ?.map((id) => categories[id as int] ?? 'Unknown')
            .toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://image.tmdb.org/t/p/w500${movie['backdrop_path']}",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: 250),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            movie['title'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 35,
                            child: IconButton(
                              icon: Icon(Icons.bookmark_border, size: 30),
                              onPressed: () {},
                              color: Color(0xffFFC319),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
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
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children:
                            movieGenres.map((genre) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Chip(
                                  side: BorderSide(color: Color(0xffDBE3FF)),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: -2,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  label: Text(genre),
                                  backgroundColor: Color(0xffDBE3FF),
                                  labelStyle: TextStyle(
                                    fontSize: 10,
                                    height: 0.0,
                                    color: Color(0xff88A4E8),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          MovieInfoTile(
                            title: "Length",
                            value: "${movie['runtime'] ?? 'N/A'} min",
                          ),
                          MovieInfoTile(
                            title: "Language",
                            value:
                                movie['original_language']
                                    .toUpperCase(),
                          ),
                          MovieInfoTile(
                            title: "Rating",
                            value: movie['vote_average'] >= 7 ? "PG-13" : "PG",
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        movie['overview'] ?? 'No description available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Cast",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 35,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                padding: WidgetStatePropertyAll<EdgeInsets>(
                                  EdgeInsets.all(10),
                                ),
                                side: WidgetStatePropertyAll(
                                  BorderSide(
                                    color: Color(0xffE5E4EA),
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                elevation: WidgetStatePropertyAll(20),
                              ),
                              child: const Text(
                                "See more",
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 0,
                                  color: Color(0xffAAA9B1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchTheStaff(
                          movie['id'],
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              "Failed to load cast",
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text(
                              "No cast available",
                            );
                          } else {
                            return SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final cast = snapshot.data![index];
                                  return CastCard(
                                    imageUrl:
                                        "https://image.tmdb.org/t/p/w200${cast['profile_path']}",
                                    name: cast['name'],
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//custom widgets
class MovieInfoTile extends StatelessWidget {
  final String title;
  final String value;

  const MovieInfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 14, color: Color(0xff9C9C9C)),
          ),
          SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CastCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const CastCard({super.key, required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 70,
                );
              },
            ),
          ),
          SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchTheStaff(int movieId) async {
  const String apiKey = "aec7a120efc0f2607c66f43ac96e5187";
  final response = await http.get(
    Uri.parse(
      "https://api.themoviedb.org/3/movie/$movieId/credits?language=en-US&api_key=$apiKey",
    ),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['cast'] != null) {
      return (data['cast'] as List<dynamic>)
          .take(6)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      return [];
    }
  } else {
    throw Exception("Failed to load data from TMDb API");
  }
}
