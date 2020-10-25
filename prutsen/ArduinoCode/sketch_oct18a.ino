int sensorPin = 14;                                                               // Select input pin
int sensorPin1 = 15;                                                              // Select input pin
int val = 0;                                                                      // declaring value 1
int val1 = 0;                                                                     // declaring value 2
byte buf[2];                                                                      // creating a buffer with 2 arrays
int minThreshold = 2                                                              // This is required because measement errors at low potentials 

void setup() {
  Serial.begin(9600);                                                             // Open serial port
}

void loop() {

  val = analogRead(sensorPin);                                                    // Read the first value from sensor
  val = map(val, minThreshold, 1023, 0, 255);
  buf[0] = (byte)val;

  val1 = analogRead(sensorPin1);                                                  // Read the second value from sensor
  val1 = map(val1, minThreshold, 1023, 0, 255);
  buf[1] = (byte)val1;

  Serial.write(buf, 2);                                                           // Creating a hub for de two arrays before writing it to Processing
  delay(100);                                                                     // Wait 100 milliseconds


} 
