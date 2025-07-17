import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MovieApp());

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List movies = [];
  String searchQuery = "marvel";

  @override
  void initState() {
    super.initState();
    loadCachedData();
    fetchMovies(searchQuery);
  }

  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cachedMovies');
    if (cached != null) {
      setState(() {
        movies = json.decode(cached)['Search'] ?? [];
      });
    }
  }

  Future<void> fetchMovies(String query) async {
    final url = Uri.parse('https://omdbapi.com/?s=$query&apikey=35882e11');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == "True") {
        setState(() {
          movies = data['Search'];
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cachedMovies', json.encode(data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

return Scaffold(
  key: _scaffoldKey,
  drawer: Drawer(
    backgroundColor: Colors.grey[900],
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.black87),
          child: Text('Movie App', style: TextStyle(fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.refresh, color: Colors.white),
          title: Text('Refresh'),
          onTap: () {
            fetchMovies(searchQuery);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.white),
          title: Text('About'),
          onTap: () {
            showAboutDialog(context: context, applicationName: "Movie App");
          },
        ),
      ],
    ),
  ),
 
appBar: AppBar(
   automaticallyImplyLeading: false,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Browse", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 2),
      Text("Movies", style: TextStyle(fontSize: 12, color: Colors.grey[300])),
    ],
  ),
  actions: [
    Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
  ],
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            setState(() => searchQuery = value);
            fetchMovies(value);
          }
        },
      ),
    ),
  ),
),

      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: movies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(imdbID: movie['imdbID']),
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: movie['Poster'] ?? '',
                            fit: BoxFit.cover,
                            placeholder: (ctx, _) => Container(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(movie['Title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(movie['Year'] ?? '', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final String imdbID;
  MovieDetailScreen({required this.imdbID});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetails;

  @override
  void initState() {
    super.initState();
    loadCachedDetail();
    fetchMovieDetail();
  }

  Future<void> loadCachedDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(widget.imdbID);
    if (cached != null) {
      setState(() {
        movieDetails = json.decode(cached);
      });
    }
  }

  Future<void> fetchMovieDetail() async {
    final url = Uri.parse('https://omdbapi.com/?i=${widget.imdbID}&apikey=35882e11');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == "True") {
        setState(() {
          movieDetails = data;
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(widget.imdbID, json.encode(data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movieDetails == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: movieDetails?['Poster'] ?? '',
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.4)), // Darken image
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  color: Colors.black.withOpacity(0.6),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movieDetails?['Title'] ?? '',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text("📝 Plot: ${movieDetails?['Plot']}", style: TextStyle(color: Colors.white)),
                        SizedBox(height: 10),
                        Text("🎬 Director: ${movieDetails?['Director']}", style: TextStyle(color: Colors.white70)),
                        Text("🎭 Genre: ${movieDetails?['Genre']}", style: TextStyle(color: Colors.white70)),
                        Text("⭐ Actors: ${movieDetails?['Actors']}", style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
