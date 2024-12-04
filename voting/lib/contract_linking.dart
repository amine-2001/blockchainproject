import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ContractLinking extends ChangeNotifier {
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";
  final String _privateKey =
      "0xe55a444ec16427a0038392d5f07dfb1fe1a101b499776483cd31b1af3c4cf427";

  late Web3Client _client;
 late  String _abiCode;

  late Credentials _credentials;
  late EthereumAddress _ownAddress;
  late EthereumAddress _contractAddress;

  late DeployedContract _contract;
  late ContractFunction _chairperson;
  late ContractFunction _registerFunc;
  late ContractFunction _voteFunc;
  late ContractFunction _declareWinnerFunc;

  bool isLoading = true;

  ContractLinking() {
    inititalSetup();
  }

  inititalSetup() async {
    _client = await Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
   await getAbi();
    await getCredentials();
   await getDeployedContract();
  }

  getAbi() async {
    String abiStringFile =
    await rootBundle.loadString("C:/Users/MSI/projetbc/build/contracts/Election.json");
    var jsonFile = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonFile["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonFile["networks"]["5777"]["address"]);
  }

  getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    //await _client.credentialsFromPrivateKey(_privateKey);
    //_ownAddress = await _credentials.extractAddress();
  }

  getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "Election"), _contractAddress);
    _chairperson = _contract.function("chairperson");
    _registerFunc = _contract.function("Register");
    _voteFunc = _contract.function("Vote");
    _declareWinnerFunc = _contract.function("Winner");
    getChairperson();
  }

  getChairperson() async {
    var chairperson = await _client
        .call(contract: _contract, function: _chairperson, params: []);
    print("${chairperson.first}");
    isLoading = false;
    notifyListeners();
  }

  registerVoter(String voterAddress, String chairpersonAddress) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,chainId:1337,
        Transaction.callContract(
            contract: _contract,
            function: _registerFunc,
            parameters: [
              EthereumAddress.fromHex(voterAddress),
              EthereumAddress.fromHex(chairpersonAddress)
            ]));
    print("Voter Registered");
    getChairperson();
  }

  vote(int toProposal, String voterAddress) async {

    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,chainId:1337,
        Transaction.callContract(
            contract: _contract,
            function: _voteFunc,
            parameters: [
              BigInt.from(toProposal),
              EthereumAddress.fromHex(voterAddress)
            ]));
    getChairperson();
    createData(toProposal,voterAddress);

  }



  // Méthode pour créer un nouvel article (requête POST)



  winner() async {
    //createData();
    var winnerIs = await _client
        .call(contract: _contract, function: _declareWinnerFunc, params: []);
    return "${winnerIs.first}";


  }

  createData(int x,String y) async {
    final String baseUrl = 'http://localhost:1337/api'; // Strapi API URL
    final response = await http.post(
      Uri.parse('$baseUrl/votes'), // URL de l'API Strapi
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"data":{
        'toProposal': x,
        'voterAddress':y

      }}),
    );

    // Si la réponse est un succès (200 ou 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // L'article a été créé avec succès
    } else {
      throw Exception('Failed to create article');
    }

  }
}