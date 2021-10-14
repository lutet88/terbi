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
import terbi.score;


const double GAME_SPEED = 0.5; // screens per second
const double HIT_LOCATION = 0.9;

class SimpleManiaGame : Game {
    MusicPlayer music;
    Map map;
    int keys;
    double offset = 0;

    int prevMissCalculationTime = 0;

    // for displaying latest note type
    int prevNoteTime = -1_000_000; // placeholder
    NoteType prevNoteType = NoteType.NONE;

    WindowBoundingBox window;
    KeyBindings keybinds;
    InputHandler input;
    Score score;

    this(Map map, WindowBoundingBox window, KeyBindings keybinds) {
        music = new MusicPlayer(map.general.audioClip);
        keys = map.difficulty.keys;
        this.map = map;
        this.window = window;
        this.keybinds = keybinds;
        input = new InputHandler(this.keybinds.keys);
        score = new BasicScore(cast(int) map.hitObjects.length, map.difficulty.accuracy);
    }

    override void setOffset(int offset) {
        // offset in milliseconds
        this.offset = offset;
        music.setOffset(offset);
        input.setOffset(offset);
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
        GameObject[] objects = new GameObject[objectCount + keys];

        // object 0 through keys depict each key (whether it is pressed)
        for (int i = 0; i < keys; i++) {
            double x = (i + 0.5) * (1.0 / keys);
            Color c;
            if (input.isPressed(i)) {
                c = Color(180, 180, 180, 255);
            } else {
                c = Color(60, 60, 60, 255);
            }
            new RectangleObject(Vector2(x, HIT_LOCATION), 1.0 / keys, 0.03, c).render(window);
        }

        // key objects
        for (int i = keys; i < objectCount + keys; i++) {
            if (hitObjects[i-keys].hit) continue;
            int col = hitObjects[i-keys].column;
            double x = (col + 0.5) * (1.0 / keys);

            double time = (hitObjects[i-keys].time - now) / 1000.0;
            double y = 1 - (time / GAME_SPEED / HIT_LOCATION);

            new RectangleObject(Vector2(x, y), (1.0 / keys) - 0.008, 0.03, Color(152, 127, 226, 255)).render(window);
        }

        // score objects
        GameObject scoreDisplay = new TextObject(to!string(score.getScore()), Vector2(0.5, 0.06), 56, Color(210, 210, 210, 255));
        scoreDisplay.render(window);

        GameObject accDisplay = new TextObject(to!string(score.getPercentAccuracy()), Vector2(0.5, 0.1), 28, Color(210, 210, 210, 255));
        accDisplay.render(window);

        // temporary: latest note
        if (prevNoteTime + 300 > music.time()) {
            // show note type text
            GameObject latestNoteDisplay = new TextObject(to!string(prevNoteType), Vector2(0.5, 0.3), 48, noteColor(prevNoteType));
            latestNoteDisplay.render(window);
        }

        return objects;
    }


    void processInput() {
        double timingWindow = score.getTimingWindow(NoteType.MISS) / 2.0;

        // process notes that have been hit
        while (input.hasKeyEvents()) {
            KeyEvent k = input.getKeyEvent();
            if (k.status != KeyStatus.KEY_PRESSED) continue;

            // find all hitObjects within miss-range of this keypress
            HitObject*[] matchingHitObjects = map.getHitObjects(
                cast(int) (k.time - timingWindow),
                cast(int) (k.time + timingWindow)
            );

            foreach (HitObject* ho; matchingHitObjects) {
                if (ho.hit || ho.column != k.key) continue;
                ho.hit = true;
                ho.hitTime = k.time - ho.time;
                ho.hitType = score.getNoteByTiming(ho.hitTime);
                score.objectHit(ho.hitTime);
                prevNoteTime = cast(int) music.time();
                prevNoteType = ho.hitType;
                break;
            }
        }

        // process notes that haven't been hit
        int currentMissTime = cast(int) (music.inputTime() - timingWindow);

        HitObject*[] potentialMissedHitObjects = map.getHitObjects(
                prevMissCalculationTime,
                currentMissTime
        );

        foreach (HitObject* ho; potentialMissedHitObjects) {
            if (!ho.hit) {
                ho.hit = true;
                ho.hitTime = music.time() - ho.time;
                ho.hitType = NoteType.MISS;
                score.objectHit(ho.hitTime);
                prevNoteTime = cast(int) music.time();
                prevNoteType = NoteType.MISS;
            }
        }

        prevMissCalculationTime = currentMissTime;

    }

    Color noteColor(NoteType note) {
        switch (note) {
            case NoteType.MARV:
                return Color(210, 120, 240, 255);
            case NoteType.PERF:
                return Color(245, 193, 61, 255);
            case NoteType.GOOD:
                return Color(95, 219, 57, 255);
            case NoteType.OK:
                return Color(108, 129, 204, 255);
            case NoteType.BAD:
                return Color(196, 183, 159, 255);
            case NoteType.MISS:
                return Color(235, 66, 66, 255);
            case NoteType.NONE:
                return Color(0, 0, 0, 0);
            default:
                assert(0);
        }
    }
}
