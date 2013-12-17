import 'dart:html';
import 'dart:math';

const String INTRO_SELECTOR = "#intro";
const String CANVAS_SELECTOR = "#box_canvas";

const int NUM_BOXES = 7;
final Size GUTTER = new Size(4,4);

void main() 
{
  resizeCanvas();
  drawBoxes( NUM_BOXES);
}

/**
 * Resize the canvas to be as big as possible.
 */
resizeCanvas() 
{
  DivElement introDiv = querySelector( INTRO_SELECTOR);
  CanvasElement canvas = querySelector( CANVAS_SELECTOR);
  canvas.width = window.innerWidth - 40;
  canvas.height = window.innerHeight - introDiv.clientHeight - 80;
}

/**
 * Draw n x n boxes on the canvas.
 */
void drawBoxes( int n)
{
  CanvasElement canvas = querySelector( CANVAS_SELECTOR);
  
  int squareSize = min( canvas.width ~/ (n), canvas.height ~/ (n));
  
  Size boxCellSize = new Size( squareSize, squareSize);
  
  /**
   * Top/Bottom, Left/Right
   */
   
  ColorHSL tlColor = new ColorHSL(0, 100, 50);    // red
  ColorHSL trColor = new ColorHSL(300, 100, 20);  // blue
  ColorHSL blColor = new ColorHSL(60, 100, 50);   // yellow
  ColorHSL brColor = new ColorHSL(120, 10, 80);  // green
  
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      ColorHSL fillColor;
      double horizontalFraction, verticalFraction;  // How far to right/bottom we are (0.0-1.0).
      horizontalFraction = j/(n-1);
      verticalFraction = i/(n-1);
//      if (i == 0)
//      {
//        fillColor = new ColorHSL( ( tlColor.hue * (1-horizontalFraction) + trColor.hue * horizontalFraction).round(),
//            100, 50);
//      }
//      else if (i == n-1)
//      {
//        fillColor = new ColorHSL( (blColor.hue * (1-horizontalFraction) + brColor.hue * horizontalFraction).round(),
//            100, 50);
//      }
//      else if (j == 0)
//      {
//        fillColor = new ColorHSL((tlColor.hue * (1-verticalFraction) + blColor.hue * verticalFraction).round(), 
//            100, 50);
//      }
//      else if (j == n-1)
//      {
//        fillColor = new ColorHSL( (trColor.hue * (1-verticalFraction) + brColor.hue * verticalFraction).round(),
//            100, 50);
//      }
//      else
//      {
////        fillColor = new ColorHSL(0, 0, 100);
//        fillColor = boxFillColor( horizontalFraction, verticalFraction,
//          tlColor, trColor, blColor, brColor);
//      }
      fillColor = boxFillColor( horizontalFraction, verticalFraction,
          tlColor, trColor, blColor, brColor);
      drawBoxAt( i, j, boxCellSize, GUTTER, fillColor);
    }
  }
    
}

/**
 * Returns the color a box that is some fraction along the two axes should be, given the colors of the four colors.
 */
ColorHSL boxFillColor(double aHorizontalFraction, double aVerticalFraction, 
             ColorHSL aTlColor, ColorHSL aTrColor, ColorHSL aBlColor, ColorHSL aBrColor) 
{
  double hf = aHorizontalFraction;
  double vf = aVerticalFraction;
  
  double topHue = hueBetween( aTlColor.hue, aTrColor.hue, aHorizontalFraction);
  double bottomHue = hueBetween( aBlColor.hue, aBrColor.hue, aHorizontalFraction);
  
  double middleHue = hueBetween( topHue, bottomHue, aVerticalFraction);
  
  double topSat = aTlColor.saturation + (aTrColor.saturation - aTlColor.saturation) * hf;
  double bottomSat = aBlColor.saturation + (aBrColor.saturation - aBlColor.saturation) * hf;
  
  double middleSat = topSat + (bottomSat - topSat) * vf;
  
  double topLightness = aTlColor.lightness + (aTrColor.lightness - aTlColor.lightness) * hf;
  double bottomLightness = aBlColor.lightness + (aBrColor.lightness - aBlColor.lightness) * hf;
  
  double middleLightness = topLightness + (bottomLightness - topLightness) * vf;
  
//  double tlhue, trhue, blhue, brhue;
//  tlhue = aTlColor.hue * (1-hf);
//  trhue = aTrColor.hue * hf;
//  blhue = aBlColor.hue * (1-hf);
//  brhue = aBrColor.hue * hf;
//  
//  double topHue = tlhue + trhue;
//  double bottomHue = blhue + brhue;
//  
//  topHue *= (1-vf);
//  bottomHue *= vf;
//  
//  double hue = topHue + bottomHue;
  
  ColorHSL retval;
//  retval = new ColorHSL((hue/2).round(), 100, 50);
//  retval = new ColorHSL(hue.round() % 360, 100, 50);
  retval = new ColorHSL(middleHue.round(), middleSat.round(), middleLightness.round());

  return retval;     
}

/**
 * Returns a hue between the two hues, where we are aFraction of the toward hue2 from hue1.
 */
double hueBetween(num hue1, num hue2, double aFraction) 
{
  double retval;
  int direction;
  if (hue1 < hue2)
  {
    if (hue2 - hue1 > 180)  
      direction = -1;        // e.g. red (0) to blue (240)
    else
      direction = 1;        // e.g. yellow (60) to green (120)
  }
  else if (hue1 > hue2)
  {
    if (hue1 - hue2 < 180)  // e.g., blue (240) to cyan (180)
      direction = -1;
    else
      direction = 1;       // e.g. blue to red 
  }
  else
    direction = 1;  // The two hues are equal, but whatever.
  
  num diff = (hue2 - hue1).abs();
  if (diff > 180)
    diff = 360 - diff;
  
  diff *= aFraction;
  
  retval = hue1 + diff * direction;
  
  return retval;
}

/**
 * Draws a single box at given "box coordinates".  Boxes are arranged into rows and columns.
 * aBoxCellSize is the size of the "cell" into which a box must fit, including padding, margin, etc.
 * aGutterFactor is the fraction of the box cell that will be devoted to "gutters" (the space between boxes).
 * Pick a value between 2 and 4 (for example).
 */
void drawBoxAt( int aRow, int aColumn, Size aBoxCellSize, Size aGutterFactor, ColorHSL aFillColor)
{
  Size gutter = new Size( 
      aBoxCellSize.width ~/ aGutterFactor.width, 
      aBoxCellSize.height ~/ aGutterFactor.height);
  Point cellTopLeft = new Point(
      aColumn * aBoxCellSize.width, 
      aRow * aBoxCellSize.height);
  Point boxTopLeft = new Point(
      cellTopLeft.x + gutter.width ~/ 2,
      cellTopLeft.y + gutter.height ~/ 2);
  Size boxSize = new Size( aBoxCellSize.width - gutter.width, aBoxCellSize.height - gutter.height);
  
  CanvasElement canvas = querySelector( CANVAS_SELECTOR);
  CanvasRenderingContext2D context = canvas.context2D;
  
  if (aFillColor != null)
  {
    context.setFillColorHsl(aFillColor.hue, aFillColor.saturation, aFillColor.lightness);
//    context.setFillColorRgb(255, 255, 128, 1.0);
//    context.setFillColorHsl(0, 50, 50, 1.0);
    context.fillRect( boxTopLeft.x, boxTopLeft.y, boxSize.width, boxSize.height);
  }
  context.strokeRect( boxTopLeft.x, boxTopLeft.y, boxSize.width, boxSize.height); 
}

class Size
{
  int width;
  int height;
  
  Size(this.width, this.height);
}

class Point
{
  int x, y;
  
  Point( this.x, this.y);
}

class ColorHSL
{
  int hue;
  int saturation;
  int lightness;
  
  /**
   * Specifies a color as hue, saturation, lightness.
   * 
   * * Hue: 0-360 degrees; red is 0; yellow, 60; green, 120; blue, 240.
   * * Saturation: 0-100; 0 is completely unsaturated (gray); 100 is fully saturated (eye-hurting pure color).
   * * Lightness: 0-100; 0 is black; 100 is white (not full color); 50 is in between (so you can see your 
   *   saturated color).
   */
  ColorHSL( int aHue, int aSaturation, int aLightness)
  {
    assert( 0 <= aSaturation && aSaturation <= 100);
    assert( 0 <= aLightness && aLightness <= 100);
    
    hue = (aHue % 360 + 360) % 360; // First mod is handle negative numbers.
    saturation = aSaturation;
    lightness = aLightness;
  }
  
}