import 'package:flutter/material.dart';

class CreateNewFileWidget extends StatefulWidget {
  final Size widgetSize;

  const CreateNewFileWidget(
      {super.key, this.widgetSize = const Size(960, 960)});

  @override
  State<StatefulWidget> createState() {
    return CreateNewFileWidgetState();
  }
}

class CreateNewFileWidgetState extends State<CreateNewFileWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
        top: size.height * 0.2,
        left: size.width * 0.1,
        right: size.width * 0.1,
        child: Container(
            width: size.width * 0.8,
            height: size.height * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('data')));
  }
}
