
import 'dart:io';
import 'dart:math';

final rng = Random();

double rnd(double a, double b) => a + (b - a) * rng.nextDouble();

String lidarPoint(num x, num y, num z, num i) =>
    "${x.toStringAsFixed(2)},"
    "${y.toStringAsFixed(2)},"
    "${z.toStringAsFixed(2)},"
    "${i.toStringAsFixed(0)}";


List<String> generateTrees(int size, int count) {
  final out = <String>[];

  for (int t = 0; t < count; t++) {
    int x0 = rng.nextInt(size - 20) + 10;
    int y0 = rng.nextInt(size - 20) + 10;

    double trunkHeight = rnd(6, 12);
    double canopyZ = trunkHeight + rnd(2, 5);

    // ------------------
    // Trunk (vertical)
    // ------------------
    for (double z = 0; z <= trunkHeight; z += 0.8) {
      out.add(lidarPoint(
        x0 + rnd(-0.5, 0.5),
        y0 + rnd(-0.5, 0.5),
        z,
        rnd(45, 65), // trunk intensity
      ));
    }

    // ------------------
    // Canopy (sphere)
    // ------------------
    const double r = 6.5;

    for (double x = -r; x <= r; x += 1) {
      for (double y = -r; y <= r; y += 1) {
        if (x * x + y * y <= r * r) {
          double dz = sqrt(max(0, r * r - (x * x + y * y)));

          out.add(lidarPoint(
            x0 + x + rnd(-0.4, 0.4),
            y0 + y + rnd(-0.4, 0.4),
            canopyZ + dz + rnd(-0.8, 0.8),
            rnd(360, 520), // canopy (VERY IMPORTANT)
          ));
        }
      }
    }
  }

  return out;
}

List<String> generateBuildingsInLow(int size, int count) {
  final out = <String>[];

  for (int b = 0; b < count; b++) {
    int x0 = rng.nextInt(size - 30) + 5;
    int y0 = rng.nextInt(size - 30) + 5;
    int w = rng.nextInt(15) + 10;
    int h = rng.nextInt(15) + 10;
    double roofZ = rnd(6, 12);

    // ------------------
    // Roof
    // ------------------
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        out.add(lidarPoint(
          x0 + x,
          y0 + y,
          roofZ + rnd(-0.15, 0.15),
          rnd(45, 60), // ROOF RANGE (important for detection)
        ));
      }
    }

    // ------------------
    // Walls
    // ------------------
    for (double z = 0; z < roofZ; z += 1.2) {
      for (int x = 0; x < w; x++) {
        out.add(lidarPoint(x0 + x, y0, z, rnd(65, 110)));
        out.add(lidarPoint(x0 + x, y0 + h, z, rnd(65, 110)));
      }

      for (int y = 0; y < h; y++) {
        out.add(lidarPoint(x0, y0 + y, z, rnd(65, 110)));
        out.add(lidarPoint(x0 + w, y0 + y, z, rnd(65, 110)));
      }
    }
  }

  return out;
}
List<String> generateLow(int rows, int cols) {
  final out = <String>[];
  double lastZ = 1.0;

  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      if (x % 2 != 0 || y % 2 != 0) continue;

      double z = lastZ + rnd(-0.3, 0.3);
      double intensity = rnd(250, 400);

      out.add(lidarPoint(x, y, z, intensity));
      lastZ = z;
    }
  }
  return out;
}

void generateFullCSV(String filename) {
  const size = 200;

  final low     = generateLow(size, size);
  final trees   = generateTrees(size, 10);
  final buildings = generateBuildingsInLow(size, 6);

  final all = [
    ...low,
    ...trees,
    ...buildings,
  ];

  File(filename).writeAsStringSync(all.join("\n"));
}

void main() {
  generateFullCSV("test6.csv");
}