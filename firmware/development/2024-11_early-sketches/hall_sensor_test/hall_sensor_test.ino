const int pinHall = A2; 

void setup() {
  pinMode(pinHall, INPUT);
  Serial.begin(9600);
} 

void loop() {
  //we measure 10 times and make the mean
  long measure = 0;
  for(int i = 0; i < 10; i++){
      measure += analogRead(pinHall);
  }
  measure /= 10;  
  
  //voltage in mV
  float outputV = measure * 5000.0 / 1023;
  Serial.println("Output Voltaje = " + String(outputV) + " mV");
  
  //flux density
  float magneticFlux = outputV * 53.33 - 133.3;
  Serial.println("Magnetic Flux Density = " + String(magneticFlux) + " mT");
  
  delay(2000);
}
