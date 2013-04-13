import processing.serial.*;
import org.json.*;

// TODO: Json serialization of composed messages.

Serial serial;
PFont font;
int resolution = 25;
int rows;
int cols;
Evaluator evaluator;
int read;
boolean ctrlPressed = false;
boolean debug = false;

void setup() {
  size(480, 400);

  try {
    String portName = Serial.list()[4];
    println(portName);
    println(Serial.list());  
    serial = new Serial(this, portName, 9600);
  } catch (Exception e) {
    println("Failed to init serial. Check serial port.");
    println(Serial.list());
  }

  rows = 15;
  cols = 8;

  //println(PFont.list());
  // A no serif font will prob be better.
  font = createFont("Serif", 20);
  textFont(font);
  reset();

  // Background when fullscreen.
  frame.setBackground(new java.awt.Color(0, 0, 0));
  //noLoop();

}

void reset() {  
  evaluator = new Evaluator(rows * cols);
}

void draw() {
  background(0);

  if (debug) {
    displayScoreChart();
    displayWeight();
  }
  //displayText();
  displayLargeText(2.5);
}

void displayLargeText(float scale) {
  pushMatrix();  
  translate(50, 50);
  textAlign(LEFT, TOP);
  fill(255);
  textSize(15 * scale);
  text(evaluator.getText()
    + (frameCount / 20 % 2 == 0 ? "|" : "")
    , 10, 10, 400, 400);

  /*
  float w = textWidth(evaluator.getText());
  //Font font = getFont();
  FontMetrics metrics = getGraphics().getFontMetrics(font);
  float h = metrics.getHeight();  
  rect(0, 0, w, h);
  */

  popMatrix();
}

void displayText() {
  pushMatrix();
  translate(50, cols * resolution + 50);
  textSize(15);
  fill(255);

// text(typedText+(frameCount/10 % 2 == 0 ? "_" : ""), 35, 45);

  text(evaluator.getText()
    + (frameCount % 2 == 0 ? "_" : ""), 10, 10, cols * resolution, 100);
  popMatrix();
}

void displayWeight() {
  
  int weight = evaluator.calculateWeight();

  pushMatrix();
  translate(60, 370);
  textSize(15);
  fill(145);
  text(weight, 0, 0);
  popMatrix();
}

void displayScoreChart() {
  pushMatrix();
  translate(50, 50);
  char[] charArr = evaluator.getText().toCharArray();
  int i = 0;
  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      String c = "";
      if (charArr.length > i) {
        c = String.valueOf(charArr[i]);
      }

      History h = evaluator.getHistory(i);      

      noStroke();
      fill(0, 0, 0);
      fill(map(h.score, 0, 2000, 0, 255));
      if (c.equals(" ")) {
        fill(150, 50, 150, map(h.score, 0, 2000, 0, 255));
      }
      rect((x * resolution), (y * resolution), resolution, resolution);
      fill(255);
      //text(c, x * resolution, y * resolution + resolution);  
      i++;
    }
  }
  popMatrix();
}

void mousePressed() {
  if (mouseEvent.getClickCount() == 2) {
    exit();
  }
}

void keyPressed() {
  // Disable escape key;
  if (key == ESC) key = '¢';
  if (key == TAB || key == ENTER) {
    storeMessage();
    reset();
    if (serial != null) {
      try {
        serial.write(0);
      } catch (Exception e) {
        println("Failed to write to serial during reset.");
      }
    }
    return;
  }
  if (keyCode == CONTROL) {
    ctrlPressed = true;
    return;
  }
  if (ctrlPressed) {
    if (key == 'd') {
      debug = !debug;
      println("DEBUG " + debug);
    }
    ctrlPressed = false;
    return;
  }
  if (key == '¢') return;

  evaluator.process(key);

  int weight = evaluator.calculateWeight();
  println("weight " + weight);
  if (serial != null) {
    try {
      serial.write(weight);
    } catch (Exception e) {
      println("Failed to write to serial while updating weight.");
    }
  }
}

void storeMessage() {
  PrintWriter output;
  output = createWriter("export/message" + millis()+ ".txt");
  output.println(evaluator.toJson());
  output.println(evaluator.toHistoryJson());
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}



