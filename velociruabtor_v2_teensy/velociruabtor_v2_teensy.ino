#include <ArduinoJson.h>
#include <QTRSensors.h>
#include "Accelerometer.h"
#include "ArraySensors.h"

#define HWSERIAL Serial1


// Sketch for the ADXL335 
// Reads the raw X, Y Z values from the accelerometer and normalizes them to +/-1 range.
// Tested on the Teensy 3.1
// For use with project found at 
// http://codergirljp.blogspot.com/2014/05/adxl335-accelerometer-on-teensy-31.html
QTRSensorsRC qtrrc((unsigned char[]) {A3, A4, A5, A6, A7, A8} ,NUM_SENSORS, 2500, QTR_NO_EMITTER_PIN); // sensor connected through analog pins A0 - A5 i.e. digital pins 14-19
struct jsonStruct
{
  float xAccel;
  float yAccel;
  float zAccel;
} ;
StaticJsonDocument<1024> json;
struct jsonStruct json_struct;
Accelerometer accel;
ArraySensors array_sensors; 
int position = 0; 
unsigned int sensorValues[NUM_SENSORS];

void setup()
{         
  json.clear();       
  HWSERIAL.begin(115200);
  accel = Accelerometer();
  array_sensors = ArraySensors(); 
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  for(int i = 0; i<300; i++)
  {
    qtrrc.calibrate();
    //delay(20);
  }
  digitalWrite(LED_BUILTIN, LOW);
}

void buildAccelJson()
{
  json.clear();
  // Acceleremoter values 
  json_struct.xAccel = accel.getX(); 
  json["xAccel"] = json_struct.xAccel;
  json_struct.yAccel = accel.getY(); 
  json["yAccel"] = json_struct.yAccel;
  json_struct.zAccel = accel.getZ(); 
  json["zAccel"] = json_struct.zAccel;

  // Array Sensors values
  uint16_t* array_calib_min_ptr = array_sensors.getCalibrationMin();
  uint16_t* array_calib_max_ptr = array_sensors.getCalibrationMax();
  uint8_t i; 
  for(i=0; i<NUM_SENSORS; i++)
  {
    json["array_calib_min"].add(qtrrc.calibratedMinimumOn[i]);
    json["array_calib_max"].add(qtrrc.calibratedMaximumOn[i]);
    position = qtrrc.readLine(sensorValues);
    json["array_values"].add(sensorValues[i]);
  }
  json["array_position"] = position;
  

  
}

void loop()                     
{
  accel.getData();
  buildAccelJson();
  serializeJson(json, HWSERIAL);
  HWSERIAL.print('\n');
  delay(100);
}
