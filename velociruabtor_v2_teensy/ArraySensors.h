#include <QTRSensors.h>

const int STBY   = 10;
const int PWMA   = 3;
const int AIN1   = 9;

const uint8_t NUM_SENSORS = 6;

class ArraySensors
{
  public:
    ArraySensors();
    void arraySensorsCalibrate(); 
    uint16_t* getCalibrationMin(); 
    uint16_t* getCalibrationMax();
  private:
    uint16_t _sensorValues[NUM_SENSORS];
    uint16_t _calibrationMin[NUM_SENSORS];
    uint16_t _calibrationMax[NUM_SENSORS];
};
