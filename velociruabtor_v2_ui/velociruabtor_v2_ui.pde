/**
Velociruabtor V2 User Interface
velociruabtor_v2_teensy.pde
Purpose: Develop a user interface for the Velociruabtor v2

@author Steven Macías and Víctor Escobedo
@version 1.0 22/04/2019
*/
import controlP5.*;
ControlP5 cp5;
import processing.serial.*;
Serial serial_port = null;

// Configuration constants

static final String COM_PORT  = "COM4";
static final int COM_BAUDRATE = 38400;

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
static final int tunning_values_x_pos    = 100;
static final int tunning_values_y_pos    = 300;
static final boolean DEBUG_ON            = false;
static final int serial_x_pos       = 100;
static final int serial_y_pos       = 600;
public float numberBoxKp = 1.0;
public float numberBoxKd = 2.0;
public boolean calibrateSensorsFlag = false;
DropdownList d1;
JSONObject tx_json;
Textarea myTextarea;
Println console;
int baseSpeedValue = 100;
Knob baseSpeedKnob;

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

void PRINT(String s)
{
  if(DEBUG_ON)
  {
    println(s);
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
  fill(color(#54f367));
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
Draw graph regarding sensor array
@param none
@return void
*/
void drawSpeedValuesGraph()
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
void serialEvent(Serial serial_port) {
  try {
    String buffer = serial_port.readStringUntil('\n');
    if (buffer != null) {
      //println(buffer);
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
void setup() {
  // create window
  frameRate(24);
  size(1280, 720);
  smooth(4);
  arial_bold = createFont("Arial Bold", 12);
  arial = createFont("Arial", 12);
  tx_json = new JSONObject();

  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;

  cp5 = new ControlP5(this);

  cp5.addNumberbox("kp")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos)
  .setSize(110,25)
  .setRange(0,20)
  .setMultiplier(0.01) // set the sensitifity of the numberbox
  .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
  .setValue(numberBoxKp)
  .setColorBackground(color(#54f367))
  .setColorForeground(color(#02657d))
  .setColorValue(color(#000000))
  .setColorActive(color(#ec0808))
  .setColorCaptionLabel(color(#ffffff))
  ;

  cp5.addNumberbox("kd")
  .setPosition(tunning_values_x_pos+150,tunning_values_y_pos)
  .setSize(110,25)
  .setRange(0,20)
  .setMultiplier(0.01) // set the sensitifity of the numberbox
  .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
  .setValue(numberBoxKd)
  .setColorBackground(color(#54f367))
  .setColorForeground(color(#02657d))
  .setColorValue(color(#000000))
  .setColorActive(color(#ec0808))
  .setColorCaptionLabel(color(#ffffff))
  ;

  // create a DropdownList,
  d1 = cp5.addDropdownList("serialPortList")
  .setPosition(tunning_values_x_pos, tunning_values_y_pos+50)
  .setOpen(false)
  .setBackgroundColor(color(#216329))
  .setColorActive(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorCaptionLabel(color(#216329))
  .setColorForeground(color(#216329))
  .setColorLabel(color(#000000))
  .setColorValue(color(#216329))
  .setColorValueLabel(color(#000000))
  .setItemHeight(25)
  .setHeight(200)
  .setBarHeight(25)
  .setWidth(110);
  ;
  customize(d1);

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("connect")
  .setPosition(tunning_values_x_pos+150,tunning_values_y_pos+50)
  .setSize(50,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454))
  ;
  cp5.addToggle("enableMotors")
  .setPosition(tunning_values_x_pos+210,tunning_values_y_pos+50)
  .setSize(50,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454))
  ;

  cp5.addButton("transmitValues")
  .setPosition(tunning_values_x_pos+280,tunning_values_y_pos)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;

  cp5.addButton("refreshPorts")
  .setPosition(tunning_values_x_pos+280,tunning_values_y_pos+50)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;

  cp5.addButton("calibrateSensors")
  .setPosition(tunning_values_x_pos+400,tunning_values_y_pos+50)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;

  cp5.addButton("consoleClear")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+310)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;


  myTextarea = cp5.addTextarea("txt")
                  .setPosition(tunning_values_x_pos,tunning_values_y_pos+100)
                  .setSize(380, 200)
                  .setFont(createFont("", 10))
                  .setLineHeight(14)
                  .setColor(color(#54f367))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#216329));
  ;
  console = cp5.addConsole(myTextarea);//

  baseSpeedKnob = cp5.addKnob("baseSpeedValue")
               .setRange(0,255)
               .setValue(50)
               .setPosition(tunning_values_x_pos+400,tunning_values_y_pos+100)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(true)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#216329))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               ;
}

public void transmitValues(int theValue) {
  println("Transmit values: "+theValue);
  tx_json.setFloat("kp", numberBoxKp);
  tx_json.setFloat("kd", numberBoxKd);
  tx_json.setFloat("baseSpeed", baseSpeedValue);
  if(serial_port != null)
  {
    // Why is this so slow? 2.5 seconds.
    serial_port.write(tx_json.toString().replace("\n", "").replace("\r", ""));
    serial_port.write('\n');
    println("Sending JSON though the UART: "+tx_json.toString().replace("\n", "").replace("\r", ""));
  }
}

  public void refreshPorts(int theValue) {
    println("Refresh ports: "+theValue);
    customize(d1);
  }

  public void calibrateSensors(int theValue)
  {
    if((calibrateSensorsFlag == false))
    {
        println("Calibrate Sensors: "+theValue);
        calibrateSensorsFlag = true;

    }
  }

  public void consoleClear()
  {
    console.clear();
  }

  void connect(boolean theFlag) {
    boolean port_error = false;
    if(theFlag==true) {
      if (serial_port == null) {
        // connect to the selected serial port
        try{
          serial_port = new Serial(this, Serial.list()[serial_list_index], COM_BAUDRATE);
          serial_port.bufferUntil('\n');
        }
        catch (Exception e) {
          println(e);
          port_error = true;
        }
        if(port_error == false)
        {
          lockButtons();
        }else
        {
          unlockButtons();
          //put the switch in off position
          cp5.getController("connect").setValue(0);
        }

      }
    } else {
      if (serial_port != null) {
        // disconnect from the serial port
        serial_port.stop();
        serial_port = null;
        unlockButtons();
      }
    }
  }

  void lockButtons()
  {
    cp5.getController("connect").setColorActive(color(#54f367));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(true);
    cp5.getController("serialPortList").setColorBackground(color(#5c5c5c));
    cp5.getController("calibrateSensors").setColorBackground(color(#5c5c5c));
    println("Connect");
  }

  void unlockButtons()
  {
    cp5.getController("connect").setColorActive(color(#f35454));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(false);
    cp5.getController("serialPortList").setColorBackground(color(#54f367));
    cp5.getController("calibrateSensors").setColorBackground(color(#54f367));
    println("Disconnect");
  }

  void enableMotors(boolean theFlag) {
    if(theFlag==true) {
      cp5.getController("enableMotors").setColorActive(color(#54f367));
      cp5.getController("enableMotors").setColorBackground(color(#5c5c5c));
      tx_json.setInt("enable", 1);
      println("Enable motors: ON");
    } else {
      // disconnect from the serial port
      cp5.getController("enableMotors").setColorActive(color(#f35454));
      cp5.getController("enableMotors").setColorBackground(color(#5c5c5c));
      tx_json.setInt("enable", 0);
      println("Enable motors: OFF");
    }
    if(serial_port != null)
    {
      // Why is this so slow? 2.5 seconds.
      serial_port.write(tx_json.toString().replace("\n", "").replace("\r", ""));
      serial_port.write('\n');
      println("Sending JSON though the UART: "+tx_json.toString().replace("\n", "").replace("\r", ""));
    }
  }

  void controlEvent(ControlEvent theEvent) {
    // DropdownList is of type ControlGroup.
    // A controlEvent will be triggered from inside the ControlGroup class.
    // therefore you need to check the originator of the Event with
    // if (theEvent.isGroup())
    // to avoid an error message thrown by controlP5.

    if (theEvent.isGroup()) {
      // check if the Event was triggered from a ControlGroup
      println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    }
    else if (theEvent.isController()) {
      if (theEvent.isFrom(cp5.getController("serialPortList"))) {
        if (serial_port == null) {
          // connect to the selected serial port
          try{
            //serial_port = new Serial(this, Serial.list()[int(theEvent.getController().getValue())], 9600);
            serial_list_index = int(theEvent.getController().getValue());
            //serial_port.bufferUntil('\n');
          }
          catch (Exception e) {
            println(e);
          }
          println("Connect");
        }
      }else if(theEvent.isFrom(cp5.getController("baseSpeedValue")))
      {
        println("BaseSpeedValue Event");
        transmitValues(0);
        delay(50);
      }
    }
  }

  void customize(DropdownList ddl) {
    // a convenience function to customize a DropdownList
    ddl.clear();
    ddl.getCaptionLabel().set("Serial Ports");
    num_serial_ports = Serial.list().length;
    println("num_serial_ports: "+num_serial_ports);
    for (int i=0;i<num_serial_ports;i++) {
      //println(Serial.list()[i]);
      ddl.addItem(Serial.list()[i], i);
    }
  }

  void kp(float kp_value) {
    numberBoxKp = kp_value;
    println("kp_value:"+numberBoxKp);
  }

  void kd(float kd_value) {
    numberBoxKd = kd_value;
    println("kd_value:"+numberBoxKd);
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
    drawSpeedValuesGraph();
    drawSensorArrayGraph();
    drawMotorDriverGraph();

    logicMotorDriver(1,AIN1,AIN2,PWMA,STBY);
    logicMotorDriver(2,BIN1,BIN2,PWMB,STBY);

    if(calibrateSensorsFlag == true)
    {
      cp5.getController("calibrateSensors").setColorBackground(color(#f56302));
    }else{
      cp5.getController("calibrateSensors").setColorBackground(color(#54f367));
    }
  }
