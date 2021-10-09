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
import terbi.input;


const double GAME_SPEED = 0.8; // screens per second
const double HIT_LOCATION = 0.9;

class SimpleManiaGame : Game {
    MusicPlayer music;
    Map map;
    int keys;
    double offset = 0;

    WindowBoundingBox window;
    KeyBindings keybinds;
    InputHandler input;

    this(Map map, WindowBoundingBox window, KeyBindings keybinds) {
        music = new MusicPlayer(map.general.audioClip);
        keys = map.difficulty.keys;
        this.map = map;
        this.window = window;
        this.keybinds = keybinds;
        this.input = new InputHandler(this.keybinds.keys);
    }

    override void setOffset(int offset) {
        // offset in milliseconds
        this.offset = offset;
    }

    override void start() {
        music.play();
    }

    override GameObject[] update() {
        music.update();
        input.update(music.time());

        processInput();

        double now = music.time() - (1 - HIT_LOCATION) * 1000;
        double next = now + GAME_SPEED * 1000;

        HitObject*[] hitObjects = map.getHitObjects(cast(int) now, cast(int) next + 1);
        int objectCount = cast(int) hitObjects.walkLength;
        GameObject[] objects = new GameObject[objectCount + 1 + keys];

        // object 0 through keys depict each key (whether it is pressed)
        for (int i = 0; i < keys; i++) {
            double x = (i + 0.5) * (1.0 / keys);
            Color c;
            if (input.isPressed(i)) {
                c = Color(180, 180, 180, 255);
            } else {
                c = Color(60, 60, 60, 255);
            }
            objects[i] = new RectangleObject(Vector2(x, HIT_LOCATION), 1.0 / keys, 0.03, c);
            objects[i].render(window);
        }

        // key objects
        for (int i = keys; i < objectCount + keys; i++) {
            int col = hitObjects[i-keys].column;
            double x = (col + 0.5) * (1.0 / keys);

            double time = (hitObjects[i-keys].time - now) / 1000.0;
            double y = 1 - (time / GAME_SPEED / HIT_LOCATION);

            objects[i] = new RectangleObject(Vector2(x, y), (1.0 / keys) - 0.008, 0.03, Color(152, 127, 226, 255));
            objects[i].render(window);
        }

        return objects;
    }


    void processInput() {
        while (input.hasKeyEvents()) {
            KeyEvent k = input.getKeyEvent();

            // find all hitObjects within miss-range of this keypress
            double timingWindow = accuracyTimingWindow(map.difficulty.accuracy, NoteType.MISS) / 2.0;
            HitObject*[] matchingHitObjects = map.getHitObjects(
                cast(int) (k.time - timingWindow),
                cast(int) (k.time + timingWindow)
            );

            foreach (HitObject* ho; matchingHitObjects) {
                if (ho.hit || ho.column != k.key) continue;
                ho.hit = true;
                ho.hitTime = k.time - ho.time;
                ho.hitType = getNoteByTiming(map.difficulty.accuracy, ho.hitTime);
                writeln(ho.hitType);
                break;
            }
        }
    }


}
