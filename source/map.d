module terbi.map;

import std.stdio;
import std.container;
import std.conv;
import std.traits;
import raylib;

import terbi.utils;


struct HitObject {
    double x = 0.5;
    double y = 0.5;
    int column = -1;
    int time = 0; // milliseconds
    int type = 0;
    bool hit = false;
    double hitTime = 0; // milliseconds offset
    NoteType hitType = NoteType.NONE;
}


enum NoteType {
    MARV  = 320,
    PERF  = 300,
    GOOD  = 200,
    OK    = 100,
    BAD   = 50,
    MISS  = 0,
    NONE  = -1
}


struct TimingPoint {
    int time = 0; // milliseconds
    double beatDuration = 0; // milliseconds
    double sliderSpeed = 0.1; // screens per beat
    int meter = 4;
    double volume = 1.0;
}

struct Difficulty {
    // all values from [0,10], like osu
    double hpDrain = 7.5;
    int keys = -1;
    double circleSize = 7.5;
    double accuracy = 7.5;
    double approachRate = 7.5;
    double sliderSpeed = 7.5;
    double sliderTickRate = 7.5;
}

struct Source {
    string source;
    string id;
    SourceLocation location;
}

struct Metadata {
    string title;
    string artist;
    string titleAlt;
    string artistAlt;
    string creator;
    string difficulty;
    Source source;
}

struct General {
    Music audioClip;
    bool initialized = false;
    int leadInMilliseconds = 0;
    int previewMilliseconds = 1000;
}

class Map {
    General general;
    int mode;

    Difficulty difficulty;
    Metadata metadata;

    TimingPoint[] timingPoints;
    HitObject[] hitObjects;

    this() {
    }

    override string toString(){
        string header = "terbi map object at " ~ to!string(this.toHash()) ~ "\n";
        string general = "general data: " ~ to!string(general) ~ "\n";
        string metadata = "metadata: " ~ to!string(metadata) ~ "\n";
        string difficulty = "difficulty: " ~ to!string(difficulty) ~ "\n";
        string stats = "hitobjects: " ~ to!string(hitObjects.length) ~ " timingpoints: " ~ to!string(timingPoints.length);
        return header ~ general ~ metadata ~ difficulty ~ stats;
    }

    void unload() {
        UnloadMusicStream(general.audioClip);
    }

    // TODO: refactor getTimingPoints and getHitObjects into one binary search method with .time
    // probably make a Timeable interface or something

    TimingPoint[] getTimingPoints(int start, int end) {
        // binary search for the start timing point
        int left = 0;
        int right = cast(int) timingPoints.length - 1;
        int mid;

        int i = -1;

        while (left <= right) {
            mid = cast(int) (left + right) / 2;
            if (timingPoints[mid].time < start) {
                left = mid + 1;
            }
            else if (timingPoints[mid].time > start) {
                right = mid - 1;
            } else {
                i = mid;
                break;
            }
            // the equivalent clause of a while/else
            if (left > right){
                if (timingPoints[mid].time > start) {
                    i = mid;
                } else {
                    i = mid + 1;
                }
            }
        }

        TimingPoint[] tps = new TimingPoint[0];
        // starting from index i, move rightwards until end time is reached
        while (i < timingPoints.length && timingPoints[i].time <= end) {
            tps ~= [timingPoints[i]];
            i ++;
        }

        return tps;
    }

    HitObject*[] getHitObjects(int start, int end) {
        // binary search for the start hit object
        int left = 0;
        int right = cast(int) hitObjects.length - 1;
        int mid;

        int i = -1;

        while (left <= right) {
            mid = cast(int) (left + right) / 2;
            if (hitObjects[mid].time < start) {
                left = mid + 1;
            }
            else if (hitObjects[mid].time > start) {
                right = mid - 1;
            } else {
                i = mid;
                break;
            }
            // the equivalent clause of a while/else
            if (left > right){
                if (hitObjects[mid].time > start) {
                    i = mid;
                } else {
                    i = mid + 1;
                }
            }
        }

        HitObject*[] hos = new HitObject*[0];
        // starting from index i, move rightwards until end time is reached
        while (i < hitObjects.length && hitObjects[i].time <= end) {
            hos ~= [&hitObjects[i]];
            i ++;
        }

        return hos;
    }
}


// returns two-sided accuracy timing window
double accuracyTimingWindow(double acc, NoteType note) {
    switch (note) {
        case NoteType.MARV:
            return 80 - 6 * acc;
        case NoteType.PERF:
            return 160 - 12 * acc;
        case NoteType.GOOD:
            return 240 - 18 * acc;
        case NoteType.OK:
            return 320 - 24 * acc;
        case NoteType.BAD:
            return 400 - 30 * acc;
        case NoteType.MISS:
            return 560 - 42 * acc;
        case NoteType.NONE:
            return double.max;
        default:
            assert(0);
    }
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

NoteType getNoteByTiming(double acc, double offset) {
    // absolute value
    if (offset < 0) offset = -offset;

    foreach (NoteType e; [EnumMembers!NoteType]) {
        if (offset < accuracyTimingWindow(acc, e)) {
            return e;
        }
    }

    // uhh, just in case.
    return NoteType.NONE;
}
