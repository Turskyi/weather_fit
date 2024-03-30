import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({super.key, required this.url, required this.onLoaded});

  final String url;
  final VoidCallback onLoaded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kIsWeb ? 20 : 2),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              // Image is fully loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoaded.call();
              });
              return child;
            } else {
              // Image is still loading
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.withAlpha(90),
                  backgroundColor: Colors.transparent,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
  }
}
