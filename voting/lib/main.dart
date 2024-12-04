import 'package:voting/contract_linking.dart';
import 'package:voting/election.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractLinking>(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        title: "Decentralized Voting",
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.cyan[400],
            hintColor: Colors.deepOrange[200]),
        home: ElectionUI(),
      ),
    );
  }
}