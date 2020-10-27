import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Serial port;                                                                     // Data received from the serial port      
float buffer = 0;                                                                // Load the buffer 
float volume = 0.0;                                                              // Creating volume var 0.0 as starting point
float maxGain = 2;                                                               // Setting a Maximum on volume
float minGain = -100;                                                            // Setting a Minimum on volume
float BPM = 0;                                                                   // Creating BPM var 0 as starting point
float maxBPM = 180;                                                              // Setting a Maximun on BPM rate
float audioSampleBPM = 100;                                                      // Setting the standard samplerate to 100 BPM
float xVolume = 100;                                                             // Creating X position of rotating volume bar 
float yVolume = 450;                                                             // Creating Y position of rotating volume bar
float xBPM = 650;                                                                // Creating X position of rotating BPM bar
float yBPM = 450;                                                                // Creating Y  position of rotating BPM bar
float rVolume = 0;                                                               // Creating rotation angle (degrees) of volume bar
float rBPM = 0;                                                                  // Creating rotation angle (degrees) of BPM bar
float maxRotationSpeed = 100;                                                    // Creating float max_rotation_speed with value 100

Minim minim;                                                                     // Using the Minim libarary          
TickRate rateControl;                                                            // Declaring controller for BPM from Minim ugens library
Gain volumeControl;                                                              // Declaring controller for volume from Minim ugens library
FilePlayer sample;                                                               // Declaring controller for audioplayer from Minim ugens library
AudioOutput out;                                                                 // Declaring controller for audio output from Minim ugens library

void setup() {

  printArray(Serial.list());                                                     // List all the available serial ports
  size(800, 900);
  String arduinoPort = Serial.list()[2];                                         // Receive the buffer from arduino 
  port = new Serial(this, arduinoPort, 9600);                                    // Via port > arduinoPort with baudrate 9600
  minim = new Minim(this);                                                       // Using Minim for the following line of code
  sample = new FilePlayer( minim.loadFileStream("Kasso - Walkman.mp3") );        // Import the desired .mp3 file to use in the code
  sample.loop();                                                                 // Function to start en loop the .mp3 file
  rateControl = new TickRate(1.f);                                               // Create BPM controller
  rateControl.setInterpolation( true );                                          // Through the interpolation the BPM control is smoother
  volumeControl = new Gain(0.f);                                                 // Create volume controller
  out = minim.getLineOut();                                                      // Create the audio output
  sample.patch(rateControl).patch(volumeControl).patch(out);                     // Combining all the aspects to create the patched sample
}

boolean updateInput() {                                                          // Checking if there is new data availbale from the Arduino
  if (port.available() > 0) {                                                    // If data is available,  
    float val = port.read();                                                     // Read it and store it in val
    float val1 = port.read();                                                    // Read it and store it in val1
    interpretInput(val, val1);                                                   // Interpret the different values 
    return true;                                                                 // Return true if that the case
  } else {                                                                       // OR
    return false;                                                                // If not; return false
  }
}

void interpretInput(float potmeter, float potmeter1) {                           // Creating function for interpret new input from potmeters
  volume = map(potmeter, 0, 255, maxGain, minGain);                              // Translating orginal values of 0,255 to 0,100 in the way of 0% - 100%.
  BPM = int(map(potmeter1, 0, 255, maxBPM, 0));                                  // Translating orginal values of 0,255 to 0,100 in the way of 0% - 100%.
  println("volume :", volume, "dB; BPM:", BPM);                                  // Print Volume dB and BPM in combination with the values
}

void sampleSetting(float volume, float BPM) {                                    // Creating function for adjusting volume and BPM.  
  rateControl.value.setLastValue(BPM/audioSampleBPM);                            // Starting at the original BPM level of the sample 
  volumeControl.setValue(volume);                                                // Boost the volume of the sample in decibel (can be negative)
}

void drawRotatingBars() {                                                        // Creating function for rotatings bars

  pushMatrix();                                                                  // Pushes the current transformation matrix onto the matrix stack
  translate(xVolume, yVolume);                                                   // Gives a new place on the screen according to X and Y
  rotate(radians(rVolume));                                                      // Degrees in PI
  fill(255);                                                                     // Color it white
  rect(-75, -5, 150, 10);                                                        // Draw a rectangle and flip it around itself
  popMatrix();                                                                   // Pops the current transformation matrix off the matrix stack

  rVolume = rVolume + map(volume, minGain, maxGain, 0, maxRotationSpeed);        // Increment rotation with amount as function of volume

  pushMatrix();                                                                  // Pushes the current transformation matrix onto the matrix stack
  translate(xBPM, yBPM);                                                         // Gives a new place on the screen according to Z and W
  rotate(radians(rBPM));                                                         // Degrees in PI
  fill(255);                                                                     // Color it white
  rect(-75, -5, 150, 10);                                                        // Draw a rectangle and flip it around itself
  popMatrix();                                                                   // Pops the current transformation matrix off the matrix stack

  rBPM = rBPM + map(BPM, 0, maxBPM, 0, maxRotationSpeed);                        // Increment rotation with amount as function of BPM
}

void drawCenterBars() {                                                          // Creating function for center bars

  for (int i = 0; i < 9; i = i + 1) {                                            // For loop function for the left LED red column  
    if (i > map(volume, minGain, maxGain, 8.0, -0.5)) {                          // Creating if statement to connect volume function to the left column
      fill(255 - 28 * i, 0, 0);                                                  // Adjusting brightness of colored volume rectangles
    } else {
      fill(0);
    }       
    rect(300, 0 + 100 * i, 100, 100);                                            // Drawing rectangle at the defined locations
  }

  for (int i = 0; i < 9; i = i + 1) {                                            // For loop function for the right LED blue column
    if (i > map(BPM, 0, maxBPM, 8.0, -0.5)) {                                    // Creating if statement to connect BPM function to the right column
      fill(0, 0, 255 - 28 * i);                                                  // Adjusting brightness of colored volume rectangles
    } else {
      fill(0);
    }       
    rect(400, 0 + 100 * i, 100, 100);                                            // Drawing rectangle at the defined locations
  }
}

void drawVisualisation() {                                                       // Function declaration for the visualisationSetting
  drawRotatingBars();
  drawCenterBars();
}

void draw() {
  background(0);

  if (updateInput()) {                                                           // If there is new data available adjust the sampleSetting or visualisationSetting
    sampleSetting(volume, BPM);                                                  // Function for the sampleSetting
  }
  drawVisualisation();                                                           // Draw the visualisation
}
