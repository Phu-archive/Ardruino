class PlayerPad extends Pad{

  PlayerPad(float start_x, float start_y, float start_speed, float start_pad_width, float start_pad_height){
    super(start_x, start_y, start_speed, start_pad_width, start_pad_height);
  }

  // 30 so that the pad didn't fully gone
  // Although there is no need to have the argument for the moveUp, but I add it just for the consistance.
  void moveUp(int height){
    if (y + pad_width > 30){
      y = y - speed_y * 5;
    }
  }

  // Minus 30 so that the pad didn't fully gone
  void moveDown(int height){
    if (y + pad_width < height-30){
      y = y + speed_y * 5;
    }
  }

}
