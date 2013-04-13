/*
 Attached an Serial7Segment to an Arduino Uno using the following pins:
 A5 to SCL
 A4 to SDA
 VIN to PWR
 GND to GND
*/

#include <Wire.h>

#define DISPLAY_ADDRESS1 0x71 //This is the default address of the OpenSegment with both solder jumpers open

int weight = 0;

void setup() {
  Wire.begin();

  Serial.begin(9600);

  //Send the reset command to the display - this forces the cursor to return to the beginning of the display
  Wire.beginTransmission(DISPLAY_ADDRESS1);
  Wire.write('v');
  Wire.endTransmission();

  setBrightness();
}

void loop() {
  if (Serial.available()) { // If data is available to read,
    weight = Serial.read();    
  }


 // Print the decimal at the proper spot
  //if (weight < 100)
  setDecimalsI2C(0b00000100);  // Sets digit 3 decimal on
  //else
  //  setDecimalsI2C(0b00001000);

  // todo, change to display left to right.

  i2cSendValue(weight);
   
  delay(100);
}

void setBrightness() {
  Wire.beginTransmission(DISPLAY_ADDRESS1);
  Wire.write(0x7A); // Brightness control command
  Wire.write(50); // Set brightness level: 0% to 100%
  Wire.endTransmission();
  i2cSendString("boot");
  delay(2000);
}

/*
  Given a number, i2cSendValue chops up an integer into 
  four values and sends them out over I2C
*/
void i2cSendValue(int tempCycles) {
  Wire.beginTransmission(DISPLAY_ADDRESS1); // transmit to device #1

  Wire.write(tempCycles / 1000); //Send the left most digit
  tempCycles %= 1000; //Now remove the left most digit from the number we want to display  
  Wire.write(tempCycles / 100);
  tempCycles %= 100;
  Wire.write(tempCycles / 10);
  tempCycles %= 10;
  Wire.write(tempCycles); //Send the right most digit
  Wire.endTransmission(); //Stop I2C transmission
}

//Given a string, i2cSendString chops up the string and sends out the first four characters over i2c
void i2cSendString(char *toSend) {
  Wire.beginTransmission(DISPLAY_ADDRESS1); // transmit to device #1
  for(byte x = 0 ; x < 4 ; x++)
    Wire.write(toSend[x]); //Send a character from the array out over I2C
  Wire.endTransmission(); //Stop I2C transmission
}

// This custom function works somewhat like a serial.print.
//  You can send it an array of chars (string) and it'll print
//  the first 4 characters in the array.
void sendStringI2C(String toSend) {
  Wire.beginTransmission(DISPLAY_ADDRESS1);
  for (int i=0; i<4; i++) {
    Wire.write(toSend[i]);
  }
  Wire.endTransmission();
}

// Turn on any, none, or all of the decimals.
//  The six lowest bits in the decimals parameter sets a decimal 
//  (or colon, or apostrophe) on or off. A 1 indicates on, 0 off.
//  [MSB] (X)(X)(Apos)(Colon)(Digit 4)(Digit 3)(Digit2)(Digit1)
void setDecimalsI2C(byte decimals) {
  // 0b00001000
  // 
  Wire.beginTransmission(DISPLAY_ADDRESS1);
  Wire.write(0x77);
  Wire.write(decimals);
  Wire.endTransmission();
}



