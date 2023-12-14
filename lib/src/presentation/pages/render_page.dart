import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:scanner3d/src/presentation/widgets/button_style.dart';

class RenderPage extends StatefulWidget {
  const RenderPage(
      {super.key, required this.objectFileName, required this.path});

  final String objectFileName;
  final String path;

  @override
  State<RenderPage> createState() => _RenderPageState();
}

class _RenderPageState extends State<RenderPage> {
  late Vector3 _scale;
  late Vector3 _position;
  late Vector3 _rotation;
  late double _far;
  late double _zoom;

  late Key _cubeKey; // Add this line

  @override
  void initState() {
    super.initState();
    _resetCube();
    _cubeKey = UniqueKey(); // Initialize a unique key
  }

  void _resetCube() {
    _scale = Vector3(10, 10, 10);
    _position = Vector3(0, 2, 1);
    _rotation = Vector3(90, -45, 180);
    _far = 1500;
    _zoom = 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.objectFileName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Cube(
              key: _cubeKey, // Use the key here
              onSceneCreated: (Scene scene) {
                scene.world.add(Object(
                  fileName: widget.path,
                  lighting: true,
                  backfaceCulling: false,
                  scale: _scale,
                  position: _position,
                  rotation: _rotation,
                ));
                scene.camera = Camera(far: _far, zoom: _zoom);
              },
            ),
          ),
          const SizedBox(height: 20),
          ButtonStyles().button("Reset Position", () {
            _resetCube();
            setState(
              () {
                _cubeKey =
                    UniqueKey(); // Change the key to create a new Cube instance
              },
            );
          }, const Color.fromARGB(255, 36, 161, 157))
        ],
      ),
    );
  }
}
