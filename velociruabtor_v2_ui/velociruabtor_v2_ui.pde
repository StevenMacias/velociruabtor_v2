/*
  Sample code to receive serial data from an Arduino hooked up to a 
  Memsic 2125 accelerometer. 
  
*/

import processing.serial.*;
Serial port;

static final int text_size = 12;
PFont arial_bold;
PFont arial;

// Window constants
static final int window_x_size     = 1280;
static final int window_y_size     = 720;
static final int accel_grid_color  = 255;
static final int background_color  = 0;

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
int accel_x_value = 0;
int accel_y_value = 0;
int accel_z_value = 0;
String accel_x_raw_value = "0.00"; 
String accel_y_raw_value = "0.00";
String accel_z_raw_value = "0.00";
JSONArray array_calib_min;
JSONArray array_calib_max;
JSONArray array_values;

// index of the comma between values (when reading from Arduino)
int index = 0;

void setup(){
  // create window
  size(1280, 720);
  arial_bold = createFont("Arial Bold", 12);
  arial = createFont("Arial", 12);
  // begin serial connection  
  port = new Serial(this, "COM8", 115200);
  port.bufferUntil('\n');  
  delay(1000);    
}

void draw(){
  // draw the background 
  background(background_color);
  // draw the grid
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
  //text(accel_z_raw_value, (accel_graph_x_pos+25), (accel_graph_size+accel_graph_y_pos-0));
}

// called whenever we receive data from the arduino
void serialEvent(Serial port){
  try {
  // read the input
  String buffer = port.readStringUntil('\n');

  // if input is not null
  if(buffer != null){
     // find the index of the comma
    
    JSONObject json = parseJSONObject(buffer);
    
    if (json == null) {
      println("JSONObject could not be parsed");
    } else {
      array_calib_min = json.getJSONArray("array_calib_min");
      array_calib_max = json.getJSONArray("array_calib_max");
      array_values = json.getJSONArray("array_values");
      
      //println(array_calib_min);
      //println(array_calib_max);
      
      // get the coordinates from the original string
      float xAccel = json.getFloat("xAccel");
      float yAccel = json.getFloat("yAccel");
      float zAccel = json.getFloat("zAccel");
      
      // trim coordinate strings so we don't get errors
      accel_x_raw_value = str(xAccel);
      accel_y_raw_value = str(yAccel);
      accel_z_raw_value = str(zAccel);
      
      // set the ellipse's coordinates to the trimmed strings
      accel_x_value = int(float(accel_x_raw_value)*accel_graph_multiplier);
      accel_y_value = int(float(accel_y_raw_value)*accel_graph_multiplier);
      accel_z_value = int(float(accel_z_raw_value)*accel_graph_multiplier);
    }
  }else
  {
    println("Buffer is null");
  }
  } catch (Exception e) {
    println("Initialization exception");
//    decide what to do here
  }  
}
