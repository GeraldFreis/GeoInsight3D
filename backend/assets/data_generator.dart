/*
  data_generator.dart generates a generic lowland, midland and highland
*/
import 'dart:io';
import 'dart:math';

final rng = Random();

double rnd(double a, double b) => a + (b - a) * rng.nextDouble();

String lidarPoint(num x, num y, num z, num i) =>
    "${x.toStringAsFixed(2)},"
    "${y.toStringAsFixed(2)},"
    "${z.toStringAsFixed(2)},"
    "${i.toStringAsFixed(0)}";


List<String> generateLow(int rows, int cols) {
  final out = <String>[];
  double lastZ = 1.0;

  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      if (x % 2 != 0 || y % 2 != 0) continue;

      double z = lastZ + rnd(-0.3, 0.3);
      double intensity = rnd(80, 150);

      out.add(lidarPoint(x, y, z, intensity));
      lastZ = z;
    }
  }
  return out;
}


List<String> generateMedium(int startX, int rows, int cols) {
  final out = <String>[];

  const double lowH = 1.0;
  const double highH = 50.0;

  for (int x = 0; x < rows; x++) {
    double t = x / rows;
    double base = lowH * (1 - t) + highH * t;

    for (int y = 0; y < cols; y++) {
      if (x % 2 != 0 || y % 2 != 0) continue;

      double z = base + rnd(-1.0, 1.0);
      double intensity = rnd(120 + 60 * t, 200 + 200 * t);
      out.add(lidarPoint(startX + x, y, z, intensity));
    }
  }

  return out;
}

List<String> generateHigh(int startX, int rows, int cols) {
  final out = <String>[];

  double lastZ = 50;

  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      if (x % 2 != 0 || y % 2 != 0) continue;

      double z = lastZ + rnd(-1.0, 1.0);

      double intensity = rng.nextBool() ? rnd(200, 600) : rnd(80, 150);

      out.add(lidarPoint(startX + x, y, z, intensity));
      lastZ = z;
    }
  }
  return out;
}

List<String> generateBuildings() {
  final out = <String>[];

  for (int b = 0; b < 4; b++) {
    int x0 = rng.nextInt(50);
    int y0 = rng.nextInt(100);
    int w = rng.nextInt(15) + 10;
    int h = rng.nextInt(15) + 10;
    double roofZ = rnd(6, 12);

    // Roof
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        out.add(lidarPoint(
          x0 + x,
          y0 + y,
          roofZ + rnd(-0.15, 0.15),
          rnd(45,60),
        ));
      }
    }

    // Walls
    for (double z = 0; z < roofZ; z += 2) {
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

/*
 generateFullCSV pieces together other generate functions to create a smooth csv
    in: String filename: path to save csv
    out: none
*/
void generateFullCSV(String filename) {
  const rowsLow = 100;
  const rowsMedium = 200;
  const rowsHigh = 100;
  const cols = 300;

  final low = generateLow(rowsLow, cols);

  final medium = generateMedium(rowsLow, rowsMedium, cols);

  final high = generateHigh(rowsLow + rowsMedium, rowsHigh, cols);

  final buildings = generateBuildings();

  final all = [...low, ...medium, ...high, ...buildings];

  File(filename).writeAsStringSync(all.join("\n"));
}

void main() {
  generateFullCSV("test4.csv");
}