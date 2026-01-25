import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.loadingProgress, super.key});

  final ImageChunkEvent? loadingProgress;

  @override
  Widget build(BuildContext context) {
    final int? totalBytes = loadingProgress?.expectedTotalBytes;
    final int? loadedBytes = loadingProgress?.cumulativeBytesLoaded;
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        backgroundColor: Colors.transparent,
        strokeAlign: BorderSide.strokeAlignOutside,
        strokeWidth: 12,
        strokeCap: StrokeCap.round,
        value: (totalBytes != null && totalBytes > 0)
            ? (loadedBytes ?? 0) / totalBytes
            : null,
      ),
    );
  }
}
