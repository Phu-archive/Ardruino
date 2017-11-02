// This the pad class.
class Pad extends Object{
  float pad_width;
  float pad_height;

  int score;

  Pad(float start_x, float start_y, float start_speed, float start_pad_width, float start_pad_height){
    super(start_x, start_y, 0, start_speed);
    pad_width = start_pad_width;
    pad_height = start_pad_height;

    score = 0;
  }

}
