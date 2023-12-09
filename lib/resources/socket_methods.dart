import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/game_methods.dart';
import 'package:tictactoe/resources/socket_client.dart';
import 'package:tictactoe/screens/game_screen.dart';
import 'package:tictactoe/screens/main_menu_screen.dart';
import 'package:tictactoe/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
//import 'package:permission_handler/permission_handler.dart';

//**Esta clase maneja los metodos que se van a ejecutar cuando el servidor envie un evento */
class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // EMITS, crea la sala
  void createRoom(String nickname) {
    /*if (Permission.internet.request().isGranted) {
    
    }else{

    }*/
    try {
      if (nickname.isNotEmpty) {
        _socketClient.emit('createRoom', {
          'nickname': nickname,
        });
      } else {
        log("error de con");
      }
    } catch (e) {
      log("error");
    }
  }

  //se une a la sala
  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }
  }

  //Detecta toques en la tabla 9*9
  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      _socketClient.emit('tap', {
        'index': index,
        'roomId': roomId,
      });
    }
  }

  // LISTENERS, esta a la espera de que se cree la sala
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  // esta a la espera de que alguien se una a  la sala
  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  //esta a la espera de que ocurra algun error
  void errorOccuredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
      showSnackBar(context, data);
    });
  }

  //esta a la espera de que se actualice la informacion de los jugadores
  void updatePlayersStateListener(BuildContext context) {
    _socketClient.on('updatePlayers', (playerData) {
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer1(
        playerData[0],
      );
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer2(
        playerData[1],
      );
    });
  }

  //esta a la espera de que hayan cambios en la sala para actualizarla
  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (data) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(data);
    });
  }

  //** Esta a la espera de que haya un clic o toque*/
  void tappedListener(BuildContext context) {
    _socketClient.on('tapped', (data) {
      RoomDataProvider roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      roomDataProvider.updateDisplayElements(
        data['index'],
        data['choice'],
      );
      roomDataProvider.updateRoomData(data['room']);
      // check winnner
      GameMethods().checkWinner(context, _socketClient);
    });
  }

  //**Esta a la espera de que se actualicen los puntos */
  void pointIncreaseListener(BuildContext context) {
    _socketClient.on('pointIncrease', (playerData) {
      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);
      if (playerData['socketID'] == roomDataProvider.player1.socketID) {
        roomDataProvider.updatePlayer1(playerData);
      } else {
        roomDataProvider.updatePlayer2(playerData);
      }
    });
  }

  //**Esta a la espera de que finalice el juego */
  void endGameListener(BuildContext context) {
    _socketClient.on('endGame', (playerData) {
      try {
        showGameDialog(context, '${playerData['nickname']} ganó el juego!');
        Future.delayed(Duration.zero, () {
          Navigator.popUntil(
            context,
            ModalRoute.withName(MainMenuScreen.routeName),
          );
        });
      } catch (e) {
        log(e.toString());
      }
      //var roomDataProvider =
      //Provider.of<RoomDataProvider>(context, listen: false);
      //roomDataProvider.dispose();
      /*Navigator.popUntil(
          context, ModalRoute.withName(MainMenuScreen.routeName));*/
    });
  }
}
