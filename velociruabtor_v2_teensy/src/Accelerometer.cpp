/*
  Morse.cpp - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/

#include "Arduino.h"
#include "Accelerometer.h"

Accelerometer::Accelerometer()
{

}


void Accelerometer::getData()
{
  // get a reading
  int xVal = analogRead(A1);
  int yVal = analogRead(A0);
  int zVal = analogRead(A14);

  // Convert raw values to 'milli-Gs"
  long xScaled = map(xVal, xMin, xMax, -1000, 1000);
  long yScaled = map(yVal, yMin, yMax, -1000, 1000);
  long zScaled = map(zVal, zMin, zMax, -1000, 1000);

  // re-scale to fractional +/- 1 Gs
  _xVal = xScaled / 1000.0;
  _yVal = yScaled / 1000.0;
  _zVal = zScaled / 1000.0;

}

float Accelerometer::getX()
{
  return _xVal;
}

float Accelerometer::getY()
{
  return _yVal;
}

float Accelerometer::getZ()
{
  return _zVal;
}
