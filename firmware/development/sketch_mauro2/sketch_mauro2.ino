// Adicionar biblioteca para controlo do motor de passo com o driver:
// https://github.com/laurb9/StepperDriver
#include "A4988.h"

#include <Arduino.h>

#define MOTOR_STEPS 200

// Definir pinos conetados
#define DIR  8
#define STEP 9
#define MS1  10
#define MS2  11
#define MS3  12

A4988 stepper(MOTOR_STEPS, DIR, STEP, MS1, MS2, MS3);

const int BUFFER_SIZE = 10;
char buf[BUFFER_SIZE];

void setup()
{
  stepper.begin(1, 1);
  Serial.begin(115200);
  delay(1000);
  Serial.setTimeout(1000);    // Timeout = um segundo
  if (Serial.available() > 0) // Limpa buffer
  {
    Serial.read();
  }
}

void loop()
{
  // Lê a mensagem proveniente do MATLAB
  if (Serial.available() > 0)
  {
    int rlen = Serial.readBytesUntil('\n', buf, BUFFER_SIZE);
    int val = atoi(buf);
    switch (val) {
      case 1:
        execute_motor_step();
        send_sensor_value(read_sensor());
        break;
      default:
        Serial.println(val);
        break;
    }
  }
}

void execute_motor_step()
{
  // Roda um passo - adicionar diferentes metodologias no futuro
  // stepper.move(1);
}

unsigned read_sensor()
{
  // Escrever código para ler o sensor
  return 20;
}

void send_sensor_value(unsigned sensor_value)
{
  // Enviar o valor do sensor para o MATLAB
  Serial.println(sensor_value);
}
