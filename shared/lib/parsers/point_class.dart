/*
point_class contains PointXYZ for parsing files
*/
class PointXYZ {
    final double x;
    final double y;
    final double z;
    final double intensity;
    
    // cheeky little constructor 
    PointXYZ (
        this.x,
        this.y,
        this.z,
        this.intensity,
    );

    // for printing purposes
    @override 
    String toString() => 'PointXYZ: (x: $x, y: $y, z: $z, intensity: $intensity)';

    // re-evaluating the list into raw form from json, because when we return from the server itll be in json
    factory PointXYZ.fromJSON(Map<String, dynamic> json_obj) {
        return PointXYZ (json_obj['x'], json_obj['y'], json_obj['z'], json_obj['intensity']);
    }
}