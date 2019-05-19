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

#define Kp 0.1 // experiment to determine this, start by something small that just makes your bot follow the line at a slow speed
#define Kd 4// experiment to determine this, slowly increase the speeds and adjust this value. ( Note: Kp < Kd)
#define MaxSpeed 255// max speed of the robot
#define BaseSpeed 255 // this is the speed at which the motors should spin when the robot is perfectly on the line
#define NUM_SENSORS  8     // number of sensors used
#define speedturn 180


QTRSensorsRC qtrrc((unsigned char[]) {A3, A4, A5, A6, A7, A8, A9, 12} ,NUM_SENSORS, 2500, QTR_NO_EMITTER_PIN);
StaticJsonDocument<1024> json;
Accelerometer accel;
Motor_driver motor_driver;
int position = 0;
unsigned int sensorValues[NUM_SENSORS];
int motorValues[7];
int lastError = 0;
unsigned long start_time = millis();
unsigned long end_time = millis();
Encoder encoderLeft(2, 9);
Encoder encoderRight(11, 10); // Pins inversed
float rpm_encoder_left = 0;
float rpm_encoder_right = 0;
float rpm_wheel_left = 0;
float rpm_wheel_right = 0;
float average_speed_m_s = 0;
unsigned long encoder_elapsed_time = 0;
long encoder_left_count, encoder_right_count;
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

}


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
  motor_driver = Motor_driver();
  motor_driver.enableMotors();
  // Calibrate Sensors Array
  calibrateQtrc();
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
    motor_driver.runMotorDriver(speedturn, HIGH, LOW, speedturn, LOW, HIGH, HIGH);
    return;
  }
  if(position<300){
    motor_driver.runMotorDriver(speedturn, LOW, HIGH, speedturn, HIGH, LOW, HIGH);
    return;
  }

  int error = position - 3500;
  int motorSpeed = Kp * error + Kd * (error - lastError);
  lastError = error;

  int rightMotorSpeed = BaseSpeed + motorSpeed;
  int leftMotorSpeed = BaseSpeed - motorSpeed;

  if (rightMotorSpeed > MaxSpeed ) rightMotorSpeed = MaxSpeed; // prevent the motor from going beyond max speed
  if (leftMotorSpeed > MaxSpeed ) leftMotorSpeed = MaxSpeed; // prevent the motor from going beyond max speed
  if (rightMotorSpeed < 0)rightMotorSpeed = 0;
  if (leftMotorSpeed < 0)leftMotorSpeed = 0;
  motor_driver.runMotorDriver(rightMotorSpeed, HIGH, LOW, leftMotorSpeed, LOW, HIGH, HIGH);
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

/**
    Main loop of the project
    @param none
    @return void
*/
void loop()
{
  motor_driver.disableMotors();
  calculateRPM();
  computePidAndDrive();
  motor_driver.getMotorDriverValues(motorValues);
  accel.getData();
  buildAccelJson();
  buildMotorDriverJson();
  buildEncoderJson();
  serializeJson(json, BT_SERIAL);
  serializeJson(json, CABLE_SERIAL);
  BT_SERIAL.print('\n');
  CABLE_SERIAL.print('\n');
}
