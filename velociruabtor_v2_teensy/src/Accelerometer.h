
// Analog Input Pins used for the X,Y,Z
const int xInput = A1;  // A0 on the Teensy 3.1
const int yInput = A0;  // A1 on the Teensy 3.1
const int zInput = A14;  // A2 on the Teensy 3.1
const int selfTest = 13;

// min/max values for each axis
// measured from calibration (see the
const int xMin = 400; // (-1 G)
const int xMax = 639; // (+1 G)

const int yMin = 339; // (-1 G)
const int yMax = 630; // (+1 G)

const int zMin = 414; // (-1 G)
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
