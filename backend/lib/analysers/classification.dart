/*
    classification.dart handles the classification of regions into low lying land, high land, infrastructure (cell & power towers) and housing
    contains:
        calculateClasses()
*/
import 'package:shared/parsers/point_class.dart';

// helper function to compute percentiles for elevation
/*
Calculates what the value linked to percent is; i.e. if a value is > percent = 0.9 => value is high land
*/
double percentile(List<double> elevations, double percent) {

    if (elevations.isEmpty) return double.nan;

    elevations.sort();

    final index = (percent * (elevations.length - 1)).clamp(0, elevations.length - 1).toInt();
    return elevations[index];

}

// from a list of point clouds, finds elevation values (z)
List<double> findElevations(List<PointXYZ> point_cloud) {
    List<double> elevations = <double>[];

    for(PointXYZ point in point_cloud) {
        elevations.add(point.z);
    }

    return elevations;
}

// getting intensity values, for classifying land type
List<double> findIntensities(List<PointXYZ> point_cloud) {
    List<double> intensities = <double>[];

    for(PointXYZ point in point_cloud) {
        intensities.add(point.intensity);
    }

    return intensities;
}

// euclidean distance between points
double distance2D(PointXYZ a, PointXYZ b) {
    return ((a.x - b.x) * (a.x - b.x) +
          (a.y - b.y) * (a.y - b.y)).toDouble();
}

bool isTreeCanopyPoint(PointXYZ p) {
    // Exact match to generator
    return p.intensity >= 360 && p.intensity <= 520;
}

bool isTrunkPoint(PointXYZ p) {
    // Exact match to generator
    return p.intensity >= 45 && p.intensity <= 65;
    }

    bool isTree(PointXYZ point, List<PointXYZ> allPoints) {

  // Only test canopy points
  if (!isTreeCanopyPoint(point)) return false;

  const double canopyRadius = 6.6;   // match r = 6.5
  const double trunkRadius  = 1.2;   // slight freedom for noise

  int canopyHits = 0;
  int trunkHits = 0;

  for (var other in allPoints) {

    final d = distance2D(point, other);

    // --- canopy spherical shape ---
    if (d <= canopyRadius && isTreeCanopyPoint(other)) {
      if ((other.z - point.z).abs() < 4.0) {
        canopyHits++;
      }
    }

    // --- vertical trunk directly below canopy ---
    if (d <= trunkRadius && isTrunkPoint(other)) {
      if (other.z < point.z && (point.z - other.z) <= 15) {
        trunkHits++;
      }
    }
  }

  // ensuring that we have a point density similar to what I actually use in generating trees
  return (canopyHits > 30 && trunkHits > 6);
}
/*
    classifying buildings now
*/

bool isRoofPoint(PointXYZ p) {
    return p.intensity >= 40 && p.intensity <= 60;
}

bool isWallPoint(PointXYZ p) {
    return p.intensity > 60 && p.intensity <= 110;
}

// neighbours of the same height
bool hasFlatNeighbours(PointXYZ p, List<PointXYZ> all, double radius) {
    int same_height = 0;

    for (var o in all) {
        if ((o.z - p.z).abs() < 0.4 &&
            (o.x - p.x).abs() <= radius &&
            (o.y - p.y).abs() <= radius) {
        same_height++;
        }
    }

    return same_height > 12; // roof size approx 10x10+
}

// Detect vertical columns (walls)
bool hasVerticalChain(PointXYZ p, List<PointXYZ> all, double height) {
    int count = 0;

    for (var o in all) {
        if ((o.x - p.x).abs() < 1 &&
            (o.y - p.y).abs() < 1 &&
            (o.z - p.z).abs() <= height &&
            isWallPoint(o)) {
        count++;
        }
    }

    return count > 6; // if a vertical chain greater than 6
}

// Master building detector
bool isBuilding(PointXYZ p, List<PointXYZ> all) {

  // ROOF
  if (isRoofPoint(p) && hasFlatNeighbours(p, all, 6)) {
    return true;
  }

  // WALL
  if (isWallPoint(p) && hasVerticalChain(p, all, 20)) {
    return true;
  }

  return false;
}

// checking if a point or set of points conform to low land, high land or buildings
Future<List<String>> calculateClasses(List<PointXYZ> point_cloud) async {
    List<String> classes = <String>[];

    List<double> elevations = findElevations(point_cloud);

    double low_land_threshold = percentile(elevations, 0.15);
    double high_land_threshold = percentile(elevations, 0.85);

    // classifying land as high or low

    for(PointXYZ point in point_cloud) {

        if (isTree(point, point_cloud)) {
            classes.add("Tree");
            continue;
        }

        if (isBuilding(point, point_cloud)) {
            classes.add("Building");
            continue;
        }

        if(point.z <= low_land_threshold) {
            classes.add("Low");
        } else if(point.z >= high_land_threshold) {
            classes.add("High");
        } else {
            classes.add("Inconsequential");
        }
    }

    return classes;
}