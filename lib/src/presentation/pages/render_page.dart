import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';
// ignore: unused_import
import 'dart:developer' as developer;
import 'package:Scanner3D/src/presentation/widgets/button_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class RenderPage extends StatefulWidget {
  const RenderPage(
      {super.key, required this.objectFileName, required this.path});

  final String objectFileName;
  final String path;

  @override
  State<RenderPage> createState() => _RenderPageState();
}

class _RenderPageState extends State<RenderPage> {
  late String _filePath;
  late bool _isObjectValid;
  late Key _cubeKey;

  Object _object = Object();
  Color _objectColor = Colors.white;
  Color _selectedColor = Colors.white;
  BlendMode _blendMode = BlendMode.color;

  bool _isReset = false;
  bool _isLoading = false;

  @override
  initState() {
    super.initState();

    _filePath = widget.path;
    _isObjectValid = false;
    _checkObjectValidity();
    _cubeKey = UniqueKey();
    _createAndSaveTextureImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.objectFileName),
        centerTitle: true,
      ),
      body: Container(
        child: _isObjectValid ? _buildValidScreen() : _buildInvalidScreen(),
      ),
    );
  }

  Widget _buildValidScreen() {
    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Cube(
                    key: _cubeKey,
                    onSceneCreated: (Scene scene) {
                      _onSceneCreated(scene);
                      setState(() {});
                    },
                  )),
        const SizedBox(height: 20),
        _buildButtonTab()
      ],
    );
  }

  Widget _buildInvalidScreen() {
    return Center(
      child: Text(
        "File '${widget.objectFileName}' could not be found!",
        style: TextStyle(
          color: Theme.of(context).shadowColor,
          fontSize: 20,
        ),
      ),
    );
  }

  void _onSceneCreated(Scene scene) {
    if (_isReset) {
      scene.textureBlendMode = _blendMode;
      scene.updateTexture();
    } else {
      Object object = Object(
        fileName: _filePath,
        lighting: true,
        backfaceCulling: false,
        scale: Vector3(10, 10, 10),
        position: Vector3(0, 1, 2),
        rotation: Vector3(90, -45, 180),
      );
      _object = object;
    }

    if (_selectedColor != _objectColor) {
      _createAndSaveTextureImage().then((value) {
        loadImageFromAsset(value, isAsset: false).then((image) {
          _object.mesh.texture = image;

          scene.textureBlendMode = _blendMode;
          scene.updateTexture();
        });
      });
      _objectColor = _selectedColor;
    }

    scene.world.add(_object);
    scene.camera = Camera(far: 1500, zoom: 0.7);
  }

  Widget _buildButtonTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ButtonStyles().button("Reset Position", () {
          _isReset = true;
          setState(() {
            _cubeKey = UniqueKey();
          });
        }, Theme.of(context).primaryColor),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  _isReset = true;
                  _blendMode = (_blendMode == BlendMode.color)
                      ? BlendMode.modulate
                      : BlendMode.color;
                  setState(() {
                    _cubeKey = UniqueKey();
                  });
                },
                icon: Icon((_blendMode == BlendMode.color)
                    ? Icons.color_lens_outlined
                    : Icons.color_lens)),
            _buildColorPicker()
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return ButtonStyles().colorButton(
      _selectedColor,
      () {
        _isReset = true;
        ColorPicker(
          color: _selectedColor,
          onColorChanged: (Color color) {
            setState(() {
              _selectedColor = color;
              _cubeKey = UniqueKey();
            });
          },
          showColorName: true,
          actionButtons:
              const ColorPickerActionButtons(dialogActionButtons: false),
          hasBorder: true,
          columnSpacing: 20,
          enableTonalPalette: true,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.primary: true,
            ColorPickerType.accent: false,
          },
        ).showPickerDialog(
          context,
          backgroundColor: Colors.white,
        );
      },
    );
  }

  Future<String> _createAndSaveTextureImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(2.0, 2.0)));

    final paint = Paint()..color = _selectedColor;
    canvas.drawRect(
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(2.0, 2.0)), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(2, 2);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/texture_image/image.png';
    final file = File(filePath);

    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(buffer);

    return filePath;
  }

  /*Future<void> _checkObjectValidity() async {
    try {
      if (await File(_filePath).exists()) {
        setState(() {
          _isObjectValid = true;
        });
      } else {
        setState(() {
          _isObjectValid = false;
        });
      }
    } catch (e) {
      setState(() {
        _isObjectValid = false;
      });
    }
  }*/
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
