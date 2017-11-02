class Ball extends Object{

  float size;
  Pad fromPad;

  Ball(float start_x, float start_y, float start_speed_x, float start_speed_y, float start_size, Pad start_Pad){
    super(start_x, start_y, start_speed_x, start_speed_y);
    size = start_size;
    fromPad = start_Pad;
  }
  
  boolean isHitPad(Pad p){
    // https://stackoverflow.com/questions/21089959/detecting-collision-of-rectangle-with-circle

    float radius = size/2 + 2;

    // Start by finding the middle point of rectangle
    float middle_x = p.x + p.pad_width/2;
    float middle_y = p.y + p.pad_height/2;

    // Find the distance between circle and rectangle
    float dis_x = abs(middle_x - x);
    float dis_y = abs(middle_y - y);

    // if the distance is more than half-circle + half-rect then return False
    if (dis_x > (p.pad_width/2 + radius)){
      return false;
    }

    if (dis_y > (p.pad_height/2 + radius)){
      return false;
    }

    if (dis_x<=(p.pad_width/2)){
      return true;
    }
    if (dis_y<=(p.pad_width/2)){
      return true;
    }

    // Test for the corner.
    float diff_x = dis_x - p.pad_width/2;
    float diff_y = dis_y - p.pad_height/2;

    return (diff_x*diff_x + diff_y*diff_y) <= ((radius) * (radius)); // Add to make it more sensitive
  }

  void move(){
    x = x + speed_x;
    y = y + speed_y;
  }

  void bounce_x(){
    speed_x = speed_x * -1;
  }

  void bounce_y(){
    speed_y = speed_y * -1;
  }

  boolean checkHitVerticle(int height){
    return (y > height) || (y < 0);
  }

  boolean checkHitHorizontal(int height){
      return (x > width) || (x < 0);
  }

}
