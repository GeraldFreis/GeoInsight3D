import 'dart:io';
import 'dart:math';


dynamic randomBetween(num a, num b) {
    final r = Random();

    // If either is double, generate a double
    if (a is double || b is double) {
        return a + (b - a) * r.nextDouble();
    }

    // Integers → correct upper bound handling
    return a + r.nextInt((b - a + 1).toInt());
}

// this is just a basic function to generate low and high areas
List<String> generateLow() {
    /*
        generateLow
        in: none
        out: List of strings containing lidar style comma separated double values
    */
    
    double last_height = 1.0; // we want heights to be relatively similar 
    int rows = 100;
    int columns = 100;
    double last_intensity = 65;
    final rng = Random();
    final out_list = <String>[];

    for(int i = 0; i < rows; i++) {
        
        for(int j = 0; j < columns; j++) {

            double x = i.toDouble();
            double y = j.toDouble();

            // we need to choose a z within a range of 0.5 of the last height
            double z = randomBetween(last_height - 0.5, last_height + 0.5);

            double intensity = 0;

            // now choosing whether it is vegetation or wet dirt
            int land_type = randomBetween(0,1);
            if(land_type == 0) { // wet dirt
                intensity = randomBetween(last_intensity - 5, last_intensity + 5);
            } else {
                intensity = randomBetween(100.0, 300.0);
            }

            // now that we have our values we just convert to a comma separated string
            out_list.add('${x.toStringAsFixed(2)},${y.toStringAsFixed(2)},${z.toStringAsFixed(2)},${intensity.toStringAsFixed(0)}');

            last_height = z;
            last_intensity = intensity;
        }

    }
    return out_list;
}

List<String> generateHigh(){
    /*
        generateLow
        in: none
        out: List of strings containing lidar style comma separated double values
            
    */
    
    double last_height = 50; // we want heights to be relatively similar 
    int rows = 200;
    int columns = 200;
    double last_intensity = 80;
    final rng = Random();
    final out_list = <String>[];

    for(int i = 100; i < rows; i++) {
        
        for(int j = 100; j < columns; j++) {

            double x = i.toDouble();
            double y = j.toDouble();

            // we need to choose a z within a range of 0.5 of the last height
            double z = randomBetween(last_height - 0.5, last_height + 0.5);

            double intensity = 0;

            // now choosing whether it is trees or dry dirt
            int land_type = randomBetween(0,1);
            if(land_type == 0) { // dry dirt
                intensity = randomBetween(last_intensity - 5, last_intensity + 5);
            } else {
                intensity = randomBetween(150.0, 600.0);
            }

            // now that we have our values we just convert to a comma separated string
            out_list.add('${x.toStringAsFixed(2)},${y.toStringAsFixed(2)},${z.toStringAsFixed(2)},${intensity.toStringAsFixed(0)}');

            last_height = z;
            last_intensity = intensity;
        }

    }
    return out_list;
}


void generateFullCSV() {
    final low_list = generateLow();
    final high_list = generateHigh();
    low_list.addAll(high_list);

    // generating csv
    final file = File("test2.csv");
    final csvContent = low_list.join('\n');

    file.writeAsString(csvContent);
}

void main() {
    generateFullCSV();
}