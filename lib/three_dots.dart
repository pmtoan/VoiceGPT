import 'package:flutter/material.dart';

class ThreeDots extends StatefulWidget {
  const ThreeDots({Key? key}) : super(key: key);

  @override
  State<ThreeDots> createState() => _ThreeDotsState();
}

class _ThreeDotsState extends State<ThreeDots> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  int _currentIdx = 0;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _currentIdx++;
            if(_currentIdx == 3){
              _currentIdx = 0;
            }
            _controller!.reset();
            _controller!.forward();
          }
        });
    _controller!.forward();
  }


  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIdx == 0 ? Colors.green : Colors.grey,
              ),
            ),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIdx == 1 ? Colors.green : Colors.grey,
              ),
            ),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIdx == 2 ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
