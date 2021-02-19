import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leaderboard_test/models/firebase_model.dart';

class GamesView extends StatelessWidget {
  final newGameNameController = TextEditingController();
  final scaffKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffKey,
      appBar: AppBar(
        title: Text('Games'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => buildShowDialog(context),
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<GamesModel>>(
            stream: GamesModel.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) => InkWell(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LeaderboardView(
                                      doc: snapshot.data[index],
                                    ))),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            snapshot.data[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ));
            }),
      ),
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: TextField(
                controller: newGameNameController,
                decoration: InputDecoration(labelText: 'Enter name'),
              ),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      if (newGameNameController.text.trim().isEmpty) {
                        scaffKey.currentState.showSnackBar(
                            SnackBar(content: Text('Please enter the name')));
                      } else {
                        final newGame = GamesModel(
                            name: newGameNameController.text, docId: null);
                        newGame.save();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add'))
              ],
            ));
  }
}

class LeaderboardView extends StatelessWidget {
  final GamesModel doc;
  final usernameController = TextEditingController();
  final scoreTextController = TextEditingController();

  LeaderboardView({Key key, @required this.doc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => buildShowDialog(context),
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<LeaderboardModel>>(
            stream: LeaderboardModel.get(docId: doc.docId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              return ListView.separated(
                  itemCount: snapshot.data?.length ?? 0,
                  separatorBuilder: (c, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = snapshot.data[index];
                    return ListTile(
                      title: Text(data.username),
                      trailing: Text(data.score.toString()),
                      subtitle: Text(data.createdAt.toString()),
                    );
                  });
            }),
      ),
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Enter name'),
              ),
              content: TextField(
                controller: scoreTextController,
                decoration: InputDecoration(labelText: 'Enter score'),
              ),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      final model = LeaderboardModel(
                          username: usernameController.text,
                          score: int.tryParse(scoreTextController.text) ?? 0,
                          createdAt: Timestamp.now());
                      model.save(docId: doc.docId);
                      usernameController.clear();
                      scoreTextController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'))
              ],
            ));
  }
}
