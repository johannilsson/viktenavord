/*
The Weight of Words

https://github.com/johannilsson/viktenavord
Johan Nilsson johan@markupartist.com


Serial 7-Segment Display from Sparkfun

   Circuit:
   Arduino -------------- Serial 7-Segment
     5V   --------------------  VCC
     GND  --------------------  GND
      8   --------------------  SS
     11   --------------------  SDI
     13   --------------------  SCK
     

Based on Jim Lindbloms spi example;
https://www.sparkfun.com/tutorials/407

*/
#include <SPI.h> // Include the Arduino SPI library

const int ssPin = 8;
unsigned int weight = 0;

char tempString[10];  // Will be used with sprintf to create strings

void setup() {
  Serial.begin(9600);

  pinMode(ssPin, OUTPUT);
  digitalWrite(ssPin, HIGH);
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV64);  // Slow down SPI clock

  clearDisplaySPI(); // Clear and reset.

  setString("boot");
  delay(500);
  //setDecimalsSPI(0b111111);  // Turn on all decimals, colon, apos
  //delay(500);
  //setDecimalsSPI(0b00000010);  // Sets digit 3 decimal on
  //setBrightnessSPI(0);  // Lowest brightness
  setBrightnessSPI(255);  // High brightness

  clearDisplaySPI();  
}

void loop() {
  clearDisplaySPI();

  if (Serial.available()) {
    weight = Serial.read();    
  }

  //sprintf(tempString, "%4d", weight);
  setInt(weight);
  
  delay(100);  // This will make the display update at 100Hz.*/
}

// This custom function works somewhat like a serial.print.
//  You can send it an array of chars (string) and it'll print
//  the first 4 characters in the array.
void setString(String toSend) {
  digitalWrite(ssPin, LOW);
  for (int i=0; i<4; i++) {
    SPI.transfer(toSend[i]);
  }
  digitalWrite(ssPin, HIGH);
}

void setInt(int tempCycles) {
  digitalWrite(ssPin, LOW);

  SPI.transfer(tempCycles / 1000);
  tempCycles %= 1000;
  SPI.transfer(tempCycles / 100);
  tempCycles %= 100;
  SPI.transfer(tempCycles / 10);
  tempCycles %= 10;
  SPI.transfer(tempCycles);

  digitalWrite(ssPin, HIGH);
}

// Send the clear display command (0x76)
//  This will clear the display and reset the cursor
void clearDisplaySPI() {
  digitalWrite(ssPin, LOW);
  SPI.transfer(0x76);  // Clear display command
  digitalWrite(ssPin, HIGH);
}

// Set the displays brightness. Should receive byte with the value
//  to set the brightness to
//  dimmest------------->brightest
//     0--------127--------255
void setBrightnessSPI(byte value) {
  digitalWrite(ssPin, LOW);
  SPI.transfer(0x7A);  // Set brightness command byte
  SPI.transfer(value);  // brightness data byte
  digitalWrite(ssPin, HIGH);
}

// Turn on any, none, or all of the decimals.
//  The six lowest bits in the decimals parameter sets a decimal 
//  (or colon, or apostrophe) on or off. A 1 indicates on, 0 off.
//  [MSB] (X)(X)(Apos)(Colon)(Digit 4)(Digit 3)(Digit2)(Digit1)
void setDecimalsSPI(byte decimals) {
  digitalWrite(ssPin, LOW);
  SPI.transfer(0x77);
  SPI.transfer(decimals);
  digitalWrite(ssPin, HIGH);
}


