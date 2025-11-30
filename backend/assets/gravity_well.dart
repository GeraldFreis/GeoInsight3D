import 'dart:io';
import 'dart:math';

final rng = Random();

double rnd(double a, double b) => a + (b - a) * rng.nextDouble();

String lidarPoint(num x, num y, num z, num i) =>
    "${x.toStringAsFixed(2)},"
    "${y.toStringAsFixed(2)},"
    "${z.toStringAsFixed(2)},"
    "${i.toStringAsFixed(0)}";

// ===================================================================
// FLAT GRID WITH GRAVITY WELL
// ===================================================================
List<String> generateFlatWithWell(int size, double wellRadius) {
  final out = <String>[];
  final center = size / 2;

  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
      double dx = x - center;
      double dy = y - center;
      double dist = sqrt(dx * dx + dy * dy);

      // Gravity well effect: max depth at center, taper off to radius
      double wellDepth = 0;
      double intensity = rnd(250, 400);
      if (dist < wellRadius) {
        wellDepth = -30 * (1 - (dist / wellRadius)); // -30 at center, 0 at edge
        intensity = rnd(40,60);
      }

      // Small random terrain noise
      double z = 1 + wellDepth + rnd(-0.5, 0.5);

      // Intensity: low for ground
      

      out.add(lidarPoint(x, y, z, intensity));
    }
  }

  return out;
}

// ===================================================================
// BUILDINGS AROUND THE WELL
// ===================================================================
List<String> generateBuildingsAroundWell(int size, double wellRadius) {
  final out = <String>[];
  final center = size / 2;

  for (int b = 0; b < 6; b++) {
    // place buildings outside the well radius
    double angle = rnd(0, 2 * pi);
    double radius = wellRadius + rnd(10, 80); // distance from well
    int x0 = (center + radius * cos(angle)).round();
    int y0 = (center + radius * sin(angle)).round();

    int w = rng.nextInt(15) + 10;
    int h = rng.nextInt(15) + 10;
    double roofZ = rnd(5, 20);

    // Roof
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        out.add(lidarPoint(
          x0 + i,
          y0 + j,
          roofZ + rnd(-0.2, 0.2),
          rnd(40, 60),
        ));
      }
    }

    // Walls
    for (int z = 0; z < roofZ.toInt(); z += 2) {
      for (int i = 0; i < w; i++) {
        out.add(lidarPoint(x0 + i, y0, z, rnd(60, 110)));
        out.add(lidarPoint(x0 + i, y0 + h, z, rnd(60, 110)));
      }
      for (int j = 0; j < h; j++) {
        out.add(lidarPoint(x0, y0 + j, z, rnd(60, 110)));
        out.add(lidarPoint(x0 + w, y0 + j, z, rnd(60, 110)));
      }
    }
  }

  return out;
}

List<String> generateTrees(int numTrees, int terrainRows, int terrainCols) {
  final trees = <String>[];
  final rng = Random();

  for (int t = 0; t < numTrees; t++) {
    // Random position for tree, leave some margin
    int x0 = rng.nextInt(terrainRows - 40) + 20;
    int y0 = rng.nextInt(terrainCols - 40) + 20;

    double trunkHeight = rnd(10.0, 25.0);
    double canopyHeight = rnd(10.0, 25.0);
    double canopyRadius = rnd(3.0, 6.0);

    // Trunk — vertical cylinder
    for (int z = 0; z < trunkHeight.toInt(); z++) {
      trees.add(lidarPoint(
        x0.toDouble(),
        y0.toDouble(),
        z.toDouble(),
        rnd(40, 60), // trunk darker
      ));
    }

    // Canopy — simple circular cluster
    for (double dx = -canopyRadius; dx <= canopyRadius; dx += 0.5) {
      for (double dy = -canopyRadius; dy <= canopyRadius; dy += 0.5) {
        if (dx * dx + dy * dy <= canopyRadius * canopyRadius) {
          double z = trunkHeight + rnd(-1.0, canopyHeight);
          trees.add(lidarPoint(
            x0 + dx,
            y0 + dy,
            z,
            rnd(400, 600), // foliage brighter
          ));
        }
      }
    }
  }

  return trees;
}

// ===================================================================
// GENERATE FULL CSV
// ===================================================================
void generateFullCSV(String filename) {
  const int size = 500;
  const double wellRadius = 70.0;

  final grid = generateFlatWithWell(size, wellRadius);
  final buildings = generateBuildingsAroundWell(size, wellRadius);
  final trees = generateTrees(5, 500, 500 );
  final all = [...grid, ...trees, ...buildings];

  File(filename).writeAsStringSync(all.join("\n"));
}

void main() {
  generateFullCSV("test_well.csv");
}