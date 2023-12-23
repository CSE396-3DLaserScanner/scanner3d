import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:Scanner3D/src/presentation/widgets/button_style.dart';

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
  late bool _backfaceCulling;

  late Key _cubeKey;

  late bool _isObjectValid;

  @override
  void initState() {
    super.initState();
    _resetCube();
    _cubeKey = UniqueKey();
    _isObjectValid = false;
    _checkObjectValidity();
  }

  void _resetCube() {
    _scale = Vector3(10, 10, 10);
    _position = Vector3(0, 2, 1);
    _rotation = Vector3(90, -45, 180);
    _far = 1500;
    _zoom = 0.7;
    _backfaceCulling = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.objectFileName), centerTitle: true),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: _isObjectValid
                ? Cube(
                    key: _cubeKey,
                    onSceneCreated: (Scene scene) {
                      scene.world.add(Object(
                        fileName: widget.path,
                        lighting: true,
                        backfaceCulling: _backfaceCulling,
                        scale: _scale,
                        position: _position,
                        rotation: _rotation,
                      ));
                      scene.camera = Camera(far: _far, zoom: _zoom);
                    },
                  )
                : Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "File '${widget.objectFileName}' could not found!",
                      style: TextStyle(
                          color: Theme.of(context).shadowColor, fontSize: 20),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          _isObjectValid
              ? ButtonStyles().button("Reset Position", () {
                  _resetCube();
                  setState(() {
                    _cubeKey = UniqueKey();
                  });
                }, Theme.of(context).primaryColor)
              : const SizedBox(height: 0),
        ],
      ),
    );
  }

  Future<void> _checkObjectValidity() async {
    try {
      await rootBundle.load(widget.path);
      setState(() {
        _isObjectValid = true;
      });
    } catch (e) {
      setState(() {
        _isObjectValid = false;
      });
    }
  }
}
