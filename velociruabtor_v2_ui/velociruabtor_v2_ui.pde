/**
    Velociruabtor V2 User Interface
    velociruabtor_v2_teensy.pde
    Purpose: Develop a user interface for the Velociruabtor v2

    @author Steven Macías and Victor Escobedo
    @version 1.0 22/04/2019
*/

import processing.serial.*;
Serial port;

// Configuration constants
static final String COM_PORT  = "/dev/pts/5";
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



/*BUTTON*/
float x = 500;
float y = 250;
float w = 150;
float h = 80;

/**
    Draw the graph regarding accelerometer values.
    @param none
    @return void
*/
void drawAccelerometerGraph()
{
  stroke(accel_grid_color);
  // Y Axis Line
  line((accel_graph_half_size+accel_graph_x_pos),(0+accel_graph_y_pos),(accel_graph_half_size+accel_graph_x_pos),(accel_graph_size+accel_graph_y_pos));
  // X Axis Line
  line((0+accel_graph_x_pos),(accel_graph_half_size+accel_graph_y_pos),(accel_graph_size+accel_graph_x_pos),(accel_graph_half_size+accel_graph_y_pos));
  // Z Axis Line
  line((accel_graph_size+accel_z_graph_x_pos),(0+accel_z_graph_y_pos),(accel_z_graph_x_pos+accel_graph_size),(accel_graph_size+accel_z_graph_y_pos));
  // draw the ellipse
  noStroke();
  fill(255,0,0);
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
  for(int i = 0; i<array_calib_min.size(); i++)
  {
    text(temp_array_values[i], (array_values_x_pos+(40*(i))), array_values_y_pos+20);
    fill(map(temp_array_values[i],0,1000,0,255));
    stroke(255);
    rect((array_values_x_pos+(40*(i))), (array_values_y_pos+35), 30, 5);
    fill(255);
  }
  
  stroke(accel_grid_color);
  // Motor L Line
  line((accel_graph_size+accel_z_graph_x_pos+array_values_x_pos),(0+accel_z_graph_y_pos),(accel_z_graph_x_pos+accel_graph_size+array_values_x_pos),(accel_graph_size+accel_z_graph_y_pos));
  // Motor L Ellipse
  noStroke();
  fill(255,0,0);
  ellipse((accel_graph_size+accel_z_graph_x_pos+array_values_x_pos), (temp_array_values[1]+accel_z_graph_y_pos+(accel_graph_half_size/2)), accel_graph_point_size, accel_graph_point_size);
  // draw the text
  fill(255);
  text("MOTOR L: ", (accel_graph_x_pos+10+array_values_x_pos), (accel_graph_size+accel_graph_y_pos-0));
  text(temp_array_values[1], (accel_graph_x_pos+25+array_values_x_pos), (accel_graph_size+accel_graph_y_pos-0));
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
  for(int i = 0; i<array_calib_min.size(); i++)
  {
    text(temp_min_values[i], (calib_values_x_pos+(40*(i+1))), calib_values_y_pos+20);
    text(temp_max_values[i], (calib_values_x_pos+(40*(i+1))), calib_values_y_pos+40);
    text(temp_array_values[i], (array_values_x_pos+(40*(i))), array_values_y_pos+20);
    fill(map(temp_array_values[i],0,1000,0,255));
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
void serialEvent(Serial port){
  try {
    String buffer = port.readStringUntil('\n');
    if(buffer != null){
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
        // set the ellipse's coordinates to the trimmed strings
        accel_x_value = int(xAccel*accel_graph_multiplier);
        accel_y_value = int(yAccel*accel_graph_multiplier);
        accel_z_value = int(zAccel*accel_graph_multiplier);
      }
    }else
    {
      println("Buffer is null");
    }
  } catch (Exception e) {
    println("Initialization exception");
  }
}

/**
    Function that initializes the user interface
    @param none
    @return void
*/
void setup(){
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
  circle(x, y, w);
  if(mousePressed){
    if(mouseX>x && mouseX <x+w && mouseY>y && mouseY <y+h){
     println("Steven esto parece que funciona ninio");
     fill(0);
     //do stuff 
    }
  }
}
