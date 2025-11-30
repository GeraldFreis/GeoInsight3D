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

Future<List<String>> calculateLowAndHigh(List<PointXYZ> point_cloud) async {
    List<String> classes = <String>[];

    List<double> elevations = findElevations(point_cloud);

    double low_land_threshold = percentile(elevations, 0.15);
    double high_land_threshold = percentile(elevations, 0.85);

    // classifying land as high or low

    for(PointXYZ point in point_cloud) {
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