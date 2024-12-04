import 'package:voting/contract_linking.dart';
import 'package:voting/election.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List catsNames = [];

List assetsImages = [
  "assets/images/ballerina-portrait-idle.png",
  "assets/images/orangetabby-portrait-idle.png",
  "assets/images/rascal-portrait-idle.png",
  "assets/images/siamese-portrait-idle.png",
  "assets/images/smudge-portrait-idle.png",
];

class Proposals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<ContractLinking>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Voting On Blockchain"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, int index) {
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  margin: EdgeInsets.only(left: 30),
                  child: Card(
                    color: Colors.blueGrey,
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 74.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Name - ${catsNames[index]}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                textBaseline: TextBaseline.ideographic),
                          ),
                          ElevatedButton(
                            child: Text("Vote"),
                            style:
                            ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                            onPressed: () {
                              voteProposal(context, index);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20.0,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.lightGreenAccent,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(.3),
                            offset: Offset(0, 2),
                            blurRadius: 5)
                      ],
                    ),
                    constraints: BoxConstraints(maxHeight: 100, maxWidth: 100),
                    child: CircleAvatar(
                      maxRadius: 40,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage: AssetImage("${assetsImages[index]}"),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  voteProposal(context, int toProposal) {
    print( 'context');
    print( context);
    print(toProposal);
    var contractLink = Provider.of<ContractLinking>(context, listen: false);
    TextEditingController voterAddress = TextEditingController();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Vote Proposal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 8.0),
                  child: TextField(
                    controller: voterAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: "Voter Address",
                        hintText: "Enter Voter Address..."),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            contractLink.vote(toProposal, voterAddress.text);
                            showToast("Thanks for voting !", context);
                            //Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ElectionUI()),
                                    (route) => false);
                          },
                          child: Text("VOTE")),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  listNames(String name){
    catsNames.add(name);

    createData(name);


  }
  createData(String y) async {
    final String baseUrl = 'http://localhost:1337/api'; // Strapi API URL
    final response = await http.post(
      Uri.parse('$baseUrl/listnames'), // URL de l'API Strapi
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"data":{
        'namee': y,


      }}),
    );

    // Si la réponse est un succès (200 ou 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // L'article a été créé avec succès
    } else {
      throw Exception('Failed to create article');
    }

  }

  showToast(String message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.teal,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      textColor: Colors.white,
      fontSize: 20,
    );
  }











}