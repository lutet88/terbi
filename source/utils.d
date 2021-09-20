module terbi.utils;

import std.math;
import raylib;


struct WindowBoundingBox {
    // x1 < x2, y1 < y2
    int x1;
    int y1;
    int x2;
    int y2;

    this(int x1, int y1, int x2, int y2){
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;

        assert (x1 < x2);
        assert (y1 < y2);
    }

    this(Vector2 pos1, Vector2 pos2){
        this.x1 = cast(int) pos1.x;
        this.y1 = cast(int) pos1.y;
        this.x2 = cast(int) pos2.x;
        this.y2 = cast(int) pos2.y;

        assert (x1 < x2);
        assert (y1 < y2);
    }

    this(Vector2 center, int width, int height){
        this.x1 = cast(int) center.x - width / 2;
        this.x2 = cast(int) center.x + width / 2;
        this.y1 = cast(int) center.y - height / 2;
        this.y2 = cast(int) center.y + height / 2;

        assert (x1 < x2);
        assert (y1 < y2);
    }

    // takes position [0, 1] and returns absolute position
    Vector2 getAbsolutePosition(Vector2 vec){
        return Vector2(
            vec.x * (x2 - x1) + x1,
            vec.y * (y2 - y1) + y1
        );
    }

    // takes size [0, 1] and returns absolute size
    Vector2 getAbsoluteSize(Vector2 size){
        return Vector2(
            size.x * (x2 - x1),
            size.y * (y2 - y1)
        );
    }

    // takes radius [0, 1] and return absolute radius based on geometric mean of X and Y
    double getAbsoluteRadius(double radius){
        return sqrt(cast(float) ((x2 - x1) * (y2 - y1)));
    }
}
