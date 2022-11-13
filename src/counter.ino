/*
 * output the time of AC 60Hz
 * -samy kamkar 2021/07/05
 */

#include "digitalWriteFast.h"

// interrupt pins on atmega328p 2+3
#define INT_PIN 2
#define OUT_PIN 4

#define BAUD 115200

bool toggle = 1;
volatile int changed = 0;
unsigned long micro = 0;
unsigned long first = 0;

void setup()
{
  pinModeFast(INT_PIN, INPUT);
  pinModeFast(OUT_PIN, OUTPUT);

  // XXX - why does RISING cause this to hit when lowering too?
  attachInterrupt(digitalPinToInterrupt(INT_PIN), isr, CHANGE);
  Serial.begin(BAUD);
}

void isr()
{
  changed = 1;
}

void pinFlip()
{
  Serial.println(micro);
  digitalWrite(OUT_PIN, toggle ^= 1);
}

void loop()
{
  // actual loop (main) has Serial checking so while 1
  while (1)
    check();
}

void check()
{
  micro = micros();

  if (changed)
  {
    changed = 0;
    // debounce
    if ((micro - first) > 4000)
    {
      // pin flipped, debounced
      pinFlip();
      first = micro;
    }
  }
}