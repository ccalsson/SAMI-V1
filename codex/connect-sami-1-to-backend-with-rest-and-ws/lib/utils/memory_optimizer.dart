import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MemoryOptimizer {
  static void optimizeImages(BuildContext context) {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }
  
  static void clearMemory() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
} 