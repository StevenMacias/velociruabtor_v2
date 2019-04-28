/*
  Morse.cpp - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/

#include "Arduino.h"
#include "ArraySensors.h"

ArraySensors::ArraySensors()
{
  //_qtr.setTypeRC();
  //_qtr.setSensorPins((const uint8_t[]){17, 18, 19, 20, 21, 22}, NUM_SENSORS);
}

void ArraySensors::arraySensorsCalibrate()
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH); // turn on Arduino's LED to indicate we are in calibration mode
  for (uint32_t i = 0; i < 3600000; i++){
    for (uint8_t i = 0; i < NUM_SENSORS; i++)
    {
      //_calibrationMin[i] = _qtr.calibrationOn.minimum[i];
    }
  
    // print the calibration maximum values measured when emitters were on
    for (uint8_t i = 0; i < NUM_SENSORS; i++)
    {
      //_calibrationMax[i] = _qtr.calibrationOn.maximum[i];
    }
  }
  digitalWrite(LED_BUILTIN, LOW); // turn off Arduino's LED to indicate we are through with calibration

}

uint16_t* ArraySensors::getCalibrationMin()
{
  return _calibrationMin;  
}

uint16_t* ArraySensors::getCalibrationMax()
{
  return _calibrationMax;  
}
