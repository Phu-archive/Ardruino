// Define all the buttons pin
const int buttonPin1 = 8;
const int buttonPin2 = 9;
const int buttonPin3 = 11;
const int buttonPin4 = 12;
const int buttonPin5 = 13;

// Initialize all the buttons states
int button1State = 0;
int button2State = 0;
int button3State = 0;
int button4State = 0;
int button5State = 0;

void setup() {
  Serial.begin(9600);

  // Define the pin modes.
  pinMode(buttonPin1, INPUT_PULLUP);
  pinMode(buttonPin2, INPUT_PULLUP);
  pinMode(buttonPin3, INPUT_PULLUP);
  pinMode(buttonPin4, INPUT_PULLUP);
  pinMode(buttonPin5, INPUT_PULLUP);
}

void loop(){
  // Read the pin value from arduino
  button1State = digitalRead(buttonPin1);
  button2State = digitalRead(buttonPin2);
  button3State = digitalRead(buttonPin3);
  button4State = digitalRead(buttonPin4);
  button5State = digitalRead(buttonPin5);

  // If the button x is high then write the number to the serial port
  // Else write zero.
  if (button1State == HIGH) {
    Serial.write(1);
  }
  else if(button2State == HIGH){
    Serial.write(2);
  }
  else if(button3State == HIGH){
        Serial.write(3);
  }
  else if(button4State == HIGH){
    Serial.write(4);
  }
  else if(button5State == HIGH){
    Serial.write(5);
  }
  else {
    Serial.write(0);
  }





  // Wait for 0.5 seconds
  delay(100);
}
