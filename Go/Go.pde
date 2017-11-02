import processing.serial.*;

Serial myPort;
int val;
int wait = 0;

ColorScheme color_scheme;

ColorScheme lightMode = new ColorScheme(255, #2c3e50, #95a5a6, 0, color(231, 76, 60, 50));
ColorScheme darkMode = new ColorScheme(0, #95a5a6, #2c3e50, 255, color(231, 76, 60));

// Press only once.
int[] button_counter = new int[5];

// Button time before you can press again
int pressAgain = 8;

// Board
int[][] board = new int[9][9];

// For floodfill algorithm.
Boolean[][] visited = new Boolean[9][9];

// For tracking the board
Boolean[][] boardVisited = new Boolean[9][9];

// Start at 1.
int cursor_x = 1;
int cursor_y = 1;

// Always start with darker player.
int current_player = 1;

// Track where player place the stone
int current_player_x = 1;
int current_player_y = 1;

void clean(Boolean[][] val){
  for(int i = 0; i < 9; i++){
    for (int j = 0; j < 9; j++) {
      val[i][j] = false;
    }
  }
}

void setup() {
  size(810,810); //So that it is 9x9
  background(255);

  // init the board
  for(int i = 0; i < 9; i++){
    for (int j = 0; j < 9; j++) {
      board[i][j] = 0;
    }
  }

  // init the button counter
  for (int i = 0; i < 5 ; i++) {
    button_counter[i] = pressAgain;
  }

  clean(visited);
  clean(boardVisited);

  String portName = "/dev/cu.usbmodem14511";
  myPort = new Serial(this, portName, 9600);

  // background(color_scheme.board_color);
}

void removeCapturedGroups(){
  ArrayList<ArrayList<Integer>> groupStone;
  for(int y = 0; y < 9; y++){
    for (int x = 0; x < 9; x++) {
      if (!(boardVisited[y][x]) && board[y][x] != 0) {
        groupStone = checkGroup(x+1, y+1);

        int liberty = getGroupLiberty(groupStone);
        if(liberty == 0){
          // Start to remove the points.
          for (int i = 0 ; i < groupStone.size() ; i++) {
            board[groupStone.get(i).get(0)-1][groupStone.get(i).get(1)-1] = 0;
            boardVisited[groupStone.get(i).get(0)-1][groupStone.get(i).get(1)-1] = true;
          }
        }
        // If not just clean the visited
        clean(visited);
      }
    }
  }
  clean(boardVisited);
}

// Going to use flood fill the get all the positions of the group.
ArrayList<ArrayList<Integer>> checkGroup(int pos_x, int pos_y){

  ArrayList<ArrayList<Integer>> groupPostion = new ArrayList<ArrayList<Integer>>();
  ArrayList<Integer> position = new ArrayList<Integer>();

  // add so that it is visited.
  visited[pos_y-1][pos_x-1] = true;

  // This will be before switch turns.
  // Base Case if the stone is stone with diff color or empty space
  if(board[pos_y-1][pos_x-1] == 0){
    return groupPostion;
  }
  if(board[pos_y-1][pos_x-1] != current_player){
    return groupPostion;
  }

  position.add(pos_y);
  position.add(pos_x);
  groupPostion.add(position);

  // Search up down right left direction
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

  // Before anythin clean up the visited
  return groupPostion;
}

int getGroupLiberty(ArrayList<ArrayList<Integer>> groupPos){
  // Loop through all the positions.
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

void switchPlayer(){
  if(current_player == 1){
    current_player = 2;
  } else {
    current_player = 1;
  }
}

void draw() {
  if (myPort.available() > 0){
    val = myPort.read();
  }

  if (wait < 500) {
    background(#8e44ad);
    textSize(72);
    text("Waiting for the light value", 30, 100);
    if (val == 6 || val == 7) {
      wait = 500;
      //the light mode signal is 6.
      if(val == 6){
       color_scheme = lightMode;
      // the dark mode signal is 7.
      } else if(val == 7){
       color_scheme = darkMode;
      }
    }
  } else if(wait > 550){
    removeCapturedGroups();
    println(val);
    // Input Stuff
    if(val == 1 && button_counter[0] == pressAgain){
      background(color_scheme.board_color);
      println("GO WITH ONE");
      // Move Up
      if(cursor_y-1 >= 1){
        drawRectAtBoardPos(cursor_x, cursor_y-1, 3);
        cursor_y = cursor_y-1;
      }
      button_counter[0] = 1;


    } else if (val == 2 && button_counter[1] == pressAgain){
      background(color_scheme.board_color);
      println("GO WITH TWO");
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
        switchPlayer();
        current_player_x = cursor_x;
        current_player_y = cursor_y;
      } else {
        println("Cant place here");
      }
      button_counter[4] = 1;

    }

    // Draw grid.....
    drawUpdateGrid();

    // For the line
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
  } else if(wait > 500 && wait < 550){
    background(color_scheme.board_color);
  }

  for (int i = 0; i < 5 ; i++ ) {
    if (button_counter[i] >= 1 && button_counter[i] < pressAgain) {
      button_counter[i] = button_counter[i] + 1;
    } else {
      button_counter[i] = 1;
    }
  }

  wait = wait + 1;
  delay(10);
}
