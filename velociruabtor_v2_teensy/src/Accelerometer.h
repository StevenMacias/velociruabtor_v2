
// Analog Input Pins used for the X,Y,Z 
const int xInput = 14;  // A0 on the Teensy 3.1
const int yInput = 15;  // A1 on the Teensy 3.1
const int zInput = 16;  // A2 on the Teensy 3.1

// min/max values for each axis
// measured from calibration (see the 
const int xMin = 406; // (-1 G)
const int xMax = 612; // (+1 G)

const int yMin = 404; // (-1 G)
const int yMax = 610; // (+1 G)

const int zMin = 440; // (-1 G)
const int zMax = 643; // (+1 G)

class Accelerometer
{
  public:
    Accelerometer();
    void getData();
    float getX();
    float getY(); 
    float getZ();
  private:
    float _xVal=0;
    float _yVal=0;
    float _zVal=0;
};
