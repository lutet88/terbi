module terbi.games.simpleMania;

import std.stdio;
import std.container;
import std.conv;
import std.range;
import raylib;

import terbi.game;
import terbi.map;
import terbi.utils;
import terbi.gameObjects;


const double GAME_SPEED = 0.8; // screens per second
const double HIT_LOCATION = 0.9;

class SimpleManiaGame : Game {
    MusicPlayer music;
    Map map;
    int keys;

    WindowBoundingBox window;

    this(Map map, WindowBoundingBox window) {
        music = new MusicPlayer(map.general.audioClip);
        keys = map.difficulty.keys;
        this.map = map;
        this.window = window;
    }

    override void start() {
        music.play();
    }

    override GameObject[] update() {
        music.update();

        double now = music.time() - (1 - HIT_LOCATION) * 1000;
        double next = now + GAME_SPEED * 1000;

        HitObject[] hitObjects = map.getHitObjects(cast(int) now, cast(int) next + 1);
        int objectCount = cast(int) hitObjects.walkLength;
        GameObject[] objects = new GameObject[objectCount + 1];

        // object 0 is a rectangle depicting the hit line
        objects[0] = new RectangleObject(Vector2(0.5, 0.915), 1, 0.03, Color(190, 190, 190, 255));
        objects[0].render(window);

        for (int i = 1; i < objectCount + 1; i++) {
            int col = hitObjects[i-1].column;
            double x = (col + 0.5) * (1.0 / keys);

            double time = (hitObjects[i-1].time - now) / 1000.0;
            double y = 1 - (time / GAME_SPEED / HIT_LOCATION);

            objects[i] = new RectangleObject(Vector2(x, y), (1.0 / keys) - 0.008, 0.03, Color(152, 127, 226, 255));
            objects[i].render(window);
        }

        return objects;
    }
}
