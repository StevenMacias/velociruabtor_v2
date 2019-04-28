/**
    Velociruabtor V2
    velociruabtor_v2_teensy.ino
    Purpose: Develop a line follower using Teensy 3.2

    @author Steven Macías and Victor Escobedo
    @version 1.0 22/04/2019
*/
#include <Arduino.h>
#include <ArduinoJson.h>
#include <QTRSensors.h>
#include "Accelerometer.h"

#define BT_SERIAL Serial1
#define CABLE_SERIAL Serial
#define BT_UART_BAUDRATE 38400
#define CABLE_UART_BAUDRATE 115200
#define NUM_SENSORS 6

QTRSensorsRC qtrrc((unsigned char[]) {A3, A4, A5, A6, A7, A8} ,NUM_SENSORS, 2500, QTR_NO_EMITTER_PIN);
StaticJsonDocument<1024> json;
Accelerometer accel;
int position = 0;
unsigned int sensorValues[NUM_SENSORS];

/**
    Calibrates the QTR-RC Sensor array
    @param none
    @return void
*/
void calibrateQtrc()
{
  digitalWrite(LED_BUILTIN, HIGH);
  for(int i = 0; i<300; i++)
  {
    qtrrc.calibrate();
  }
  digitalWrite(LED_BUILTIN, LOW);
}

/**
    Function that initializes the system
    @param none
    @return void
*/
void setup()
{
  json.clear();
  // Configure Bluetooth UART
  BT_SERIAL.begin(BT_UART_BAUDRATE);
  // Configure USB UART
  CABLE_SERIAL.begin(CABLE_UART_BAUDRATE);
  // Create Objects
  accel = Accelerometer();
  // Configure Built In LED
  pinMode(LED_BUILTIN, OUTPUT);
  // Calibrate Sensors Array
  calibrateQtrc();
}

/**
    Builds a JSON string that contains all the data regarging the line follower.
    @param none
    @return void
*/
void buildAccelJson()
{
  json.clear();
  // Acceleremoter values
  json["xAccel"] = accel.getX();
  json["yAccel"] = accel.getY();
  json["zAccel"] = accel.getY();

  // Array Sensors values
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

/**
    Main loop of the project
    @param none
    @return void
*/
void loop()
{
  accel.getData();
  buildAccelJson();
  serializeJson(json, BT_SERIAL);
  serializeJson(json, CABLE_SERIAL);
  BT_SERIAL.print('\n');
  CABLE_SERIAL.print('\n');
}
