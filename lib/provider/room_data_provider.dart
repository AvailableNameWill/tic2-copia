//esta clase es para actualizar los datos del programa en tiempo real
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tictactoe/models/player.dart';

class RoomDataProvider extends ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  List<String> _displayElement = ['', '', '', '', '', '', '', '', ''];
  int _filledBoxes = 0;

  //**maneja los datos del jugador1**//
  Player _player1 = Player(
    nickname: '',
    socketID: '',
    points: 0,
    playerType: 'X',
  );

  //**maneja los datos del jugador2**//
  Player _player2 = Player(
    nickname: '',
    socketID: '',
    points: 0,
    playerType: 'O',
  );

  Map<String, dynamic> get roomData => _roomData;
  List<String> get displayElements => _displayElement;
  int get filledBoxes => _filledBoxes;
  Player get player1 => _player1;
  Player get player2 => _player2;

  //***actualiza los datos de la sala***//
  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;
    notifyListeners();
  }

  //***actualiza los datos del jugador1***//
  void updatePlayer1(Map<String, dynamic> player1Data) {
    _player1 = Player.fromMap(player1Data);
    notifyListeners();
  }

  //***actualiza los datos del jugador2***//
  void updatePlayer2(Map<String, dynamic> player2Data) {
    _player2 = Player.fromMap(player2Data);
    notifyListeners();
  }

  //***atualiza los datos de la pantalla del juego***//
  void updateDisplayElements(int index, String choice) {
    _displayElement[index] = choice;
    _filledBoxes += 1;
    notifyListeners();
  }

  void setFilledBoxesTo0() {
    _filledBoxes = 0;
  }
}
