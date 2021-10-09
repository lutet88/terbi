module terbi.input;

import std.container : DList;
import std.conv;
import std.stdio;

import raylib;


struct KeyEvent {
    int key;
    KeyStatus status;
    double time;
}

enum KeyStatus {
    KEY_PRESSED,
    KEY_RELEASED
}

struct KeyState {
    int key;
    KeyStatus status = KeyStatus.KEY_RELEASED;
}


class InputHandler {
    KeyState[] keyStates;
    double prevUpdateTime;
    DList!KeyEvent keyEvents;

    this(int[] keys) {
        this.keyStates = new KeyState[keys.length];
        for (int i = 0; i < keys.length; i++) {
            this.keyStates[i] = KeyState(keys[i], KeyStatus.KEY_RELEASED);
        }
        keyEvents = DList!KeyEvent();
    }

    void update(double now) {
        double betweenTime = (prevUpdateTime + now) / 2.0;

        // Note for this section:
        // Input is highly framerate-dependent.
        // TODO: Modify redthing1/raylib to implement event queue
        for (int i = 0; i < keyStates.length; i++) {
            if (keyStates[i].status == KeyStatus.KEY_RELEASED && IsKeyDown(keyStates[i].key)) {
                keyEvents.insertBack(KeyEvent(i, KeyStatus.KEY_PRESSED, betweenTime));
                keyStates[i].status = KeyStatus.KEY_PRESSED;
                // writeln("key pressed " ~ to!string(i) ~ " at time " ~ to!string(betweenTime));
            }
            if (keyStates[i].status == KeyStatus.KEY_PRESSED && IsKeyUp(keyStates[i].key)) {
                keyEvents.insertBack(KeyEvent(i, KeyStatus.KEY_RELEASED, betweenTime));
                keyStates[i].status = KeyStatus.KEY_RELEASED;
                // writeln("key released " ~ to!string(i) ~ " at time " ~ to!string(betweenTime));
            }
        }
        prevUpdateTime = now;
    }

    bool isPressed(int key) {
        return keyStates[key].status == KeyStatus.KEY_PRESSED;
    }

    bool hasKeyEvents() {
        return !keyEvents.empty();
    }

    KeyEvent getKeyEvent() {
        KeyEvent front = keyEvents.front();
        keyEvents.removeFront();
        return front;
    }
}
