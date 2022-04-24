import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  AnimatedLogo({Key? key, required this.isFullLogo, double? customSize}) : super(key: key) {
    if (isFullLogo) {
      size = customSize ?? 100.0;
      logo = 'lib/assets/pictures/logo_text.png';
    } else {
      size = customSize ?? 200.0;
      logo = 'lib/assets/pictures/logo_animation_1.png';
    }
  }

  final bool isFullLogo;
  late double size;
  late String logo;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation1 = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(parent: _controller1, curve: Curves.elasticIn),
    );

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation2 = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(parent: _controller2, curve: Curves.bounceIn),
    );

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation3 = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(parent: _controller3, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller1
        .forward()
        .whenComplete(() => _controller2.forward().whenComplete(() => _controller3.forward()));
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: widget.size,
            child: Image.asset(widget.logo),
          ),
          SizedBox(
            height: widget.size,
            child: FadeTransition(
              opacity: _animation1,
              child: Image.asset('lib/assets/pictures/logo_animation_1.png'),
            ),
          ),
          SizedBox(
            height: widget.size,
            child: FadeTransition(
              opacity: _animation2,
              child: Image.asset('lib/assets/pictures/logo_animation_2.png'),
            ),
          ),
          SizedBox(
            height: widget.size,
            child: FadeTransition(
              opacity: _animation3,
              child: Image.asset('lib/assets/pictures/logo_animation_3.png'),
            ),
          ),
        ],
      ),
    );
  }
}
