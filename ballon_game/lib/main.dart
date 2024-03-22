import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const Game());
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
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
  List<Bubble> bubbles = [];
  Random random = Random();
  int score = 0;
  late Size size;
  bool start = false;
  int _start = 120;
  String _remainingTime = '2:00';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        endGame();
      } else {
        _start--;
        Duration remainingTime = Duration(seconds: _start);
        _remainingTime =
        '${remainingTime.inMinutes}:${(remainingTime.inSeconds - remainingTime.inMinutes * 60).toString().padLeft(2, '0')}';
        balloonCreation();
      }
    });
  }

  void balloonCreation() {
    double left = random.nextDouble() * (size.width - 150);
    setState(() {
      bubbles.add(Bubble(
        left: left,
        color: colorsList[random.nextInt(colorsList.length)],
        pop: pop,
      ));
    });
  }

  void pop() {
    setState(() {
      score++;
    });
  }

  void endGame() {
    setState(() {
      start = true;
      totalBalloons = bubbles.length;
      _remainingTime = '2:00';
      _start = 120;
      bubbles.clear();
    });
  }

  void restartGame() {
    setState(() {
      endGame();
      start = false;
      startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      body: !start
          ? Stack(children: [
        for (int i = 0; i < bubbles.length; i++) bubbles[i],
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
            const Divider(
              thickness: 2,
              color: Colors.white,
            ),
            Text(
              'Balloons Popped: $score',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Balloons Missed: ${totalBalloons - score}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const Text(
              'You Score',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
              restartGame();
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
    );
  }
}

class Bubble extends StatefulWidget {
  final double left;
  final Color color;
  final Function pop;

  const Bubble({
    super.key,
    required this.left,
    required this.color,
    required this.pop,
  });

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {

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