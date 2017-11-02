import processing.serial.*;

Serial myPort;
int val;

// Screen size
int screen_width = 700;
int screen_height = 700;

//Start Location
float x = 350;
float y = 350;

// Speed
float xspeed = random(3, 8);
float yspeed = random(3, 8);

// Size of pad
float pad_width = 10;
float pad_height = 100;

// Size of ball
float ball_size = 16;

float pad_speed = 2.5;

// Location of the first pad (Player) at start
float player1_x = 30;
float player1_y = 30;

// Locatopn of the second pad (AI) at start
float player2_x = screen_width - player1_x * 2;
float player2_y = 30;

int wait = 0;

Ball ball;
PlayerPad player1;
AIPad player2;

ColorMode lightMode = new ColorMode(#2c3e50, #ecf0f1, #1abc9c);
ColorMode darkMode = new ColorMode(#ecf0f1, #2c3e50, #1abc9c);

ColorMode mainColor;

void setup() {
  player1 = new PlayerPad(player1_x, player1_y, pad_speed, pad_width, pad_height);
  player2 = new AIPad(player2_x, player2_y, 1, pad_width, pad_height);

  ball = new Ball(x, y, xspeed, yspeed, ball_size, player1);

  String portName = "/dev/cu.usbmodem14511";
  myPort = new Serial(this, portName, 9600);

  size(700, 700);
  background(100);

}

void draw() {



  // println(val);
  if (myPort.available() > 0){
    val = myPort.read();
  }


  //At the start: find the light value for 0.5 second.
  if (wait < 500) {
    background(#8e44ad);
    textSize(72);
    text("Waiting for the light value", 30, 100); 
    if (val == 6 || val == 7) {
      wait = 500;
      // the light mode signal is 6.
      if(val == 6){
        mainColor = lightMode;
      // the dark mode signal is 7.
      } else if(val == 7){
        mainColor = darkMode;
      }
    }
    println(val);
    
  // Just for safety. 
  } else if(wait > 550){
    background(mainColor.background_color);
    // One step ---------------------------------------------
    ball.move();

    if (ball.checkHitHorizontal(width)){
      // If hit the side, then reset
      ball.fromPad.score = ball.fromPad.score - 1;

      // Reset.
      ball.x = x;
      ball.y = y;

      xspeed = random(3, 8);
      yspeed = random(3, 8);

      ball.bounce_x();
    }

    if(ball.checkHitVerticle(height)){
      ball.bounce_y();
    }

    player2.move(ball);

    // Just for controller...........

    if(val == 1){
      player1.moveUp(height);
    } else if (val == 2){
      player1.moveDown(height);
    }

    // check Collision
    if(ball.isHitPad(player2)){
      ball.bounce_x();
      ball.x = ball.x; // move the ball backward so that it won't stick to the pad
    }

    if(ball.isHitPad(player1)){
      ball.bounce_x();
      ball.x = ball.x; // move the ball forward so that it won't stick to the pad
    }

    // One step ---------------------------------------------

    stroke(0);
    fill(mainColor.ball_color);
    // Draw a ball
    ellipse(ball.x,ball.y,ball_size,ball_size);

    fill(mainColor.pad_color);
    // Draw a player_1
    rect(player1.x, player1.y, pad_width, pad_height);

    // Draw a player_2
    rect(player2.x, player2.y, pad_width, pad_height);
  }

  wait = wait + 1;
  delay(10);
}