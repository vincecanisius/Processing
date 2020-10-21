import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

//Minim minim;
//AudioPlayer muziekje;

//importeer audiosample

Serial port;        // Create object from Serial class             //HIER ZOU PORT EN PORT 1 GEINITIALISEERD MOET WORDEN?
// Data received from the serial port          //HIER ZOU IN FLOAT'S OF INT'S VAL EN VAL1 ONTVANGEN MOETEN WORDEN?
int buffer = 0;
float volume = 0.0;
float maxGain = 3;
float minGain = -40;
//max volume zetten!
int BPM = 0;
float maxBPM = 180;
float audioSampleBPM = 100;

Minim minim;
TickRate rateControl;
Gain volumeControl;
FilePlayer muziekje;
AudioOutput out;


void setup() {



  printArray(Serial.list());
  rectMode(CENTER);
  ellipseMode(CENTER);
  size(500, 500);
  String arduinoPort = Serial.list()[2];
  //String arduinoPort = Serial.list()[1];                                         
  port = new Serial(this, arduinoPort, 9600);
  minim = new Minim(this);
  //muziekje = minim.loadFile("Nescafe.mp3");
  //muziekje.amp(0.5);
  //muziekje.loop(); //using loop instead of play
  muziekje = new FilePlayer( minim.loadFileStream("Nescafe.mp3") );
  muziekje.loop();
  rateControl = new TickRate(1.f);
  rateControl.setInterpolation( true );
  volumeControl = new Gain(0.f);
  out = minim.getLineOut();
  muziekje.patch(rateControl);
  muziekje.patch(volumeControl).patch(out);
  
}

// READ
boolean updateInput() {  //is there new data availbale from Arduin? Yes or no.
  if (port.available() > 0) { // If data is available,  
    float val = port.read(); // read it and store it in val
    float val1 = port.read();
    interpretInput(val, val1);
    return true;
  } else {
    return false;
  }
}

void interpretInput(float potmeter, float potmeter1) {  //creating function for interpret new input from potmeters
  volume = map(potmeter, 0, 255, maxGain, minGain);               //translating orginal values of 0,255 to 0,100 in the way of 0% - 100%.
  BPM = int(map(potmeter1, 0, 255, maxBPM, 0));             //translating orginal values of 0,255 to 0,100 in the way of 0% - 100%.
  println("volume :", volume , "dB; BPM:", BPM);
}

void sampleSetting(float volume, float BPM) {  //creating function for adjusting volume and BPM.  
  rateControl.value.setLastValue(BPM/audioSampleBPM);
  volumeControl.setValue(volume);  
  //muziekje.setVolume(volume);
  //amp() en rate(); komen hier.
  //muziekje.amp(0.5);
  //muziekje.rate(0.5);
}

void drawVisualisation () {    //function for  visualisationSetting
  float volumeHeight = map(volume, minGain, maxGain, 450, 50);  // Convert the value
  float BPMHeight = map(BPM, 0, maxBPM, 450, 50); //
  ellipse(100, volumeHeight, 101, 101);   // draw visualisations
  rect(250, BPMHeight, 101, 101);
}



void draw() {
  background(0);

  if (updateInput()) {     //if there is new adata available adjust the sampleSetting or visualisationSetting.
    sampleSetting(volume, BPM); // functie voor sample setting
  }
  drawVisualisation();
}
