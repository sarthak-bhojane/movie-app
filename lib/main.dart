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
    // return Scaffold(
    //   appBar: AppBar(
    //      leading: Icon(Icons.menu),
    //     title: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text("Browse", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    //         SizedBox(height: 2),
    //         Text("Movies", style: TextStyle(fontSize: 12, color: Colors.grey[300])),
    //       ],
    //     ),
       
    //     bottom: PreferredSize(
    //       preferredSize: Size.fromHeight(60),
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: TextField(
    //           style: TextStyle(color: Colors.white),
    //           decoration: InputDecoration(
    //             hintText: 'Search movies...',
    //             hintStyle: TextStyle(color: Colors.white54),
    //             filled: true,
    //             fillColor: Colors.black54,
    //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    //           ),
    //           onSubmitted: (value) {
    //             if (value.isNotEmpty) {
    //               setState(() {
    //                 searchQuery = value;
    //               });
    //               fetchMovies(value);
    //             }
    //           },
    //         ),
    //       ),
    //     ),
    //   ),

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
  // appBar: AppBar(
  //   leading: IconButton(
  //     icon: Icon(Icons.menu),
  //     onPressed: () => _scaffoldKey.currentState?.openDrawer(),
  //   ),
  //   title: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text("Browse", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //       SizedBox(height: 2),
  //       Text("Movies", style: TextStyle(fontSize: 12, color: Colors.grey[300])),
  //     ],
  //   ),
  //   bottom: PreferredSize(
  //     preferredSize: Size.fromHeight(60),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: TextField(
  //         style: TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           hintText: 'Search movies...',
  //           hintStyle: TextStyle(color: Colors.white54),
  //           filled: true,
  //           fillColor: Colors.black54,
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  //         ),
  //         onSubmitted: (value) {
  //           if (value.isNotEmpty) {
  //             setState(() => searchQuery = value);
  //             fetchMovies(value);
  //           }
  //         },
  //       ),
  //     ),
  //   ),
  // ),
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



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:glassmorphism/glassmorphism.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   await Hive.openBox('movieDetails');
//   runApp(MovieApp());
// }

// class MovieApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Movie Browser',
//       theme: ThemeData.dark(useMaterial3: true),
//       home: MovieHome(),
//     );
//   }
// }

// class MovieHome extends StatefulWidget {
//   @override
//   _MovieHomeState createState() => _MovieHomeState();
// }

// class _MovieHomeState extends State<MovieHome> {
//   List movies = [];
//   String searchTerm = 'avengers';
//   bool isLoading = false;

//   final TextEditingController controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedMovies();
//   }

//   Future<void> _loadCachedMovies() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? cached = prefs.getString('cachedMovies');
//     if (cached != null) {
//       setState(() {
//         movies = json.decode(cached);
//       });
//     }
//     _searchMovies(searchTerm);
//   }

//   Future<void> _searchMovies(String search) async {
//     setState(() => isLoading = true);
//     final url = 'https://omdbapi.com/?s=$search&apikey=35882e11';
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final result = json.decode(response.body);
//       if (result['Search'] != null) {
//         setState(() {
//           movies = result['Search'];
//           isLoading = false;
//         });
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('cachedMovies', json.encode(result['Search']));
//       }
//     }
//   }

//   void _openDrawer() {
//     Scaffold.of(context).openDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         backgroundColor: Colors.grey[900],
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               child: Text('Movie Options', style: TextStyle(fontSize: 24)),
//               decoration: BoxDecoration(color: Colors.black),
//             ),
//             ListTile(
//               title: Text('Refresh'),
//               leading: Icon(Icons.refresh),
//               onTap: () {
//                 _searchMovies(searchTerm);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: Text('About'),
//               leading: Icon(Icons.info_outline),
//               onTap: () {
//                 showAboutDialog(context: context, applicationName: "Movie App");
//               },
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         title: Text('Browse'),
//         centerTitle: false,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: CircleAvatar(child: Icon(Icons.person)),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Top Searches', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             SizedBox(height: 10),
//             TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: 'Search Movie...',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () => _searchMovies(controller.text),
//                 ),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             SizedBox(height: 12),
//             isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : Expanded(
//                     child: GridView.builder(
//                       itemCount: movies.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
//                       itemBuilder: (context, index) {
//                         final movie = movies[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => MovieDetailPage(imdbID: movie['imdbID'])),
//                             );
//                           },
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Stack(
//                               children: [
//                                 Image.network(
//                                   movie['Poster'],
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                 ),
//                                 Positioned(
//                                   bottom: 0,
//                                   left: 0,
//                                   right: 0,
//                                   child: Container(
//                                     padding: EdgeInsets.all(6),
//                                     color: Colors.black54,
//                                     child: Text(
//                                       movie['Title'],
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MovieDetailPage extends StatefulWidget {
//   final String imdbID;

//   MovieDetailPage({required this.imdbID});

//   @override
//   _MovieDetailPageState createState() => _MovieDetailPageState();
// }

// class _MovieDetailPageState extends State<MovieDetailPage> {
//   Map? movie;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadMovie();
//   }

//   Future<void> loadMovie() async {
//     var box = Hive.box('movieDetails');
//     if (box.containsKey(widget.imdbID)) {
//       setState(() {
//         movie = box.get(widget.imdbID);
//         loading = false;
//       });
//     } else {
//       final url = 'https://omdbapi.com/?i=${widget.imdbID}&apikey=35882e11';
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           movie = data;
//           loading = false;
//         });
//         box.put(widget.imdbID, data);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: movie == null
//           ? Center(child: CircularProgressIndicator())
//           : Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(
//                   movie!['Poster'] ?? '',
//                   fit: BoxFit.cover,
//                 ),
//                 Positioned(
//                   top: 40,
//                   left: 10,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.black54,
//                     child: BackButton(color: Colors.white),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: GlassmorphicContainer(
//                     width: double.infinity,
//                     height: 220,
//                     borderRadius: 0,
//                     blur: 20,
//                     alignment: Alignment.bottomCenter,
//                     border: 0,
//                     linearGradient: LinearGradient(
//                       colors: [
//                         Colors.black.withOpacity(0.5),
//                         Colors.black.withOpacity(0.2),
//                       ],
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                     ),
//                     borderGradient: LinearGradient(
//                       colors: [Colors.black12, Colors.black12],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             movie!['Title'] ?? '',
//                             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 10),
//                           Text('Year: ${movie!['Year'] ?? ''}'),
//                           Text('Genre: ${movie!['Genre'] ?? ''}'),
//                           Text('Plot: ${movie!['Plot'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }
