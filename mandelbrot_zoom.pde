double map_min_width;
double map_max_width;
double map_min_height;
double map_max_height;
int num_iterations = 50;
double zoom_speed = 0.1;
int hue_modulo = 30;
int mode = 1;


void setup() {
  colorMode(HSB, 360, 100, 100);
  //size(600, 600);
  fullScreen();
  reset_map();

  map_min_width = -0.750213293470586;
  map_max_width = -0.7414487263925814;
  map_min_height = -0.10840041240289094;
  map_max_height = -0.10347034345824527;

  draw_mandelbrot();
  capture_image();
}

void capture_image() {
  PImage texture = get();
  texture.save("captured_img.png");
}

void draw() {
  double width_dist = map_max_width - map_min_width;
  double height_dist = map_max_height - map_min_height;
  if (mousePressed) {
    double width_frac = (double)mouseX / (double)width;
    double height_frac = (double)mouseY / (double)height;
    map_min_width += zoom_speed * width_frac * width_dist;
    map_max_width -= zoom_speed * (1-width_frac) * width_dist;
    map_min_height += zoom_speed * height_frac * height_dist;
    map_max_height -= zoom_speed * (1-height_frac) * height_dist;
    draw_mandelbrot();
    println(map_min_width, map_max_width, map_min_height, map_max_height);
  }
}

double double_map(double value, double start1, double stop1, double start2, double stop2) {
  return ((value - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
}

void reset_map() {
  float aspect = (float)width / (float)height;
  map_min_width = -aspect;
  map_max_width = aspect;
  map_min_height = -1;
  map_max_height = 1;
}

void draw_mandelbrot() {
  background(0);
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      double a = double_map((double)x, (double)0, (double)width, (double)map_min_width, (double)map_max_width);
      double b = double_map((double)y, (double)0, (double)height, (double)map_min_height, (double)map_max_height);
      double Za = 0;
      double Zb = 0;
      int i = 0;
      while ((i < num_iterations) && (Za*Za - Zb*Zb < 1073741824)) {
        double new_Za = Za*Za - Zb*Zb + a;
        double new_Zb = 2*Za*Zb + b;
        Za = new_Za;
        Zb = new_Zb;
        i++;
      }
      if (Za*Za + Zb*Zb < 4) {
        pixels[y*width + x] = color(0);
      } else {
        float hue, brightness;
        if (mode == 1) {
          hue = map(i%128, 0, 128, 0, 360);
          //brightness = 100 - (5*i % 128);
          brightness = 100 - i%100;
        } else if (mode == 2) {
          hue = i % hue_modulo;
          brightness = map(i, 0, num_iterations, 0, 100);
        } else if (mode == 3) {
          hue = map(i%128, 0, 128, 0, 360);
          brightness = 100;
        } else if (mode == 4) {
          hue = i % hue_modulo;
          brightness = 100;
        } else {
          hue = map(i, 0, num_iterations, 0, 360);
          brightness = 100 - i % 100;
        }
        pixels[y*width + x] = color(hue, 90, brightness);
      }
    }
  }
  updatePixels();
}

void keyPressed() {
  println(key);

  switch(key) {
  case '1':
    // mode 1 with hue mapped and brightness moduloed
    mode = 1;
    draw_mandelbrot();
    break;
  case '2':
    // mode 2 with hue moduloed and brightness mapped
    mode = 2;
    draw_mandelbrot();
    break;
  case '3':
    mode = 3;
    draw_mandelbrot();
    break;
  case '4':
    mode = 4;
    draw_mandelbrot();
    break;
  case '5':
    mode = 5;
    draw_mandelbrot();
    break;
  case '[':
    // only useful in mode 2 or 4
    hue_modulo--;
    if (hue_modulo <= 0) hue_modulo = 1;
    draw_mandelbrot();
    break;
  case ']':
    // only useful in mode 2 or 4
    hue_modulo++;
    if (hue_modulo > 360) hue_modulo = 360;
    draw_mandelbrot();
    break;

  case 'r':
    reset_map();
    draw_mandelbrot();
    break;

  case '-':
    num_iterations -= 10;
    if (num_iterations < 1) num_iterations = 1;
    println("num_iterations: ", num_iterations);
    draw_mandelbrot();
    break;
  case '+':
    num_iterations += 10;
    println("num_iterations: ", num_iterations);
    draw_mandelbrot();
    break;
  case 'c':
    capture_image();
    break;
  default:
    break;
  }
}
