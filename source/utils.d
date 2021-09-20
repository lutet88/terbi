module terbi.utils;

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
        this.x1 = pos1.x;
        this.y1 = pos1.y;
        this.x2 = pos2.x;
        this.y2 = pos2.y;

        assert (x1 < x2);
        assert (y1 < y2);
    }

    this(Vector2 center, int width, int height){
        this.x1 = center.x - width / 2;
        this.x2 = center.x + width / 2;
        this.y1 = center.y - height / 2;
        this.y2 = center.y + height / 2;

        assert (x1 < x2);
        assert (y1 < y2);
    }

    // takes position [0, 1] and returns absolute position
    Vector2 getAbsolutePosition(Vector2 vec){
        return new Vector2(
            getXAbsolute(vec.x),
            getYAbsolute(vec.y)
        );
    }

    // takes size [0, 1] and returns absolute size
    Vector2 getAbsoluteSize(Vector2 size){
        return new Vector2(
            size.x * (x2 - x1);
            size.y * (y2 - y1);
        );
    }

    // takes radius [0, 1] and return absolute radius based on geometric mean of X and Y
    double getAbsoluteRadius(double radius){
        return sqrt((x2 - x1) * (y2 - y1));
    }
}
