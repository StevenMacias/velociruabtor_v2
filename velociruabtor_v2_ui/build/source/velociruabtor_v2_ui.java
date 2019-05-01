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

    @author Steven Macías and Victor Escobedo
    @version 1.0 22/04/2019
*/


Serial port;

// Configuration constants
static final String COM_PORT  = "/dev/ttyACM0";
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

/**
    Draw the graph regarding accelerometer values.
    @param none
    @return void
*/
public void drawAccelerometerGraph()
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
public void serialEvent(Serial port){
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
        accel_x_raw_value = str(xAccel);
        accel_y_raw_value = str(yAccel);
        accel_z_raw_value = str(zAccel);
        // set the ellipse's coordinates to the trimmed striqngs
        accel_x_value = PApplet.parseInt(xAccel*accel_graph_multiplier);
        accel_y_value = PApplet.parseInt(yAccel*accel_graph_multiplier);
        accel_z_value = PApplet.parseInt(zAccel*accel_graph_multiplier);
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
public void setup(){
  // create window
  
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
public void draw()
{
  background(background_color);
  drawAccelerometerGraph();
  drawSensorArrayGraph();
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