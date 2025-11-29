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
}