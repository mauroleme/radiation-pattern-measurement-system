/*
 * File     : commissioning.ino
 * Author   : Mauro Leme
 * Date     : October 10, 2026
 * Purpose  : Stand-alone test firmware for commissioning the positioner.
 *            It does NOT replace firmware/main: flash it, run the MATLAB
 *            tests in matlab/commissioning, then flash firmware/main again.
 *
 *            Unlike the measurement firmware, it reports what the hardware
 *            is doing (Hall sensors, step counters, raw ADC), so the tests
 *            can check the motion and calibrate the system.
 *
 *            Pins, step timing, direction convention and Hall polarity are
 *            the same as in firmware/main (main.ino + joint.cpp).
 *
 * License  : MIT License (see LICENSE)
 *
 * Serial protocol (115200 baud, one command per line, replies end in CR/LF)
 *   PING                     -> PONG
 *   INFO                     -> INFO,<version>,<delta_t_us>
 *   HALL                     -> HALL,<j1>,<j2>          (1 = magnet seen)
 *   HALLA                    -> HALLA,<adc_j1>,<adc_j2> (analog value, 0-1023)
 *   EN,<j>,<0|1>             -> OK                      (motor driver off/on)
 *   ZERO,<j>                 -> OK                      (step counter = 0)
 *   POS                      -> POS,<steps_j1>,<steps_j2>
 *   DT,<us>                  -> OK                      (half step period)
 *   STEP,<j>,<n>             -> OK,<pos>                (n signed usteps)
 *   SCAN,<j>,<n>,<every>     -> E,<pos>,<state> on every Hall change,
 *                               A,<pos>,<adc> every <every> steps (0 = off),
 *                               then DONE,<pos>
 *   RAW,<n>                  -> n comma-separated analogRead(A3) values
 *   Errors                   -> ERR,<message>
 */

#include <Arduino.h>

#define FW_VERSION  "commissioning-1.0"

// ---- Pins (identical to firmware/main/main.ino) ---------------------------
const uint8_t STEP_PIN[3] = { 0, 6, 5 };
const uint8_t DIR_PIN[3]  = { 0, 7, 4 };
const uint8_t EN_PIN[3]   = { 0, 8, 12 };
const uint8_t HALL_PIN[3] = { 0, A0, A1 };
const uint8_t RF_PIN      = A3;

// ---- State -------------------------------------------------------------------
uint16_t delta_t = 5000;           // us, same as DELTA_T in joint.h
long     pos[3]  = { 0, 0, 0 };    // micro-step counters
char     line[48];

// ---- Low-level helpers --------------------------------------------------------
bool hall(uint8_t j)
{
    // Same as Joint::ReadHall(): input with pull-up, magnet pulls it LOW
    return digitalRead(HALL_PIN[j]) == LOW;
}

int hallAnalog(uint8_t j)
{
    return analogRead(HALL_PIN[j]);
}

void enable(uint8_t j, bool on)
{
    digitalWrite(EN_PIN[j], on ? LOW : HIGH);   // DRV8825 EN is active low
}

void stepOnce(uint8_t j, int dir)
{
    // Positive = default direction of the Joint class (DIR pin HIGH)
    digitalWrite(DIR_PIN[j], dir > 0 ? HIGH : LOW);
    digitalWrite(STEP_PIN[j], LOW);
    delayMicroseconds(delta_t);
    digitalWrite(STEP_PIN[j], HIGH);
    delayMicroseconds(delta_t);
    pos[j] += dir;
}

bool validJoint(int j)
{
    if (j == 1 || j == 2) return true;
    Serial.println(F("ERR,joint must be 1 or 2"));
    return false;
}

// ---- Commands ---------------------------------------------------------------------
void cmdScan(int j, long n, long every)
{
    int  dir  = (n >= 0) ? 1 : -1;
    long todo = labs(n);
    bool last = hall(j);
    enable(j, true);
    Serial.print(F("E,")); Serial.print(pos[j]); Serial.print(','); Serial.println(last);
    for (long i = 1; i <= todo; i++)
    {
        stepOnce(j, dir);
        bool now = hall(j);
        if (now != last)
        {
            Serial.print(F("E,")); Serial.print(pos[j]); Serial.print(','); Serial.println(now);
            last = now;
        }
        if (every > 0 && i % every == 0)
        {
            Serial.print(F("A,")); Serial.print(pos[j]); Serial.print(','); Serial.println(hallAnalog(j));
        }
    }
    Serial.print(F("DONE,")); Serial.println(pos[j]);
}

void handle(char *cmd)
{
    long a = 0, b = 0, c = 0;

    if (strcmp(cmd, "PING") == 0)
    {
        Serial.println(F("PONG"));
    }
    else if (strcmp(cmd, "INFO") == 0)
    {
        Serial.print(F("INFO," FW_VERSION ",")); Serial.println(delta_t);
    }
    else if (strcmp(cmd, "HALL") == 0)
    {
        Serial.print(F("HALL,")); Serial.print(hall(1)); Serial.print(','); Serial.println(hall(2));
    }
    else if (strcmp(cmd, "HALLA") == 0)
    {
        Serial.print(F("HALLA,")); Serial.print(hallAnalog(1)); Serial.print(','); Serial.println(hallAnalog(2));
    }
    else if (strcmp(cmd, "POS") == 0)
    {
        Serial.print(F("POS,")); Serial.print(pos[1]); Serial.print(','); Serial.println(pos[2]);
    }
    else if (sscanf(cmd, "EN,%ld,%ld", &a, &b) == 2)
    {
        if (validJoint(a)) { enable(a, b != 0); Serial.println(F("OK")); }
    }
    else if (sscanf(cmd, "ZERO,%ld", &a) == 1)
    {
        if (validJoint(a)) { pos[a] = 0; Serial.println(F("OK")); }
    }
    else if (sscanf(cmd, "DT,%ld", &a) == 1)
    {
        if (a < 200 || a > 20000) { Serial.println(F("ERR,DT out of range 200-20000")); return; }
        delta_t = (uint16_t)a;
        Serial.println(F("OK"));
    }
    else if (sscanf(cmd, "STEP,%ld,%ld", &a, &b) == 2)
    {
        if (!validJoint(a)) return;
        enable(a, true);
        int dir = (b >= 0) ? 1 : -1;
        for (long i = 0; i < labs(b); i++) stepOnce(a, dir);
        Serial.print(F("OK,")); Serial.println(pos[a]);
    }
    else if (sscanf(cmd, "SCAN,%ld,%ld,%ld", &a, &b, &c) == 3)
    {
        if (validJoint(a)) cmdScan(a, b, c);
    }
    else if (sscanf(cmd, "RAW,%ld", &a) == 1)
    {
        if (a < 1 || a > 200) { Serial.println(F("ERR,RAW n must be 1-200")); return; }
        for (long i = 0; i < a; i++)
        {
            Serial.print(analogRead(RF_PIN));
            if (i < a - 1) Serial.print(',');
            delay(1);
        }
        Serial.println();                       // CR/LF, as MATLAB expects
    }
    else
    {
        Serial.print(F("ERR,unknown command: ")); Serial.println(cmd);
    }
}

void setup()
{
    for (uint8_t j = 1; j <= 2; j++)
    {
        pinMode(STEP_PIN[j], OUTPUT);
        pinMode(DIR_PIN[j], OUTPUT);
        pinMode(EN_PIN[j], OUTPUT);
        pinMode(HALL_PIN[j], INPUT_PULLUP);
        enable(j, false);                       // drivers off until used
    }
    pinMode(RF_PIN, INPUT);
    Serial.begin(115200);
    while (!Serial);
    Serial.println(F("READY," FW_VERSION));
}

void loop()
{
    static uint8_t n = 0;
    while (Serial.available() > 0)
    {
        char ch = Serial.read();
        if (ch == '\r') continue;
        if (ch == '\n')
        {
            line[n] = '\0';
            if (n > 0) handle(line);
            n = 0;
        }
        else if (n < sizeof(line) - 1)
        {
            line[n++] = ch;
        }
    }
}
