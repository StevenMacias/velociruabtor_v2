import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class velociruabtor_v2_ui extends PApplet {

/**
Velociruabtor V2 User Interface
velociruabtor_v2_teensy.pde
Purpose: Develop a user interface for the Velociruabtor v2

@author Steven Macías and Víctor Escobedo
@version 1.0 22/04/2019
*/


Serial serial_port = null;

// Configuration constants

static final String COM_PORT  = "COM4";
static final int COM_BAUDRATE = 9600;

// Fonts
PFont arial_bold;
PFont arial;

// Window constants
static final int text_size          = 12;
static final int window_x_size      = 1280;
static final int window_y_size      = 720;
static final int accel_grid_color   = 255;
static final int background_color   = 0;

// Accel constants
static final int accel_graph_size        = 150;
static final int accel_graph_half_size   = (accel_graph_size/2);
static final int accel_graph_point_size  = (accel_graph_size/10);
static final int accel_graph_multiplier  = (accel_graph_size/3);
static final int accel_graph_x_pos       = 100;
static final int accel_graph_y_pos       = 120;
static final int accel_z_graph_x_pos     = accel_graph_x_pos+(accel_graph_point_size*2);
static final int accel_z_graph_y_pos     = accel_graph_y_pos+0;
static final int calib_values_x_pos      = 100;
static final int calib_values_y_pos      = 25;
static final int array_values_x_pos      = 500;
static final int array_values_y_pos      = 25;
static final int speed_values_x_pos      = 900;
static final int speed_values_y_pos      = 25;
static final boolean DEBUG_ON            = false;
static final int serial_x_pos       = 100;
static final int serial_y_pos       = 600;

// Motor driver constants
int PWMA  =  0;
int AIN1  =  0;
int AIN2  =  0;
int PWMB  =  0;
int BIN1  =  0;
int BIN2  =  0;
int STBY  =  0;
int AOUT1  =  -1;
int AOUT2  =  -1;
int BOUT1  =  -1;
int BOUT2  =  -1;

//TEMPORALES
int OUT1 = -1;
int OUT2 = -1;
//MOTOR WAY
String texto = "";

static final int motor_driver_distance_between_graphs  = 100;

static final int motor_driver_graph_size        = 150;
static final int motor_driver_graph_half_size   = (motor_driver_graph_size/2);
static final int motor_driver_graph_x_pos       = array_values_x_pos;
static final int motor_driver_graph_y_pos       = accel_graph_y_pos;
static final int motor_driver_graph_rect_width  = 40;

// serial port buttons
Button btn_serial_up;              // move up through the serial port list
Button btn_serial_dn;              // move down through the serial port list
Button btn_serial_connect;         // connect to the selected serial port
Button btn_serial_disconnect;      // disconnect from the serial port
Button btn_serial_list_refresh;    // refresh the serial port list
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port
int num_serial_ports = 0;          // number of serial ports in the list


// variables for the coordinates
int accel_x_value         = 0;
int accel_y_value         = 0;
int accel_z_value         = 0;
String accel_x_raw_value  = "0.00";
String accel_y_raw_value  = "0.00";
String accel_z_raw_value  = "0.00";
JSONArray array_calib_min = new JSONArray();
JSONArray array_calib_max = new JSONArray();
JSONArray array_values = new JSONArray();

// Variables for speed and RPMs
float rpm_encoder_left;
float rpm_encoder_right;
int encoder_elapsed_time;
float rpm_wheel_left;
float rpm_wheel_right;
float average_speed_m_s;
long encoder_left_count;
long encoder_right_count;

public void PRINT(String s)
{
  if(DEBUG_ON)
  {
    print(s);
  }
}
///*BUTTON*/
//float x = 500;
//float y = 250;
//float w = 150;
//float h = 80;

/**
Draw the graph regarding accelerometer values.
@param none-
@return void
*/
public void drawAccelerometerGraph()
{
  stroke(accel_grid_color);
  // Y Axis Line
  line((accel_graph_half_size+accel_graph_x_pos), (0+accel_graph_y_pos), (accel_graph_half_size+accel_graph_x_pos), (accel_graph_size+accel_graph_y_pos));
  // X Axis Line
  line((0+accel_graph_x_pos), (accel_graph_half_size+accel_graph_y_pos), (accel_graph_size+accel_graph_x_pos), (accel_graph_half_size+accel_graph_y_pos));
  // Z Axis Line
  line((accel_graph_size+accel_z_graph_x_pos), (0+accel_z_graph_y_pos), (accel_z_graph_x_pos+accel_graph_size), (accel_graph_size+accel_z_graph_y_pos));
  // draw the ellipse
  noStroke();
  fill(255, 0, 0);
  ellipse((accel_graph_half_size+accel_y_value+accel_graph_x_pos), (accel_graph_half_size+accel_x_value+accel_graph_y_pos), accel_graph_point_size, accel_graph_point_size);
  ellipse((accel_graph_size+accel_z_graph_x_pos), (accel_z_value+accel_z_graph_y_pos+(accel_graph_half_size/2)), accel_graph_point_size, accel_graph_point_size);
  // draw the text
  fill(255);
  text("X: ", (accel_graph_x_pos+10), (accel_graph_size+accel_graph_y_pos-40));
  text(accel_x_raw_value, (accel_graph_x_pos+25), (accel_graph_size+accel_graph_y_pos-40));
  text("Y: ", (accel_graph_x_pos+10), (accel_graph_size+accel_graph_y_pos-20));
  text(accel_y_raw_value, (accel_graph_x_pos+25), (accel_graph_size+accel_graph_y_pos-20));
  text("Z: ", (accel_graph_x_pos+10), (accel_graph_size+accel_graph_y_pos-0));
  text(accel_z_raw_value, (accel_graph_x_pos+25), (accel_graph_size+accel_graph_y_pos-0));
}


public void drawMotorDriverGraph()
{
  int[] temp_array_values = array_values.getIntArray();
  for (int i = 0; i<array_calib_min.size(); i++)
  {
    text(temp_array_values[i], (array_values_x_pos+(40*(i))), array_values_y_pos+20);
    fill(map(temp_array_values[i], 0, 1000, 0, 255));
    stroke(255);
    rect((array_values_x_pos+(40*(i))), (array_values_y_pos+35), 30, 5);
    fill(255);
  }

  //MOTOR LEFT
  noFill();  // Set fill to white
  rect(motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos, motor_driver_graph_rect_width, -100);
  fill(255);
  rect(motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos, motor_driver_graph_rect_width, -map(PWMA, 0, 255, 0, 100));

  //FW/BW LEFT
  text("L: ", (motor_driver_graph_x_pos+(motor_driver_graph_rect_width/2)),  accel_graph_y_pos+accel_graph_size-100-5);
  fill(0);
  if(AOUT1 == 0 && AOUT2 == 1){
    fill(248,243,43);
    texto = "BW";
  }
  if(AOUT1 == 1 && AOUT2 == 0){
    fill(124,252,0);
    texto = "FW";
  }
  rect(motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos+10, motor_driver_graph_rect_width, 10);
  fill(0);
  text(texto, motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos+10+10);

  /* --- BRAKE LEFT --- */
  if(AOUT1 == 0 && AOUT2 == 0){
    fill(255,0,0);
  }else{
    fill(0);
  }
  rect(motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos+25, motor_driver_graph_rect_width, 10);
  fill(0);
  text("BRAKE", motor_driver_graph_x_pos, accel_graph_size+accel_graph_y_pos+25+10);

  /*-----------------------------------------------------------------------------------------------------------*/
  //MOTOR RIGHT
  noFill();  // Set fill to white
  rect(motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos, motor_driver_graph_rect_width, -100);
  fill(255);
  rect(motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos, motor_driver_graph_rect_width, -map(PWMB, 0, 255, 0, 100));

  //FW/BW RIGHT
  text("R: ", (motor_driver_graph_x_pos+(motor_driver_graph_rect_width/2)+motor_driver_distance_between_graphs),  accel_graph_y_pos+accel_graph_size-100-5);
  fill(0);
  if(BOUT1 == 0 && BOUT2 == 1){
    fill(248,243,43);
    texto = "BW";
  }
  if(BOUT1 == 1 && BOUT2 == 0){
    fill(124,252,0);
    texto = "FW";
  }
  fill(0);
  rect(motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos+10, motor_driver_graph_rect_width, 10);
  text(texto, motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos+10+10);

  /* --- BRAKE RIGHT --- */
  if(BOUT1 == 0 && BOUT2 == 0){
    fill(255,0,0);
  }else{
    fill(0);
  }
  rect(motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos+25, motor_driver_graph_rect_width, 10);
  fill(0);
  text("BRAKE", motor_driver_graph_x_pos+motor_driver_distance_between_graphs, accel_graph_size+accel_graph_y_pos+25+10);
}


public void logicMotorDriver(int motor,int IN1, int IN2, int PWM, int STBY)
{
  if (STBY == 0){
    PRINT("Motor:"+motor+"-STANDBY"+"\r\n");
    OUT1  =  -1;
    OUT2  =  -1;
  }else{
    if(IN1 == 0 && IN2 == 0){
      PRINT("Motor:"+motor+"-STOP"+"\r\n");
      OUT1  =  -1;
      OUT2  =  -1;
    }else{
      if(IN1 == 1 && IN2 == 1){
        PRINT("Motor:"+motor+"-SHORT BRAKE"+"\r\n");
        OUT1  =  0;
        OUT2  =  0;
      }else{
        if(PWM == 0){
          PRINT("Motor:"+motor+"-SHORT BRAKE"+"\r\n");
          OUT1  =  0;
          OUT2  =  0;
        }else{
          if(IN1 == 1){
            PRINT("Motor:"+motor+"-CW"+"\r\n");
            OUT1  =  1;
            OUT2  =  0;
          }else{
            PRINT("Motor:"+motor+"-CCW"+"\r\n");
            OUT1  =  0;
            OUT2  =  1;
          }
        }
      }
    }
  }
  if(motor == 1){
    AOUT1 = OUT1;
    AOUT2 = OUT2;
  }else{
    BOUT1 = OUT1;
    BOUT2 = OUT2;
  }
}



/**
Draw graph regarding sensor array
@param none
@return void
*/
public void drawSensorArrayGraph()
{
  textFont(arial_bold);
  text("Calibration values", (calib_values_x_pos), calib_values_y_pos);
  text("IR array values", (array_values_x_pos), array_values_y_pos);
  text("Accelerometer", (accel_graph_x_pos), accel_graph_y_pos-10);
  text("Motor driver", (array_values_x_pos), accel_graph_y_pos-10);
  int[] temp_min_values = array_calib_min.getIntArray();
  int[] temp_max_values = array_calib_max.getIntArray();
  int[] temp_array_values = array_values.getIntArray();
  text("Min: ", (calib_values_x_pos), (calib_values_y_pos+20));
  text("Max: ", (calib_values_x_pos), (calib_values_y_pos+40));
  textFont(arial);
  for (int i = 0; i<array_calib_min.size(); i++)
  {
    text(temp_min_values[i], (calib_values_x_pos+(40*(i+1))), calib_values_y_pos+20);
    text(temp_max_values[i], (calib_values_x_pos+(40*(i+1))), calib_values_y_pos+40);
    text(temp_array_values[i], (array_values_x_pos+(40*(i))), array_values_y_pos+20);
    fill(map(temp_array_values[i], 0, 1000, 0, 255));
    stroke(255);
    rect((array_values_x_pos+(40*(i))), (array_values_y_pos+35), 30, 5);
    fill(255);
  }
}

/**
Draw graph regarding sensor array
@param none
@return void
*/
public void drawSpeedValuesGraph()
{
  textFont(arial_bold);
  text("Speed values", speed_values_x_pos, speed_values_y_pos);

  text("encoder_elapsed_time: ", (speed_values_x_pos), (speed_values_y_pos+20));
  text(encoder_elapsed_time, (speed_values_x_pos+150), (speed_values_y_pos+20));
  text("encoder_left_count: ", (speed_values_x_pos), (speed_values_y_pos+35));
  text(encoder_left_count, (speed_values_x_pos+150), (speed_values_y_pos+35));
  text("encoder_right_count: ", (speed_values_x_pos), (speed_values_y_pos+50));
  text(encoder_right_count, (speed_values_x_pos+150), (speed_values_y_pos+50));

  text("rpm_encoder_left: ", (speed_values_x_pos), (speed_values_y_pos+70));
  text(rpm_encoder_left, (speed_values_x_pos+150), (speed_values_y_pos+70));
  text("rpm_encoder_right: ", (speed_values_x_pos), (speed_values_y_pos+85));
  text(rpm_encoder_right, (speed_values_x_pos+150), (speed_values_y_pos+85));

  text("rpm_wheel_left: ", (speed_values_x_pos), (speed_values_y_pos+105));
  text(rpm_wheel_left, (speed_values_x_pos+150), (speed_values_y_pos+105));
  text("rpm_wheel_right: ", (speed_values_x_pos), (speed_values_y_pos+120));
  text(rpm_wheel_right, (speed_values_x_pos+150), (speed_values_y_pos+120));

  text("average_speed_m_s: ", (speed_values_x_pos), (speed_values_y_pos+140));
  text(average_speed_m_s, (speed_values_x_pos+150), (speed_values_y_pos+140));


}



/**
Function that is called everytime a JSON string arrives through the UART
@param none
@return void
*/
public void serialEvent(Serial serial_port) {
  try {
    String buffer = serial_port.readStringUntil('\n');
    if (buffer != null) {
      JSONObject json = parseJSONObject(buffer);
      if (json == null) {
        println("JSONObject could not be parsed");
      } else {
        // Get the values of the Sensor Array
        array_calib_min = json.getJSONArray("array_calib_min");
        array_calib_max = json.getJSONArray("array_calib_max");
        array_values = json.getJSONArray("array_values");
        // Get the values of the accelerometer
        float xAccel = json.getFloat("xAccel");
        float yAccel = json.getFloat("yAccel");
        float zAccel = json.getFloat("zAccel");
        accel_x_raw_value = str(xAccel);
        accel_y_raw_value = str(yAccel);
        accel_z_raw_value = str(zAccel);
        // set the ellipse's coordinates to the trimmed striqngs
        accel_x_value = PApplet.parseInt(xAccel*accel_graph_multiplier);
        accel_y_value = PApplet.parseInt(yAccel*accel_graph_multiplier);
        accel_z_value = PApplet.parseInt(zAccel*accel_graph_multiplier);
        //Get the values of the Motor Driver
        PWMA = json.getInt("PWMA");
        AIN1 = json.getInt("AIN1");
        AIN2 = json.getInt("AIN2");
        PWMB = json.getInt("PWMB");
        BIN1 = json.getInt("BIN1");
        BIN2 = json.getInt("BIN2");
        STBY = json.getInt("STBY");
        // Get the values for the encoders
        encoder_left_count = json.getLong("encoder_left_count");
        encoder_right_count = json.getLong("encoder_right_count");
        rpm_encoder_left = json.getFloat("rpm_encoder_left");
        rpm_encoder_right = json.getFloat("rpm_encoder_right");
        encoder_elapsed_time = json.getInt("encoder_elapsed_time");
        rpm_wheel_left = json.getFloat("rpm_wheel_left");
        rpm_wheel_right = json.getFloat("rpm_wheel_right");
        average_speed_m_s = json.getFloat("average_speed_m_s");
      }
    } else
    {
      println("Buffer is null");
    }
  }
  catch (Exception e) {
    println("Initialization exception");
  }
}

/**
Function that initializes the user interface
@param none
@return void
*/
public void setup() {
  // create window
  
  arial_bold = createFont("Arial Bold", 12);
  arial = createFont("Arial", 12);
  // create the buttons
  btn_serial_up = new Button("^", serial_x_pos+140, serial_y_pos+10, 40, 20);
  btn_serial_dn = new Button("v", serial_x_pos+140, serial_y_pos+50, 40, 20);
  btn_serial_connect = new Button("Connect", serial_x_pos+300, serial_y_pos+10, 100, 55);
  btn_serial_disconnect = new Button("Disconnect", serial_x_pos+190, serial_y_pos+45, 100, 25);
  btn_serial_list_refresh = new Button("Refresh", serial_x_pos+190, serial_y_pos+10, 100, 25);

  // get the list of serial ports on the computer
  serial_list = Serial.list()[serial_list_index];

  //println(Serial.list());
  //println(Serial.list().length);

  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;
}

/**
Main function to create the user interface
@param none
@return void
*/
public void draw()
{
  background(background_color);
  drawAccelerometerGraph();
  drawSpeedValuesGraph();
  drawSensorArrayGraph();
  drawMotorDriverGraph();
  btn_serial_up.Draw();
  btn_serial_dn.Draw();
  btn_serial_connect.Draw();
  btn_serial_disconnect.Draw();
  btn_serial_list_refresh.Draw();
  // draw the text box containing the selected serial port
  DrawTextBox("Select Port", serial_list, serial_x_pos+10, serial_y_pos+10, 120, 60);
  logicMotorDriver(1,AIN1,AIN2,PWMA,STBY);
  logicMotorDriver(2,BIN1,BIN2,PWMB,STBY);
}

public void mousePressed() {
  // up button clicked
  if (btn_serial_up.MouseIsOver()) {
    if (serial_list_index > 0) {
      // move one position up in the list of serial ports
      serial_list_index--;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // down button clicked
  if (btn_serial_dn.MouseIsOver()) {
    if (serial_list_index < (num_serial_ports - 1)) {
      // move one position down in the list of serial ports
      serial_list_index++;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // Connect button clicked
  if (btn_serial_connect.MouseIsOver()) {
    if (serial_port == null) {
      // connect to the selected serial port
      serial_port = new Serial(this, Serial.list()[serial_list_index], 9600);
    }
  }
  // Disconnect button clicked
  if (btn_serial_disconnect.MouseIsOver()) {
    if (serial_port != null) {
      // disconnect from the serial port
      serial_port.stop();
      serial_port = null;
    }
  }
  // Refresh button clicked
  if (btn_serial_list_refresh.MouseIsOver()) {
    // get the serial port list and length of the list
    serial_list = Serial.list()[serial_list_index];
    num_serial_ports = Serial.list().length;
  }
}

// function for drawing a text box with title and contents
public void DrawTextBox(String title, String str, int x, int y, int w, int h)
{
  fill(255);
  rect(x, y, w, h);
  fill(0);
  textAlign(LEFT);
  textSize(14);
  text(title, x + 10, y + 10, w - 20, 20);
  textSize(12);
  text(str, x + 10, y + 40, w - 20, h - 10);
}

// button class used for all buttons
class Button {
  String label;
  float x;    // top left corner x position
  float y;    // top left corner y position
  float w;    // width of button
  float h;    // height of button

  // constructor
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }

  // draw the button in the window
  public void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }

  // returns true if the mouse cursor is over the button
  public boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}
  public void settings() {  size(1280, 720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "velociruabtor_v2_ui" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
