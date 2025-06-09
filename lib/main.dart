import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Анимации',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const AnimationDemo(),
    );
  }
}

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo>
    with SingleTickerProviderStateMixin {
  bool _showFirst = true;
  bool _showSecond = true;
  double _paddingValue = 20.0;
  Color _containerColor = Colors.blue;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  final ScrollController _scrollController = ScrollController();
  double _parallaxOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.indigo,
      end: Colors.purple,
    ).animate(_controller);

    _scrollController.addListener(() {
      setState(() {
        _parallaxOffset = _scrollController.offset / 2;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFirst() {
    setState(() {
      _showFirst = !_showFirst;
    });
  }

  void _toggleSecond() {
    setState(() {
      _showSecond = !_showSecond;
      _paddingValue = _showSecond ? 20.0 : 50.0;
      _containerColor = _showSecond ? Colors.blue : Colors.green;
    });
  }

  void _toggleExplicitAnimation() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Анимации'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Имплицитные анимации',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleFirst,
                        child: Text(_showFirst ? 'Скрыть' : 'Показать'),
                      ),
                      ElevatedButton(
                        onPressed: _toggleSecond,
                        child: Text(_showSecond ? 'Скрыть' : 'Показать'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AnimatedOpacity(
                      opacity: _showFirst ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.deepPurple,
                        child: const Center(
                          child: Text(
                            'Это щас пропадет',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: _showSecond ? 200 : 100,
                      height: _showSecond ? 100 : 200,
                      padding: EdgeInsets.all(_paddingValue),
                      color: _containerColor,
                      curve: Curves.easeInOut,
                      child: const Center(
                        child: Text(
                          'Это тоже ща пропадет',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Явные анимации',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _toggleExplicitAnimation,
                      child: Text(
                        _controller.isAnimating
                            ? 'Погоди'
                            : _controller.isCompleted
                                ? 'Назад'
                                : 'Вперед',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _controller.value += details.delta.dy / 500;
                        });
                      },
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            color: _colorAnimation.value,
                            child: const Center(
                              child: Text(
                                'Кружусь',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Секция с параллакс-эффектом
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Параллакс-эффект',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('Прокрути вниз'),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 50 - _parallaxOffset * 0.3,
                          left: 20,
                          child: Container(
                            width: 200,
                            height: 200,
                            color: Colors.red,
                            child: const Center(
                              child: Text(
                                'Слой 1',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 100 - _parallaxOffset * 0.7,
                          left: 100,
                          child: Container(
                            width: 200,
                            height: 200,
                            color: Colors.blue,
                            child: const Center(
                              child: Text(
                                'Слой 2',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 150 - _parallaxOffset,
                          left: 180,
                          child: Container(
                            width: 200,
                            height: 200,
                            color: Colors.orange,
                            child: const Center(
                              child: Text(
                                'Слой 3',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}