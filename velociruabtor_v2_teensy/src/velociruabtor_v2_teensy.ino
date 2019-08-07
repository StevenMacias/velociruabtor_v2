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
#include <Encoder.h>
#include "Accelerometer.h"
#include "Motor_driver.h"

#define PI 3.1415926535897932384626433832795
#define WHEEL_GEAR_DIVIDER 10.00
#define WHEEL_DIAMETER_MILIMETERS 28.00
#define WHEEL_PERIMETER (PI*WHEEL_DIAMETER_MILIMETERS)
#define ENCODER_OPTIMIZE_INTERRUPTS
#define BT_SERIAL Serial1
#define CABLE_SERIAL Serial
#define BT_UART_BAUDRATE 38400
#define CABLE_UART_BAUDRATE 115200
#define NUM_SENSORS 8
#define ARDUINOJSON_DEFAULT_NESTING_LIMIT 4

#define Kp 0.1 // experiment to determine this, start by something small that just makes your bot follow the line at a slow speed
#define Kd 4// experiment to determine this, slowly increase the speeds and adjust this value. ( Note: Kp < Kd)
#define MaxSpeed 255// max speed of the robot
#define BaseSpeed 255 // this is the speed at which the motors should spin when the robot is perfectly on the line
#define NUM_SENSORS  8     // number of sensors used
#define speedturn 180


QTRSensorsRC qtrrc((unsigned char[]) {A2, A3, A4, A5, A6, A7, A8, A9} ,NUM_SENSORS, 2500, QTR_NO_EMITTER_PIN);
StaticJsonDocument<1024> json;
StaticJsonDocument<2048> rx_json;
Accelerometer accel;
Motor_driver motor_driver;
int position = 0;
unsigned int sensorValues[NUM_SENSORS];
int motorValues[7];
int lastError = 0;
unsigned long start_time = millis();
unsigned long end_time = millis();
Encoder encoderLeft(2, 10);
Encoder encoderRight(12, 11); // Pins inversed
float rpm_encoder_left = 0;
float rpm_encoder_right = 0;
float rpm_wheel_left = 0;
float rpm_wheel_right = 0;
float average_speed_m_s = 0;
int calibrateSensorsState = 0;
int jsonError = 0;
unsigned long encoder_elapsed_time = 0;
long encoder_left_count, encoder_right_count;
char serial_data[2048] = "";
int enable = 0;
float kp = 1;
float kd = 1;
int baseSpeed = 0;
int period = 200;
unsigned long time_now = 0;
boolean lets_start = false;
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
  json["zAccel"] = accel.getZ();

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
Builds a JSON string that contains all the data regarging the motor driver.
@param none
@return void
*/
void buildMotorDriverJson()
{
  json["PWMA"] = motorValues[0];
  json["AIN1"] = motorValues[2];
  json["AIN2"] = motorValues[1];
  json["PWMB"] = motorValues[3];
  json["BIN1"] = motorValues[4];
  json["BIN2"] = motorValues[5];
  json["STBY"] = motorValues[6];
}

void buildEncoderJson()
{
  json["rpm_encoder_left"] = rpm_encoder_left;
  json["rpm_encoder_right"] = rpm_encoder_right;
  json["encoder_elapsed_time"] = encoder_elapsed_time;
  json["rpm_wheel_left"] = rpm_wheel_left;
  json["rpm_wheel_right"] = rpm_wheel_right;
  json["average_speed_m_s"] = average_speed_m_s;
  json["encoder_left_count"] = encoder_left_count;
  json["encoder_right_count"] = encoder_right_count;
  json["calibrateSensorsState"] = calibrateSensorsState;
  json["jsonError"] = jsonError;
  json["lets_start"] = lets_start;
}


/**
Calibrates the QTR-RC Sensor array
@param none
@return void
*/
void calibrateQtrc()
{
  int i = 0;
  for (int i; i < 20; i++) // calibrate for sometime by sliding the sensors across the line, or you may use auto-calibration instead
  { 	//Added open brace here

    if ( i  <= 5 || i >= 15 ) // turn to the left and right to expose the sensors to the brightest and darkest readings that may be encountered
    {
      motor_driver.runMotorDriver(100, LOW, HIGH, 100, LOW, HIGH, HIGH);
    }
    else
    {
      motor_driver.runMotorDriver(100, HIGH, LOW, 100, HIGH, LOW, HIGH);
    }
    qtrrc.calibrate();
    delay(20);

  }  	//Added close brace here
  calibrateSensorsState = 2;
  motor_driver.runMotorDriver(0, LOW, HIGH, 0, HIGH, LOW, LOW);

}

/**
Function that initializes the system
@param none
@return void
*/
void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(A1, INPUT);
  pinMode(A0, INPUT);
  pinMode(A14, INPUT);
  //digitalWrite(LED_BUILTIN, HIGH);
  json.clear();
  // Configure Bluetooth UART
  BT_SERIAL.begin(BT_UART_BAUDRATE);
  // Configure USB UART
  CABLE_SERIAL.begin(CABLE_UART_BAUDRATE);
  // Create Objects
  accel = Accelerometer();
  motor_driver = Motor_driver();
  //motor_driver.enableMotors();
  // Calibrate Sensors Array
  calibrateQtrc();
  //digitalWrite(LED_BUILTIN, LOW);
  BT_SERIAL.setTimeout(50);
}

/**
Test function for the motor driver
@param none
@return void
*/
void testMotorDriver()
{
  static int i=0;
  static bool forward = true;

  if(forward == true)
  {
    motor_driver.runMotorDriver(i, LOW, HIGH, i, LOW, HIGH, HIGH);
  }else{
    motor_driver.runMotorDriver(i, HIGH, LOW, i, HIGH, LOW, HIGH);
  }
  i++;
  if(i>=255)
  {
    forward = !forward;
    i = 0;
  }
}

void computePidAndDrive()
{
  position = qtrrc.readLine(sensorValues); // get calibrated readings along with the line position, refer to the QTR Sensors Arduino Library for more details on line position.

  if(position>6700){
    motor_driver.runMotorDriver(speedturn, HIGH, LOW, speedturn, LOW, HIGH, enable);
    return;
  }
  if(position<300){
    motor_driver.runMotorDriver(speedturn, LOW, HIGH, speedturn, HIGH, LOW, enable);
    return;
  }

  int error = position - 3500;
  int motorSpeed = kp * error + kd * (error - lastError);
  lastError = error;

  int rightMotorSpeed = baseSpeed + motorSpeed;
  int leftMotorSpeed = baseSpeed - motorSpeed;

  if (rightMotorSpeed > MaxSpeed ) rightMotorSpeed = MaxSpeed; // prevent the motor from going beyond max speed
  if (leftMotorSpeed > MaxSpeed ) leftMotorSpeed = MaxSpeed; // prevent the motor from going beyond max speed
  if (rightMotorSpeed < 0)rightMotorSpeed = 0;
  if (leftMotorSpeed < 0)leftMotorSpeed = 0;
  motor_driver.runMotorDriver(rightMotorSpeed, LOW, HIGH, leftMotorSpeed, HIGH, LOW, enable);
}

void calculateRPM()
{
  end_time = millis();
  encoder_elapsed_time = end_time - start_time;

  encoder_left_count = encoderLeft.read();
  encoder_right_count = encoderRight.read();
  //rpm_encoder_left = 60000.00*encoder_left_count/encoder_elapsed_time/12;
  //rpm_encoder_right = 60000.00*encoder_right_count/encoder_elapsed_time/12;
  rpm_encoder_left = ((encoder_left_count/12.00)/encoder_elapsed_time)*60000;
  rpm_encoder_right = ((encoder_right_count/12.00)/encoder_elapsed_time)*60000;
  rpm_wheel_left = rpm_encoder_left/WHEEL_GEAR_DIVIDER;
  rpm_wheel_right = rpm_encoder_right/WHEEL_GEAR_DIVIDER;

  average_speed_m_s = (((rpm_wheel_left+rpm_wheel_right)/2)*WHEEL_PERIMETER/1000)/60; //Average wheel speed * perimeter / 60 seconds = meters/second
  encoderLeft.write(0);
  encoderRight.write(0);
  start_time = millis();
}

void sendJsonByBluetooth(boolean force)
{
    // avoid uart saturation
    if(((millis() > time_now + period) || force)&&lets_start){
      motor_driver.getMotorDriverValues(motorValues);
      accel.getData();
      buildAccelJson();
      buildMotorDriverJson();
      buildEncoderJson();
      time_now = millis();
      serializeJson(json, BT_SERIAL);
      serializeJson(json, CABLE_SERIAL);
      BT_SERIAL.print('\n');
      CABLE_SERIAL.print('\n');
  }
}
/**
Main loop of the project
@param none
@return void
*/
void loop()
{
  calculateRPM();
  computePidAndDrive();
  sendJsonByBluetooth(false);



  /*if(CABLE_SERIAL.available() > 0) {
    //a= Serial.readString();// read the incoming data as string
    CABLE_SERIAL.readBytesUntil('\n', serial_data, 128);
    rx_json.clear();
    deserializeJson(rx_json, serial_data);
    enable = rx_json["enable"];
    kp = rx_json["kp"];
    kd = rx_json["kd"];
    baseSpeed = rx_json["baseSpeed"];
    calibrateSensorsState = rx_json["calibrateSensorsState"];
  }*/
  if(BT_SERIAL.available() > 0) {
    //a= Serial.readString();// read the incoming data as string
    BT_SERIAL.readBytesUntil('\n', serial_data, sizeof(serial_data)-1);
    rx_json.clear();
    DeserializationError err = deserializeJson(rx_json, serial_data,DeserializationOption::NestingLimit(4));

    switch (err.code()) {
    case DeserializationError::Ok:
        enable = rx_json["enable"];
        kp = rx_json["kp"];
        kd = rx_json["kd"];
        baseSpeed = rx_json["baseSpeed"];
        calibrateSensorsState = rx_json["calibrateSensorsState"];
        lets_start = rx_json["lets_start"];
        jsonError = 0;
        break;
    case DeserializationError::InvalidInput:
        jsonError = 1;
        digitalWrite(LED_BUILTIN,HIGH);
        delay(50);
        BT_SERIAL.flush();
        digitalWrite(LED_BUILTIN,LOW);
        break;
    case DeserializationError::NoMemory:
        jsonError = 2;
        break;
    default:
        jsonError = 3;
        break;
      }

    sendJsonByBluetooth(true);

  }

  if((calibrateSensorsState == 1)&&(lets_start ==1))
  {
    sendJsonByBluetooth(true);
    calibrateQtrc();
  }
  //delay(22);
}
