import processing.serial.*;
import httprocessing.*;

// Important Notes
// 1. The board location starts with one because it is easiler to draw.

// Define the variable that connect the arduino to processing
Serial myPort;
int val;

// Main Color theme of the game
ColorScheme color_scheme;

// 2 color theme that depends on light value.
ColorScheme lightMode = new ColorScheme(255, #2c3e50, #95a5a6, 0, color(231, 76, 60, 50));
ColorScheme darkMode = new ColorScheme(0, #95a5a6, #2c3e50, 255, color(231, 76, 60));

// Set up a counter for each button in order to stop button from pressing too much.
int[] button_counter = new int[5];

// Times when button can press again
// This depends on the delay time at the end, which mean the button can be press again
// After (8 * 10)/1000 = 0.1 seconds
int pressAgain = 10;

// The raw board contains number 0-2.
// This indicate the location of the stones
int[][] board = new int[9][9];

// For finding a group of stontes, which will be used for capturing stone.
Boolean[][] visited = new Boolean[9][9];

// Tracking all the placed stone, which will be used for capturing stone.
Boolean[][] boardVisited = new Boolean[9][9];

// The cursor location that starts with 1.
int cursor_x = 1;
int cursor_y = 1;

// Always start with darker player, which is one.
int current_player = 1;

// Track where player place the stone
// int current_player_x = 1;
// int current_player_y = 1;

// Use to clean all the array, this is used for seaching all the stones and flood fill.
void clean(Boolean[][] val){
  for(int i = 0; i < 9; i++){
    for (int j = 0; j < 9; j++) {
      val[i][j] = false;
    }
  }
}

// Starts with Set up.
void setup() {
  size(810,810);
  background(255);

  // Initialize the board, by filling it with 0 or empty space
  for(int i = 0; i < 9; i++){
    for (int j = 0; j < 9; j++) {
      board[i][j] = 0;
    }
  }

  // The button counter always with thigh highest mark.
  for (int i = 0; i < 5 ; i++) {
    button_counter[i] = pressAgain;
  }

  // Fill the array with false.
  clean(visited);
  clean(boardVisited);

  // Set up the port for reading values
  String portName = "/dev/cu.usbmodem14511";
  myPort = new Serial(this, portName, 9600);

  PostRequest post = new PostRequest("http://phuarduino.azurewebsites.net/add.php");
  post.addData("clean", "clean");
  println("Sent");
  println("Reponse Content: " + post.getContent());

  // Assune that we are in light mode.
  color_scheme = lightMode;
}

// Going to use flood fill the get all the positions of the adjacent stone.
// NOTE:
// The y_position is stores before x_position
ArrayList<ArrayList<Integer>> checkGroup(int pos_x, int pos_y){

  // Start by storing all the positions of the stone in the group.
  ArrayList<ArrayList<Integer>> groupPostion = new ArrayList<ArrayList<Integer>>();

  // Just the position of the current stone.
  ArrayList<Integer> position = new ArrayList<Integer>();

  // The searched stone will always be visited.
  visited[pos_y-1][pos_x-1] = true;


  // Base Case if the color of the stone has the difference color or empty space
  // Just return nothing.
  if(board[pos_y-1][pos_x-1] == 0){
    return groupPostion;
  }
  if(board[pos_y-1][pos_x-1] != current_player){
    return groupPostion;
  }

  // Else add the position of current stone.
  position.add(pos_y);
  position.add(pos_x);
  groupPostion.add(position);


  // Search up neightbours that haven't been visited
  if (pos_y-2 >= 0) {
    if (! (visited[pos_y-2][pos_x-1])) {
      groupPostion.addAll(checkGroup(pos_x, pos_y-1));
    }
  }
  if (pos_y < 9) {
    if (! (visited[pos_y][pos_x-1])) {
      groupPostion.addAll(checkGroup(pos_x, pos_y+1));
    }
  }
  if (pos_x < 9) {
    if (! (visited[pos_y-1][pos_x])) {
      groupPostion.addAll(checkGroup(pos_x+1, pos_y));
    }
  }
  if (pos_x-2 >= 0) {
    if (! (visited[pos_y-1][pos_x-2])) {
      groupPostion.addAll(checkGroup(pos_x-1, pos_y));
    }
  }

  return groupPostion;
}

// After getting all the group we will find the liberty of the group.
// The same as whether it is surrounded or not.
int getGroupLiberty(ArrayList<ArrayList<Integer>> groupPos){

  // Initialize the liberty
  int sum_liberty = 0;

  // Current stone position. (y starts first).
  ArrayList<Integer> pos;
  for (int i = 0; i < groupPos.size() ; i++) {
    // To make the code looks easiler
    pos = groupPos.get(i);

    int pos_y = pos.get(0);
    int pos_x = pos.get(1);

    // Go through all the neightbours
    if (pos_y-2 >= 0) {
      if(board[pos_y-2][pos_x-1] == 0){
        sum_liberty = sum_liberty + 1;
      }
    }
    if (pos_y < 9) {
      if(board[pos_y][pos_x-1] == 0){
        sum_liberty = sum_liberty + 1;
      }
    }
    if (pos_x-2 >= 0) {
      if(board[pos_y-1][pos_x-2] == 0){
        sum_liberty = sum_liberty + 1;
      }
    }
    if (pos_x < 9) {
      if(board[pos_y-1][pos_x] == 0){
        sum_liberty = sum_liberty + 1;
      }
    }
  }

  return sum_liberty;
}

// After we find the group, check whether the group of stones is surrounded or not.
// If yes, we remove the surrounded stone.
void removeCapturedGroups(){
  // Start with empty group of stone.
  ArrayList<ArrayList<Integer>> groupStone;

  // For every position in the board
  for(int y = 0; y < 9; y++){
    for (int x = 0; x < 9; x++) {
      // if the stone isn't visited and not an empty space.
      if (!(boardVisited[y][x]) && board[y][x] != 0) {
        // we find a group of stones.
        //This can be one stone only
        groupStone = checkGroup(x+1, y+1);

        // get the liberty of that group.
        int liberty = getGroupLiberty(groupStone);

        // if the liberty of the group is zero.
        if(liberty == 0){
          // Start to remove the points.
          for (int i = 0 ; i < groupStone.size() ; i++) {
            board[groupStone.get(i).get(0)-1][groupStone.get(i).get(1)-1] = 0;
          }
        }

        // After the removing, the visited array is removed
        // because the method checkGroup always use visited
        clean(visited);
      }
    }
  }
  // clean for the next use.
  clean(boardVisited);
}


// This is the drawing part of the program.
void drawRectAtBoardPos(int pos_x, int pos_y, int player_number){
  if(player_number == 2){
    fill(color_scheme.player2_color);
  } else if (player_number == 1){
    fill(color_scheme.player1_color);
  } else if (player_number == 3){
    fill(color_scheme.cursor_color);
  }

  // array index starts at 1.
  int start_rect_x = 90 * (pos_x - 1);
  int start_rect_y = 90 * (pos_y - 1);

  // Size will always be 90 * 90
  rect(start_rect_x, start_rect_y, 90, 90);
}

// This when we draw the whole board.
void drawUpdateGrid(){
  for(int x = 0; x < 9; x++){
    for (int y = 0; y < 9; y++) {
      if (board[y][x] == 1) {
        drawRectAtBoardPos(x+1, y+1, 1);
      } else if (board[y][x] == 2){
        drawRectAtBoardPos(x+1, y+1, 2);
      }
    }
  }
}

// switch the players.
void switchPlayer(){
  if(current_player == 1){
    current_player = 2;
  } else {
    current_player = 1;
  }
}

// Start with drawing part.
void draw() {

  // Get the value from the port.
  if (myPort.available() > 0){
    val = myPort.read();
  }

  // Remove the group of stone that is captured.
  removeCapturedGroups();

  // Starting with button inputs ------------------------------------
  // NOTE
  // I added  background(color_scheme.board_color), so that the screen isn't always reseting.
  // The each cell of the button_counter will reset when we press the button.
  // It can be press again when the button is reseted.
  if(val == 1 && button_counter[0] == pressAgain){
    background(color_scheme.board_color);
    // Move Up
    if(cursor_y-1 >= 1){
      drawRectAtBoardPos(cursor_x, cursor_y-1, 3);
      cursor_y = cursor_y-1;
    }
    button_counter[0] = 1;
  } else if (val == 2 && button_counter[1] == pressAgain){
    background(color_scheme.board_color);

    // Move Down
    if(cursor_y+1 <= 9){

      drawRectAtBoardPos(cursor_x, cursor_y+1, 3);
      cursor_y = cursor_y+1;
    }
    button_counter[1] = 1;
  } else if (val == 3 && button_counter[2] == pressAgain){
    background(color_scheme.board_color);

    // Move Right
    if(cursor_x+1 <= 9){

      drawRectAtBoardPos(cursor_x+1, cursor_y, 3);
      cursor_x = cursor_x+1;
    }
    button_counter[2] = 1;
  } else if (val == 4 && button_counter[3] == pressAgain){
    background(color_scheme.board_color);
    // Move Left
    if(cursor_x-1 >= 1){

      drawRectAtBoardPos(cursor_x-1, cursor_y, 3);
      cursor_x = cursor_x-1;
    }
    button_counter[3] = 1;
  } else if (val == 5 && button_counter[4] == pressAgain){
    background(color_scheme.board_color);
    // Place a stone

    if(board[cursor_y-1][cursor_x-1] == 0){
      board[cursor_y-1][cursor_x-1] = current_player;

      PostRequest post = new PostRequest("http://phuarduino.azurewebsites.net/add.php");
      post.addData("x", str(cursor_x));
      post.addData("y", str(cursor_y));
      post.send();

      switchPlayer();
    } else {
      println("Cant place here");
    }

    // When press the stone send the POST request.
    button_counter[4] = 1;

  }

  // end of the input data -------------------------------------

  // Adter the input, we update the screen.
  drawUpdateGrid();

  // Draing a grid.
  stroke(color_scheme.line_color);
  // Verticle line
  for (int i = 1; i < 10; i++) {
    strokeWeight(2);
    line(90 * i, 0, 90 * i, 810);
  }
  // Horizontal line
  for (int i = 1; i < 10; i++) {
    strokeWeight(2);
    line(0, 90 * i, 810, 90 * i);
  }

  // Button counter
  // The button will start to increase when we press the button
  // And it will end, when it reach maximum.
  for (int i = 0; i < 5 ; i++ ) {
    if (button_counter[i] >= 1 && button_counter[i] < pressAgain) {
      button_counter[i] = button_counter[i] + 1;
    } else {
      button_counter[i] = 1;
    }
  }
}
