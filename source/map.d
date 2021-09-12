module terbi.map;

import std.stdio;
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
    float hpDrain = 7.5;
    int keys = 4;
    float circleSize = 7.5;
    float accuracy = 7.5;
    float approachRate = 7.5;
    float sliderSpeed = 7.5;
    float sliderTickRate = 7.5;
}

struct Source {
    string source;
    string ID;
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

class Map {
    Sound audioclip;
    int leadInMilliseconds = 0;
    int previewMilliseconds = 1000;

    Difficulty difficulty;
    Metadata metadata;

    TimingPoint[] timingPoints;
    HitObject[] hitObjects;

    this(Sound audioclip, TimingPoint[] timingPoints, HitObject[] hitObjects) {
        this.audioclip = audioclip;
        this.timingPoints = timingPoints;
        this.hitObjects = hitObjects;
    }

    void setLeadIn(int ms){
        this.leadInMilliseconds = ms;
    }

    void setPreview(int ms){
        this.previewMilliseconds = ms;
    }

    void setDifficulty(Difficulty diff){
        this.difficulty = diff;
    }

    void setMetadata(Metadata meta){
        this.metadata = meta;
    }
}
