
import 'dart:io';
import 'dart:math';

List<String> generateHillWithLake(int size) {
  final out = <String>[];

  final hillCenterX = size / 2;
  final hillCenterY = size / 2;

  final lakeStartX = hillCenterX + 50;
  final lakeStartY = hillCenterY - 100;
  const lakeSize = 40;

  const hillRadius = 60.0;
  const hillHeight = 30.0;
  const lakeDepth = -2.0;

  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
        if (x % 2 != 0 || y % 2 != 0) continue;
      double z = 1;
      double intensity = rnd(200, 350);

      // ---------- HILL (CENTER) ----------
      double dx = x - hillCenterX;
      double dy = y - hillCenterY;
      double dist = sqrt(dx * dx + dy * dy);

      if (dist < hillRadius) {
        // Smooth parabolic hill shape
        double t = 1 - (dist / hillRadius);
        z += hillHeight * t * t;
        intensity = rnd(350, 500);
      }

      // ---------- LAKE (RIGHT SIDE) ----------
      if (x > lakeStartX &&
          x < lakeStartX + lakeSize &&
          y > lakeStartY &&
          y < lakeStartY + lakeSize) {
        z += lakeDepth + rnd(-2, 1);
        intensity = rnd(30, 80);
      }

      // slight terrain noise
      z += rnd(-0.6, 0.6);

      out.add(lidarPoint(x, y, z, intensity));
    }
  }

  return out;
}

final rng = Random();

double rnd(double a, double b) => a + (b - a) * rng.nextDouble();

String lidarPoint(num x, num y, num z, num i) =>
    "${x.toStringAsFixed(2)},"
    "${y.toStringAsFixed(2)},"
    "${z.toStringAsFixed(2)},"
    "${i.toStringAsFixed(0)}";

/*
 generateFullCSV pieces together other generate functions to create a smooth csv
    in: String filename: path to save csv
    out: none
*/
void generateFullCSV(String filename) {
    const int size = 200;

    final terrain = generateHillWithLake(size);
    final all = [...terrain];

    File(filename).writeAsStringSync(all.join("\n"));
    }

void main() {
  generateFullCSV("test5.csv");
}