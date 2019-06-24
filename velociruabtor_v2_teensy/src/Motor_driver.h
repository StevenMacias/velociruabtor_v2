
// Pinout
const int pinPWMA = 3;
const int pinAIN2 = 4;
const int pinAIN1 = 5;
const int pinBIN1 = 7;
const int pinBIN2 = 8;
const int pinPWMB = 9;
const int pinSTBY = 6;

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
    void test2();
    void runMotorDriver(int pwmaVal, int aIn1Val, int aIn2Val, int pwmbVal, int bIn1Val, int bIn2Val, int stbyVal);
    void getMotorDriverValues(int *values);
  private:
    int _pwmaVal=0;
    int _aIn1Val=0;
    int _aIn2Val=0;
    int _pwmbVal=0;
    int _bIn1Val=0;
    int _bIn2Val=0;
    int _stbyVal=0;
};
