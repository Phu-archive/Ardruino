class AIPad extends Pad{

  AIPad(float start_x, float start_y, float start_speed, float start_pad_width, float start_pad_height){
    super(start_x, start_y, start_speed, start_pad_width, start_pad_height);
  }

  void move(Ball b){
      y = y + (b.y - y) * speed_y * speed_y;
  }

}
