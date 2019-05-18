/*
  Morse.cpp - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/

#include "Arduino.h"
#include "Motor_driver.h"

Motor_driver::Motor_driver()
{
   pinMode(pinAIN2, OUTPUT);
   pinMode(pinAIN1, OUTPUT);
   pinMode(pinPWMA, OUTPUT);
   pinMode(pinBIN1, OUTPUT);
   pinMode(pinBIN2, OUTPUT);
   pinMode(pinPWMB, OUTPUT);
   pinMode(pinSTBY, OUTPUT);
}
void Motor_driver::move(int direction, int speed)
{
   if (direction == forward)
   {
      moveMotorForward(pinMotorA, speed);
      moveMotorForward(pinMotorB, speed);
   }
   else
   {
      moveMotorBackward(pinMotorA, speed);
      moveMotorBackward(pinMotorB, speed);
   }
}

void Motor_driver::turn(int direction, int speed)
{
   if (direction == forward)
   {
      moveMotorForward(pinMotorA, speed);
      moveMotorBackward(pinMotorB, speed);
   }
   else
   {
      moveMotorBackward(pinMotorA, speed);
      moveMotorForward(pinMotorB, speed);
   }
}

void Motor_driver::fullStop()
{
   disableMotors();
   stopMotor(pinMotorA);
   stopMotor(pinMotorB);
}

//Funciones que controlan los motores
void Motor_driver::moveMotorForward(const int pinMotor[3], int speed)
{
   digitalWrite(pinMotor[1], HIGH);
   digitalWrite(pinMotor[2], LOW);

   analogWrite(pinMotor[0], speed);
}

void Motor_driver::moveMotorBackward(const int pinMotor[3], int speed)
{
   digitalWrite(pinMotor[1], LOW);
   digitalWrite(pinMotor[2], HIGH);

   analogWrite(pinMotor[0], speed);
}

void Motor_driver::stopMotor(const int pinMotor[3])
{
   digitalWrite(pinMotor[1], LOW);
   digitalWrite(pinMotor[2], LOW);

   analogWrite(pinMotor[0], 0);
}

void Motor_driver::enableMotors()
{
   digitalWrite(pinSTBY, HIGH);
}

void Motor_driver::disableMotors()
{
   digitalWrite(pinSTBY, LOW);
}

void Motor_driver::test()
{
  enableMotors();
  move(forward, 180);
  delay(waitTime);

  move(backward, 180);
  delay(waitTime);

  turn(clockwise, 180);
  delay(waitTime);

  turn(counterClockwise, 180);
  delay(waitTime);

  fullStop();
  delay(waitTime);
}

void Motor_driver::runMotorDriver(int pwmaVal, int aIn1Val, int aIn2Val, int pwmbVal, int bIn1Val, int bIn2Val, int stbyVal)
{
  // STBY PIN
  digitalWrite(pinSTBY, stbyVal);
  _stbyVal = stbyVal;
  // MOTOR A
  analogWrite(pinMotorA[0], pwmaVal);
  _pwmaVal = pwmaVal;
  digitalWrite(pinMotorA[1], aIn2Val);
  _aIn2Val = aIn2Val;
  digitalWrite(pinMotorA[2], aIn1Val);
  _aIn1Val = aIn1Val;
  // MOTOR B
  analogWrite(pinMotorB[0], pwmbVal);
  _pwmbVal = pwmbVal;
  digitalWrite(pinMotorB[1], bIn1Val);
  _bIn1Val = bIn1Val;
  digitalWrite(pinMotorB[2], bIn2Val);
  _bIn2Val = bIn2Val;
}

void Motor_driver::test2()
{
  int i;
  for(i=0; i<255; i++)
  {
    runMotorDriver(i, HIGH, LOW, i, HIGH, LOW, HIGH);
    delay(5);
  }
  for(i=0; i<255; i++)
  {
    runMotorDriver(i, LOW, HIGH, i, LOW, HIGH, HIGH);
    delay(5);
  }
}

void Motor_driver::getMotorDriverValues(int *values)
{
  values[0] = _pwmaVal;
  values[1] = _aIn2Val;
  values[2] = _aIn1Val;
  values[3] = _pwmbVal;
  values[4] = _bIn1Val;
  values[5] = _bIn2Val;
  values[6] = _stbyVal;
}
