import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;


Serial port;                                                                     // Data received from the serial port      
int buffer = 0;                                                                  // Load the buffer 
float volume = 0.0;                                                              // Creating volume var 0.0 as starting point
float maxGain = 10;                                                              // Setting a Maximum on volume
float minGain = -100;                                                            // Setting a Minimum on volume
int BPM = 0;                                                                     // Creating BPM var 0 as starting point
float maxBPM = 180;                                                              // Setting a Maximun on BPM rate
float audioSampleBPM = 100;                                                      // Setting the standard samplerate to 100 BPM

Minim minim;                                                                     // Using the Minim libarary          
TickRate rateControl;                                                            // ?
Gain volumeControl;                                                              // ?
FilePlayer muziekje;                                                             // ?
AudioOutput out;                                                                 // ?

void setup() {

  printArray(Serial.list());                                                     // List all the available serial ports
  rectMode(CENTER);                                                             
  ellipseMode(CENTER);
  size(500, 500);
  String arduinoPort = Serial.list()[2];                                         // Receive the buffer from arduino 
  port = new Serial(this, arduinoPort, 9600);                                    // Via port > arduinoPort with baudrate 9600
  minim = new Minim(this);                                                       // ?
  muziekje = new FilePlayer( minim.loadFileStream("Regal - Anhedonia.mp3") ); // Import the choosen .mp3 file to use in the code
  muziekje.loop();                                                               // Function to start en loop the .mp3 file
  rateControl = new TickRate(1.f);                                               // ?
  rateControl.setInterpolation( true );                                          // ?
  volumeControl = new Gain(0.f);                                                 //
  out = minim.getLineOut();                                                      //
  muziekje.patch(rateControl).patch(volumeControl).patch(out);                                     //
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
  println("volume :", volume , "dB; BPM:", BPM);                                 // Print Volume dB and BPM in combination with the values
}

void sampleSetting(float volume, float BPM) {                                    // Creating function for adjusting volume and BPM.  
  rateControl.value.setLastValue(BPM/audioSampleBPM);                            // ?
  volumeControl.setValue(volume);                                                // ?
}

void drawVisualisation () {                                                      // Function declaration for the visualisationSetting
  float volumeHeight = map(volume, minGain, maxGain, 450, 50);                   // Convert the Volume value and map it
  float BPMHeight = map(BPM, 0, maxBPM, 450, 50);                                // Convert the BPM and map it
  ellipse(100, volumeHeight, 101, 101);                                          // Draw ellipse and adjus it vertically by volumeHeight
  rect(250, BPMHeight, 101, 101);                                                // Draw rectangle and adjus it vertically by BPMHeight
}

void draw() {
    background(0);

  if (updateInput()) {                                                           // If there is new data available adjust the sampleSetting or visualisationSetting
    sampleSetting(volume, BPM);                                                  // Function for the sampleSetting
  }
  drawVisualisation();                                                           // Draw the visualisation
}
