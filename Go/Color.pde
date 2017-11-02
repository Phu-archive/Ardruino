class ColorScheme{
  // Contains the boards color scheme.
  color board_color;
  color player1_color;
  color player2_color;
  color line_color;
  color cursor_color;

  ColorScheme(color new_board_color, color new_player1_color, color new_player2_color, color new_line_color, color new_cursor_color){
    board_color = new_board_color;
    player1_color = new_player1_color;
    player2_color = new_player2_color;
    line_color = new_line_color;
    cursor_color = new_cursor_color;
  }
}
