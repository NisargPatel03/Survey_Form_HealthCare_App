import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPath {
  final Path path;
  final Paint paint;

  DrawingPath({
    required this.path,
    required this.paint,
  });
}

class TextLabel {
  final String text;
  final Offset position;
  final Color color;

  TextLabel({
    required this.text,
    required this.position,
    required this.color,
  });
}

class SketchCanvasScreen extends StatefulWidget {
  const SketchCanvasScreen({super.key});

  @override
  State<SketchCanvasScreen> createState() => _SketchCanvasScreenState();
}

class _SketchCanvasScreenState extends State<SketchCanvasScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _redoPaths = [];
  final List<TextLabel> _labels = [];
  
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;
  bool _isTextMode = false;

  Offset _startPoint = Offset.zero;
  String _activeTool = 'brush'; // 'brush', 'line', 'rectangle', 'circle'

  final List<Color> _palette = [
    Colors.black,
    Colors.blue.shade700,
    Colors.red.shade600,
    Colors.green.shade600,
    Colors.amber.shade700,
  ];

  Widget _buildToolChip(String toolId, IconData icon, String label) {
    final bool isSelected;
    if (toolId == 'eraser') {
      isSelected = _isEraser;
    } else if (toolId == 'text') {
      isSelected = _isTextMode;
    } else {
      isSelected = !_isEraser && !_isTextMode && _activeTool == toolId;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        avatar: Icon(
          icon, 
          size: 16, 
          color: isSelected ? Colors.white : Colors.blueGrey.shade600,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.blueGrey.shade800,
        ),
        selected: isSelected,
        selectedColor: Colors.blue.shade700,
        backgroundColor: Colors.grey.shade100,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              if (toolId == 'eraser') {
                _isEraser = true;
                _isTextMode = false;
              } else if (toolId == 'text') {
                _isEraser = false;
                _isTextMode = true;
              } else {
                _isEraser = false;
                _isTextMode = false;
                _activeTool = toolId;
              }
            });
          }
        },
      ),
    );
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sketch?'),
        content: const Text('This will delete all drawing strokes and text labels. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paths.clear();
                _redoPaths.clear();
                _labels.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _redoPaths.add(_paths.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoPaths.isNotEmpty) {
      setState(() {
        _paths.add(_redoPaths.removeLast());
      });
    }
  }

  Future<void> _addTextLabel(Offset position) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Room Label / Annotation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. OPD, Waiting Room, Labor Room',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Place Label'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _labels.add(
          TextLabel(
            text: result,
            position: position,
            color: _selectedColor,
          ),
        );
      });
    }
  }

  Future<void> _saveCanvas() async {
    if (_paths.isEmpty && _labels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save empty sketch. Please draw something first.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Capture the exact canvas drawing using RepaintBoundary for high-fidelity export
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 3.0 pixelRatio provides highly crisp, detailed PNG output (perfect scaling without blur/distortion)
      final ui.Image img = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) throw Exception("Failed to serialize sketch image data");
      final bytes = byteData.buffer.asUint8List();

      // Write PNG to documents directory
      final dir = await getApplicationDocumentsDirectory();
      final String filename = 'sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        Navigator.pop(context, file.path); // Return file path
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving sketch: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Draw Physical Layout', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _paths.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _redoPaths.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All',
            onPressed: (_paths.isNotEmpty || _labels.isNotEmpty) ? _clearCanvas : null,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Layout',
            onPressed: _saveCanvas,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Drawing Area Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: GestureDetector(
                    onTapDown: (details) {
                      if (_isTextMode) {
                        _addTextLabel(details.localPosition);
                      }
                    },
                    onPanStart: (details) {
                      if (_isTextMode) return;
                      setState(() {
                        _startPoint = details.localPosition;

                        final paint = Paint()
                          ..color = _isEraser ? Colors.white : _selectedColor
                          ..strokeWidth = _isEraser ? 24.0 : _strokeWidth
                          ..isAntiAlias = true
                          ..strokeCap = StrokeCap.round
                          ..strokeJoin = StrokeJoin.round
                          ..style = PaintingStyle.stroke;

                        final path = Path();
                        path.moveTo(details.localPosition.dx, details.localPosition.dy);

                        _paths.add(DrawingPath(path: path, paint: paint));
                        _redoPaths.clear(); // Clear redo stack on new action
                      });
                    },
                    onPanUpdate: (details) {
                      if (_isTextMode) return;
                      setState(() {
                        if (_paths.isNotEmpty) {
                          if (_isEraser || _activeTool == 'brush') {
                            _paths.last.path.lineTo(details.localPosition.dx, details.localPosition.dy);
                          } else {
                            final newPath = Path();
                            newPath.moveTo(_startPoint.dx, _startPoint.dy);
                            if (_activeTool == 'line') {
                              newPath.lineTo(details.localPosition.dx, details.localPosition.dy);
                            } else if (_activeTool == 'rectangle') {
                              newPath.addRect(Rect.fromPoints(_startPoint, details.localPosition));
                            } else if (_activeTool == 'circle') {
                              newPath.addOval(Rect.fromPoints(_startPoint, details.localPosition));
                            }
                            _paths[_paths.length - 1] = DrawingPath(path: newPath, paint: _paths.last.paint);
                          }
                        }
                      });
                    },
                    child: CustomPaint(
                      foregroundPainter: SketchPainter(paths: _paths, labels: _labels),
                      child: Container(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Painting Toolbar (Aesthetic Bottom Control Box)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Tool Info Header
                  Row(
                    children: [
                      Icon(
                        _isEraser 
                            ? Icons.cleaning_services 
                            : _isTextMode 
                                ? Icons.text_fields 
                                : _activeTool == 'line'
                                    ? Icons.horizontal_rule
                                    : _activeTool == 'rectangle'
                                        ? Icons.crop_square
                                        : _activeTool == 'circle'
                                            ? Icons.radio_button_unchecked
                                            : Icons.brush, 
                        color: _isEraser ? Colors.grey.shade700 : _selectedColor, 
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isEraser 
                              ? 'Eraser Mode (Swipe to erase)' 
                              : _isTextMode 
                                  ? 'Text Mode (Tap canvas to label)' 
                                  : _activeTool == 'line'
                                      ? 'Line Mode (Drag to draw straight line)'
                                      : _activeTool == 'rectangle'
                                          ? 'Rectangle Mode (Drag to draw room boundary)'
                                          : _activeTool == 'circle'
                                              ? 'Circle Mode (Drag to draw pillar/column)'
                                              : 'Brush Thickness', 
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 2. Tools Selection Drawer (Scrollable Choice Chips)
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildToolChip('brush', Icons.brush, 'Freehand'),
                        _buildToolChip('line', Icons.horizontal_rule, 'Straight Line'),
                        _buildToolChip('rectangle', Icons.crop_square, 'Rectangle'),
                        _buildToolChip('circle', Icons.radio_button_unchecked, 'Circle'),
                        _buildToolChip('text', Icons.text_fields, 'Text Label'),
                        _buildToolChip('eraser', Icons.cleaning_services, 'Eraser'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  if (!_isEraser && !_isTextMode) ...[
                    Slider(
                      value: _strokeWidth,
                      min: 2.0,
                      max: 12.0,
                      divisions: 5,
                      label: '${_strokeWidth.toInt()}px',
                      onChanged: (val) => setState(() => _strokeWidth = val),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                  ],
                  
                  // Color Palette Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Color:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Row(
                        children: _palette.map((color) {
                          final isSelected = _selectedColor == color && !_isEraser;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _isEraser = false;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.grey.shade900 : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isSelected 
                                  ? const Icon(Icons.check, color: Colors.white, size: 14) 
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final List<TextLabel> labels;

  SketchPainter({
    required this.paths,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Render lines
    for (final p in paths) {
      canvas.drawPath(p.path, p.paint);
    }

    // Render annotations
    for (final l in labels) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: l.text,
          style: TextStyle(
            color: l.color,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white.withOpacity(0.85),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(l.position.dx - textPainter.width / 2, l.position.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}
