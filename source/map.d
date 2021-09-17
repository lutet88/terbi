module terbi.map;

import std.stdio;
import std.conv;
import raylib;

import terbi.enums;

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
}
