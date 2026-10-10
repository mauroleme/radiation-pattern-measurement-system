/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  https://www.arduino.cc/en/Tutorial/BuiltInExamples/AnalogReadSerial
*/

int N=100;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(115200);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  
  // print out the value you read:
   float sensorValue=0.0;
   float P_dB=0.0;
  for (int i=0;i<N;i++)
  {
    sensorValue += (float)analogRead(A3); 
     
    delay(1);        // delay in between reads for stability
  }
  sensorValue=sensorValue/N;
  //P_dB=0.2758*sensorValue-97.817; // modelo com todas as amostras
  P_dB=0.2722*sensorValue-97.115;   // modelos sem saturação

  Serial.println((float)P_dB);

  //0.0177
  //1.732
  //3.6133x+354.36
  
  
}
