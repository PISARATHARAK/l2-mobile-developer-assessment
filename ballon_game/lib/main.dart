import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  var colorsList = <Color>[
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.black,
    Colors.pink
  ];

  int totalBalloons = 0;
  late Timer timer;
  List<Balloon> balloons = [];
  int score = 0;
  bool start = false;
  int _start = 120;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    gameStart();
  }

  void gameStart() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        gameEnd();
      } else {
        _start--;
        Duration remainingTime = Duration(seconds: _start);
        _remainingTime =
        '${remainingTime.inMinutes}:${(remainingTime.inSeconds - remainingTime.inMinutes * 60).toString().padLeft(2, '0')}';
        setState(() {
          balloons.add(Balloon(
            left: Random().nextDouble() * (400),
            color: colorsList[Random().nextInt(colorsList.length)],
            pop: balloonPopped,
          ));
        });
      }
    });
  }

  void balloonPopped() {
    setState(() {
      score++;
    });
  }

  void gameEnd() {
    setState(() {
      start = true;
      totalBalloons = balloons.length;
      _remainingTime = '2:00';
      _start = 120;
      balloons.clear();
    });
  }

  void gameRestart() {
    setState(() {
      gameEnd();
      start = false;
      gameStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: !start
            ? Stack(children: [
          for (int i = 0; i < balloons.length; i++) balloons[i],
        ])
            : Container(
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 220),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Score Board',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Balloons Popped: $score \n Balloons Missed: ${totalBalloons - score} \n your score:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${score * 2 - (totalBalloons - score)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: TextButton(
            onPressed: () {
              if (start) {
                gameRestart();
              }
            },
            child: Text(
              start ? 'Restart' : 'Remaining Time: $_remainingTime',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Balloon extends StatefulWidget {
  final double left;
  final Color color;
  final Function pop;

  const Balloon({
    super.key,
    required this.left,
    required this.color,
    required this.pop,
  });

  @override
  State<Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> {

  var random = Random();
  bool show = false;
  bool visible = true;
  double size = 1;
  double position = 0;
  bool hasBeenTapped = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {});
    Future.delayed(const Duration(milliseconds: 90), () {
      setState(() {
        show = true;
      });
    });
  }

  getSize() {
    if (timer.isActive) {
      timer.cancel();
    }
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) {
        setState(() {
          size = size <= 1 ? 1.5 : 0.6;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      bottom: show ? screenHeight : -200,
      left: widget.left,
      duration: Duration(seconds: random.nextInt(4) + 2),
      child: GestureDetector(
        onTap: () {
          setState(() {
            visible = false;
            getSize();

            if (!hasBeenTapped) {

              widget.pop();
              hasBeenTapped = true;

              Future.delayed(const Duration(milliseconds: 200), () {
                if (timer.isActive) {
                  timer.cancel();
                }
              });
            }
          });
        },
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Transform.scale(
            scale: visible ? 1.0 : size,
            child: SvgPicture.asset(
              'assets/balloon.svg',
              semanticsLabel: 'balloon',
              height: 200,
              width: 200,
              colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}