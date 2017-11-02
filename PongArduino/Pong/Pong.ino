const int buttonPin1 = 8;
const int buttonPin2 = 9;     
const int LDRPin = 5;
const int buttonPin3 = 11; 
const int buttonPin4 = 12; 
const int buttonPin5 = 13; 


int button1State = 0;
int button2State = 0;
int button3State = 0;
int button4State = 0;
int button5State = 0;

int LDRValue = 0;

int wait = 0;
int count_light = 0;
int count_dark = 0;

void setup() {
  Serial.begin(9600);
  pinMode(buttonPin1, INPUT_PULLUP);   
  pinMode(buttonPin2, INPUT_PULLUP);   
  pinMode(buttonPin3, INPUT_PULLUP); 
  pinMode(buttonPin4, INPUT_PULLUP); 
  pinMode(buttonPin5, INPUT_PULLUP); 
}

void loop(){
  button1State = digitalRead(buttonPin1);
  button2State = digitalRead(buttonPin2);
  button3State = digitalRead(buttonPin3);
  button4State = digitalRead(buttonPin4);
  button5State = digitalRead(buttonPin5);
  LDRValue = analogRead(LDRPin);

//  Serial.println(LDRValue);
//  
  // Wait for the Light sensor.
  if(wait < 50){
    if(LDRValue < 525){
      // Light Mode
      count_light = count_light + 1;
    } else {
       count_dark = count_dark + 1;
    }
  } else if(wait > 50){
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
    } else {
      Serial.write(0);
    }
  } else {
    if(count_light > count_dark){
      // Light Mode
      Serial.write(6);
    } else {
      // Dark mode
      Serial.write(7); 
    }
  }
  
  // Wait for 0.5 seconds
  wait = wait + 1;
 delay(100);

}
