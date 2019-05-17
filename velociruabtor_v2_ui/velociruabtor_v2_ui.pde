/**
 Velociruabtor V2 User Interface
 velociruabtor_v2_teensy.pde
 Purpose: Develop a user interface for the Velociruabtor v2
 
 @author Steven Macías and Víctor Escobedo
 @version 1.0 22/04/2019
 */

import processing.serial.*;
Serial port;

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
static final boolean DEBUG_ON            = false;

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




// variables for the coordinates
int accel_x_value         = 0;
int accel_y_value         = 0;
int accel_z_value         = 0;
String accel_x_raw_value  = "0.00";
String accel_y_raw_value  = "0.00";
String accel_z_raw_value  = "0.00";
JSONArray array_calib_min;
JSONArray array_calib_max;
JSONArray array_values;


void PRINT(String s)
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
void drawAccelerometerGraph()
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


void drawMotorDriverGraph()
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


void logicMotorDriver(int motor,int IN1, int IN2, int PWM, int STBY)
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
void drawSensorArrayGraph()
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
 Function that is called everytime a JSON string arrives through the UART
 @param none
 @return void
 */
void serialEvent(Serial port) {
  try {
    String buffer = port.readStringUntil('\n');
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
        accel_x_value = int(xAccel*accel_graph_multiplier);
        accel_y_value = int(yAccel*accel_graph_multiplier);
        accel_z_value = int(zAccel*accel_graph_multiplier);
        //Get the values of the Motor Driver
        PWMA = json.getInt("PWMA");
        AIN1 = json.getInt("AIN1");
        AIN2 = json.getInt("AIN2");
        PWMB = json.getInt("PWMB");
        BIN1 = json.getInt("BIN1");
        BIN2 = json.getInt("BIN2");
        STBY = json.getInt("STBY");
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
void setup() {
  // create window
  size(1280, 720);
  arial_bold = createFont("Arial Bold", 12);
  arial = createFont("Arial", 12);
  // begin serial connection
  port = new Serial(this, COM_PORT, COM_BAUDRATE);
  port.bufferUntil('\n');
  delay(1000);
}

/**
 Main function to create the user interface
 @param none
 @return void
 */
void draw()
{
  background(background_color);
  drawAccelerometerGraph();
  drawSensorArrayGraph();
  drawMotorDriverGraph();
  //circle(x, y, w);
  //if(mousePressed){
  //  if(mouseX>x && mouseX <x+w && mouseY>y && mouseY <y+h){
  //   println("Steven esto parece que funciona ninio");
  //   fill(0);
  //   //do stuff 
  //  }
  //}
  logicMotorDriver(1,AIN1,AIN2,PWMA,STBY);
  logicMotorDriver(2,BIN1,BIN2,PWMB,STBY);
}
