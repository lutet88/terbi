module terbi.map;

import std.stdio;
import std.container;
import std.conv;
import raylib;

import terbi.utils;


struct HitObject {
    double x = 0.5;
    double y = 0.5;
    int time = 0; // milliseconds
    int type = 0;
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
    int keys = 4;
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
    // dunno if this is possible in D just yet...

    DList!TimingPoint getTimingPoints(int start, int end) {
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

        DList!TimingPoint tps = DList!TimingPoint();
        // starting from index i, move rightwards until end time is reached
        while (i < timingPoints.length && timingPoints[i].time <= end) {
            tps.insertBack([timingPoints[i]]);
            i ++;
        }

        return tps;
    }

    DList!HitObject getHitObjects(int start, int end) {
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

        DList!HitObject hos = DList!HitObject();
        // starting from index i, move rightwards until end time is reached
        while (i < hitObjects.length && hitObjects[i].time <= end) {
            hos.insertBack([hitObjects[i]]);
            i ++;
        }

        return hos;
    }
}
