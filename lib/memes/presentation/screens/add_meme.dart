import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:memes/memes/domain/entities/meme.dart';

class CreateMemeScreen extends StatefulWidget {
  final Meme meme;
  const CreateMemeScreen({super.key, required this.meme});

  @override
  State<CreateMemeScreen> createState() => _CreateMemeScreenState();
}

class _CreateMemeScreenState extends State<CreateMemeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _captureKey = GlobalKey();
  late final TransformationController _transformer;
  bool _showGrid = false;

  // Caption model for the editor
  final List<_Caption> _captions = [];
  int? _selectedId;

  // Theme accents
  static const _glassBlur = 16.0;
  static const _panelRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _transformer = TransformationController();
    final initialCount = widget.meme.captions.clamp(0, widget.meme.boxCount);
    for (int i = 0; i < initialCount; i++) {
      _captions.add(_Caption.initial(i));
    }
  }

  @override
  void dispose() {
    for (final c in _captions) {
      c.controller.dispose();
    }
    _transformer.dispose();
    super.dispose();
  }

  _Caption? get _selected =>
      _captions.firstWhere((c) => c.id == _selectedId, orElse: () => _nullCap);

  static final _nullCap = _Caption.initial(-1);

  void _select(int id) {
    setState(() => _selectedId = id);
  }

  void _addCaption() {
    if (_captions.length >= widget.meme.boxCount) return;
    final id = (_captions.map((e) => e.id).fold<int>(-1, math.max)) + 1;
    setState(() => _captions.add(_Caption.initial(id)));
    _selectedId = id;
  }

  void _removeSelected() {
    if (_selectedId == null) return;
    setState(() {
      _captions.removeWhere((c) => c.id == _selectedId);
      _selectedId = null;
    });
  }

  Future<void> _export() async {
    try {
      RenderRepaintBoundary boundary =
          _captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      final bytes = byteData!.buffer.asUint8List();
      showDialog(
        context: context,
        builder: (context) => Dialog(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_panelRadius),
          ),
          child: Stack(
            children: [
              Image.memory(bytes, fit: BoxFit.contain),
              Positioned(
                top: 12,
                right: 12,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspect = widget.meme.width / widget.meme.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _Glass(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image, size: 18),
                const SizedBox(width: 8),
                Text(
                  // widget.meme.name,
                  'Make your own meme',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _showGrid ? 'Hide grid' : 'Show grid',
            onPressed: () => setState(() => _showGrid = !_showGrid),
            icon: Icon(_showGrid ? Icons.grid_off : Icons.grid_on),
          ),
          IconButton(
            tooltip: 'Reset view',
            onPressed: () =>
                setState(() => _transformer.value = Matrix4.identity()),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: _buildBottomPanel(context),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Hero header with metadata
              _HeaderBar(meme: widget.meme),

              // Canvas area
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_panelRadius),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: aspect,
                      child: _buildCanvas(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    return RepaintBoundary(
      key: _captureKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            transformationController: _transformer,
            boundaryMargin: const EdgeInsets.all(200),
            minScale: 1,
            maxScale: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Ink.image(
                  image: NetworkImage(widget.meme.url),
                  fit: BoxFit.cover,
                ),
                // Optional grid overlay
                if (_showGrid) const _GridOverlay(),
              ],
            ),
          ),

          // Draggable captions overlay
          ..._captions.map(
            (c) => _CaptionBox(
              caption: c,
              selected: c.id == _selectedId,
              onTap: () => _select(c.id),
              onChanged: (updated) {
                setState(() {
                  final idx = _captions.indexWhere((e) => e.id == updated.id);
                  if (idx != -1) _captions[idx] = updated;
                });
              },
            ),
          ),

          // Top-right export button inside canvas for convenience
          Positioned(
            right: 12,
            top: 12,
            child: _Glass(
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Export PNG',
                    onPressed: _export,
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    final canAdd = _captions.length < widget.meme.boxCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedId != null) ...[
          FloatingActionButton.small(
            heroTag: 'delete_fab',
            onPressed: _removeSelected,
            child: const Icon(Icons.delete_outline),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton.extended(
          heroTag: 'add_fab',
          onPressed: canAdd ? _addCaption : null,
          label: Text(canAdd ? 'Add caption' : 'Max reached'),
          icon: const Icon(Icons.add_comment),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final cap = _selectedId == null ? null : _selected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: _Glass(
        radius: _panelRadius,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields),
                    const SizedBox(width: 8),
                    Text(
                      cap == null
                          ? 'Select a caption to style'
                          : 'Caption #${cap.id + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Export PNG',
                      onPressed: _export,
                      icon: const Icon(Icons.download_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (cap != null && cap.id != -1) ...[
                  TextField(
                    controller: cap.controller,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Type your caption…',
                      prefixIcon: Icon(Icons.edit_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StyleControls(
                    caption: cap,
                    onChanged: (updated) {
                      setState(() {
                        final idx = _captions.indexWhere(
                          (e) => e.id == updated.id,
                        );
                        if (idx != -1) _captions[idx] = updated;
                      });
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Tip: Tap on a caption to select it. Use the + button to add more.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ————————————————————————————————————————————————————————————————
// Widgets & Helpers
// ————————————————————————————————————————————————————————————————

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.meme});
  final Meme meme;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withOpacity(0.5),
              cs.surface.withOpacity(0.2),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primaryContainer,
                    child: const Icon(Icons.mood, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meme.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meme.width}×${meme.height}  •  up to ${meme.boxCount} captions',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Guide'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.radius = 16});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: _CreateMemeScreenState._glassBlur,
          sigmaY: _CreateMemeScreenState._glassBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Caption {
  final int id;
  final TextEditingController controller;
  final Offset position; // top-left in canvas space
  final double fontSize;
  final FontWeight weight;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;
  final bool shadow;
  final TextAlign align;

  const _Caption({
    required this.id,
    required this.controller,
    required this.position,
    required this.fontSize,
    required this.weight,
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
    required this.shadow,
    required this.align,
  });

  factory _Caption.initial(int id) => _Caption(
    id: id,
    controller: TextEditingController(
      text: id == 0 ? 'TOP TEXT' : 'BOTTOM TEXT',
    ),
    position: Offset(32 + 8.0 * id, 32.0 + 24.0 * id),
    fontSize: 28,
    weight: FontWeight.w700,
    color: Colors.white,
    strokeColor: Colors.black,
    strokeWidth: 3,
    shadow: true,
    align: TextAlign.center,
  );

  _Caption copyWith({
    String? text,
    Offset? position,
    double? fontSize,
    FontWeight? weight,
    Color? color,
    Color? strokeColor,
    double? strokeWidth,
    bool? shadow,
    TextAlign? align,
  }) {
    return _Caption(
      id: id,
      controller: text == null ? controller : TextEditingController(text: text),
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      shadow: shadow ?? this.shadow,
      align: align ?? this.align,
    );
  }
}

class _CaptionBox extends StatefulWidget {
  const _CaptionBox({
    required this.caption,
    required this.selected,
    required this.onTap,
    required this.onChanged,
  });

  final _Caption caption;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<_Caption> onChanged;

  @override
  State<_CaptionBox> createState() => _CaptionBoxState();
}

class _CaptionBoxState extends State<_CaptionBox> {
  late Offset _dragOrigin;
  late Offset _startPos;

  @override
  Widget build(BuildContext context) {
    final text = widget.caption.controller.text;
    return Positioned(
      left: widget.caption.position.dx,
      top: widget.caption.position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (d) {
          _dragOrigin = d.globalPosition;
          _startPos = widget.caption.position;
        },
        onPanUpdate: (d) {
          final delta = d.globalPosition - _dragOrigin;
          final next = _startPos + delta;
          widget.onChanged(widget.caption.copyWith(position: next));
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _OutlinedText(
              text: text.isEmpty ? ' ' : text,
              fontSize: widget.caption.fontSize,
              weight: widget.caption.weight,
              color: widget.caption.color,
              strokeColor: widget.caption.strokeColor,
              strokeWidth: widget.caption.strokeWidth,
              shadow: widget.caption.shadow,
              align: widget.caption.align,
              maxWidth: 260,
            ),
            if (widget.selected)
              Positioned(
                top: -10,
                right: -10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.drag_indicator, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.fontSize,
    required this.weight,
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
    required this.shadow,
    required this.align,
    required this.maxWidth,
  });

  final String text;
  final double fontSize;
  final FontWeight weight;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;
  final bool shadow;
  final TextAlign align;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      height: 1.1,
      letterSpacing: 0.6,
    );

    final List<Shadow> shadows = shadow
        ? [
            const Shadow(blurRadius: 2, offset: Offset(1, 1)),
            Shadow(blurRadius: 8, color: Colors.black.withOpacity(0.25)),
          ]
        : const [];

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Stack(
        children: [
          // Stroke (outline)
          Text(
            text,
            textAlign: align,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
              shadows: shadows,
            ),
          ),
          // Fill
          Text(
            text,
            textAlign: align,
            style: base.copyWith(color: color, shadows: shadows),
          ),
        ],
      ),
    );
  }
}

class _StyleControls extends StatelessWidget {
  const _StyleControls({required this.caption, required this.onChanged});
  final _Caption caption;
  final ValueChanged<_Caption> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Size & weight
        Row(
          children: [
            const Icon(Icons.format_size),
            Expanded(
              child: Slider(
                value: caption.fontSize,
                min: 12,
                max: 64,
                label: caption.fontSize.toStringAsFixed(0),
                onChanged: (v) => onChanged(caption.copyWith(fontSize: v)),
              ),
            ),
            const SizedBox(width: 8),
            SegmentedButton<FontWeight>(
              segments: const [
                ButtonSegment(value: FontWeight.w400, label: Text('R')),
                ButtonSegment(value: FontWeight.w600, label: Text('M')),
                ButtonSegment(value: FontWeight.w700, label: Text('B')),
              ],
              selected: {caption.weight},
              onSelectionChanged: (s) =>
                  onChanged(caption.copyWith(weight: s.first)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Color & stroke
        Row(
          children: [
            const Icon(Icons.palette_outlined),
            const SizedBox(width: 8),
            _ColorDotRow(
              colors: [
                Colors.white,
                Colors.black,
                Colors.amber,
                Colors.redAccent,
                Colors.lightGreen,
                Colors.lightBlue,
                cs.primary,
                cs.tertiary,
              ],
              selected: caption.color,
              onPick: (c) => onChanged(caption.copyWith(color: c)),
            ),
            const Spacer(),
            const Text('Stroke'),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: Slider(
                value: caption.strokeWidth,
                min: 0,
                max: 8,
                onChanged: (v) => onChanged(caption.copyWith(strokeWidth: v)),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Toggle shadow',
              onPressed: () =>
                  onChanged(caption.copyWith(shadow: !caption.shadow)),
              icon: Icon(
                caption.shadow ? Icons.wb_shade_outlined : Icons.wb_shade,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Alignment & stroke color
        Row(
          children: [
            const Icon(Icons.format_align_center),
            const SizedBox(width: 8),
            SegmentedButton<TextAlign>(
              segments: const [
                ButtonSegment(
                  value: TextAlign.left,
                  label: Icon(Icons.format_align_left),
                ),
                ButtonSegment(
                  value: TextAlign.center,
                  label: Icon(Icons.format_align_center),
                ),
                ButtonSegment(
                  value: TextAlign.right,
                  label: Icon(Icons.format_align_right),
                ),
              ],
              selected: {caption.align},
              onSelectionChanged: (s) =>
                  onChanged(caption.copyWith(align: s.first)),
            ),
            const Spacer(),
            const Text('Outline'),
            const SizedBox(width: 8),
            _ColorDotRow(
              colors: const [
                Colors.black,
                Colors.white,
                Colors.deepPurple,
                Colors.blueGrey,
                Colors.teal,
                Colors.orange,
              ],
              selected: caption.strokeColor,
              onPick: (c) => onChanged(caption.copyWith(strokeColor: c)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorDotRow extends StatelessWidget {
  const _ColorDotRow({
    required this.colors,
    required this.selected,
    required this.onPick,
  });
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onPick;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final c in colors)
          GestureDetector(
            onTap: () => onPick(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c,
                border: Border.all(
                  color: selected == c
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white.withOpacity(0.6),
                  width: selected == c ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
