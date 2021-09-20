module terbi.gameObjects;

import raylib;

import terbi.utils;


abstract class GameObject {
    Vector2 center;
    abstract void render(WindowBoundingBox wbb);
}

class RectangleObject : GameObject {
    Vector2 topLeft;
    Vector2 bottomRight;
    Vector2 size;
    Color fillColor;

    // base constructor: fillColor = GRAY
    this(Vector2 center, double width, double height){
        this.center = center;
        this.topLeft = Vector2(center.x - width / 2.0, center.y - height / 2.0);
        this.bottomRight = Vector2(center.x + width / 2.0, center.y + height / 2.0);
        this.size = Vector2(width, height);
        this.fillColor = Color(127, 127, 127, 255);
    }

    // constructor with color definition
    this(Vector2 center, double width, double height, Color fill){
        this.center = center;
        this.topLeft = Vector2(center.x - width / 2.0, center.y - height / 2.0);
        this.bottomRight = Vector2(center.x + width / 2.0, center.y + height / 2.0);
        this.size = Vector2(width, height);
        this.fillColor = fill;
    }

    override void render(WindowBoundingBox wbb){
        DrawRectangleV(wbb.getAbsolutePosition(topLeft), wbb.getAbsoluteSize(size), fillColor);
    }
}

class CircleObject : GameObject {
    double radius;
    Color fillColor;

    // base constructor: fillColor = GRAY
    // NOTE: radius is scaled to the geometric mean of X, Y
    this(Vector2 center, double radius){
        this.center = center;
        this.radius = radius;
        this.fillColor = Color(127, 127, 127, 255);
    }

    // constructor with color definition
    // NOTE: radius is scaled to the geometric mean of X, Y
    this(Vector2 center, double radius, Color fill){
        this.center = center;
        this.radius = radius;
        this.fillColor = fill;
    }

    override void render(WindowBoundingBox wbb){
        DrawCircleV(wbb.getAbsolutePosition(center), wbb.getAbsoluteRadius(radius), fillColor);
    }
}
