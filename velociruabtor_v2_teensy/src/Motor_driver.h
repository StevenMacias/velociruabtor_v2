
// Pinout
const int pinPWMA = 3;
const int pinAIN2 = 5;
const int pinAIN1 = 6;
const int pinBIN1 = 7;
const int pinBIN2 = 8;
const int pinPWMB = 4;
const int pinSTBY = 2;

const int waitTime = 2000;   //espera entre fases
const int speed = 200;      //velocidad de giro

const int pinMotorA[3] = { pinPWMA, pinAIN2, pinAIN1 };
const int pinMotorB[3] = { pinPWMB, pinBIN1, pinBIN2 };

enum moveDirection {
   forward,
   backward
};

enum turnDirection {
   clockwise,
   counterClockwise
};

class Motor_driver
{
  public:
    Motor_driver();
    void move(int direction, int speed);
    void turn(int direction, int speed);
    void fullStop();
    void moveMotorForward(const int pinMotor[3], int speed);
    void moveMotorBackward(const int pinMotor[3], int speed);
    void stopMotor(const int pinMotor[3]);
    void enableMotors();
    void disableMotors();
    void test();
  private:
    float _xVal=0;
};
