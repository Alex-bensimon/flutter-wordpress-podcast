import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwp/blocs/blocs.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/widgets/widgets.dart';

const iconPlaySize = 60.0;

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerManager _playerManager;

  @override
  void initState() {
    super.initState();
    _playerManager = PlayerManager();
  }

  @override
  void dispose() {
    _playerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Lecteur",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: BlocConsumer<PlayerCubit, PlayerState>(
        listener: (context, playerState) async {
          try {
            await _playerManager.init(
              title: playerState.title,
              audioFileUrl: playerState.audioFileUrl,
            );
            _playerManager.play();
          } catch (e) {
            //TODO
          }
        },
        builder: (context, player) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    renderImage(player),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        player.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: const [
                  AudioProgressBar(),
                  AudioControlButtons(),
                  SizedBox(height: 10),
                  // renderControls(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row renderControls() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       IconButton(
  //         iconSize: 50,
  //         onPressed: () => _playerManager.goBackward30Seconds(),
  //         icon: const Icon(
  //           Icons.replay_30,
  //         ),
  //       ),
  //       ValueListenableBuilder<ButtonState>(
  //         valueListenable: _playerManager.buttonNotifier,
  //         builder: (_, value, __) {
  //           switch (value) {
  //             case ButtonState.loading:
  //               return Container(
  //                 margin: const EdgeInsets.all(8.0),
  //                 width: iconPlaySize,
  //                 height: iconPlaySize,
  //                 child: const CircularProgressIndicator(),
  //               );
  //             case ButtonState.paused:
  //               return IconButton(
  //                 icon: const Icon(Icons.play_arrow),
  //                 iconSize: iconPlaySize,
  //                 onPressed: _playerManager.play,
  //               );
  //             case ButtonState.playing:
  //               return IconButton(
  //                 icon: const Icon(Icons.pause),
  //                 iconSize: iconPlaySize,
  //                 onPressed: _playerManager.pause,
  //               );
  //           }
  //         },
  //       ),
  //       IconButton(
  //         onPressed: () => _playerManager.goForward30Seconds(),
  //         iconSize: 50,
  //         icon: const Icon(
  //           Icons.forward_30,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Padding renderImage(PlayerState player) {
    if (player.imageUrl.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Image(
          image: AssetImage(
            'assets/images/thinkerview.png',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Image(image: NetworkImage(player.imageUrl)),
    );
  }
}
