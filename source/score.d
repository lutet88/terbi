module terbi.score;

import std.stdio;
import std.format;
import std.traits;
import std.conv;

import terbi.map;


class Score {
    // absolute accuracy, out of 1
    double accuracy = 1;

    // cumulative score, however it is implemented
    double scorePart = 0;

    // counter for each NoteType
    int[NoteType] noteTypeCounter;

    // getters for acc and score
    double getAccuracy() {
        return accuracy;
    }

    int getScore() {
        return cast(int) (scorePart * 1_000_000);
    }

    int[NoteType] getNoteTypeCounter() {
        return noteTypeCounter;
    }

    // string rep for accuracy
    string getPercentAccuracy() {
        return "%3.2f".format(accuracy * 100);
    }

    // accuracy value
    double accValue = 7.5; // default

    // setter for accuracy value
    void setAccValue(double accValue) {
        this.accValue = accValue;
    }

    // hit an object, given an offset, and add to this score
    abstract void objectHit(double offset);

    // get the timing window for a NoteType
    // should be the timing window on EITHER SIDE (+t/-t), not overall.
    abstract double getTimingWindow(NoteType note);

    // get the note type by offset
    abstract NoteType getNoteByTiming(double offset);
}


class BasicScore : Score {
    int maxScore;
    int currentMaxScore = 0;
    int currentScore = 0;
    int objectCount;
    int objectsHit = 0;

    this(int objectCount, double acc) {
        this.objectCount = objectCount;
        maxScore = objectCount * 320;
        setAccValue(acc);
    }

    override void objectHit(double offset) {
        NoteType n = getNoteByTiming(offset);
        noteTypeCounter[n]++;
        objectsHit++;
        currentScore += cast(int) n;
        currentMaxScore += 320;
        scorePart = cast(double) currentScore / maxScore;
        accuracy = cast(double) currentScore / currentMaxScore;

        if (objectsHit >= objectCount) {
            writeln(to!string(getNoteTypeCounter()));
        }
    }

    override double getTimingWindow(NoteType note) {
        switch (note) {
            case NoteType.MARV:
                return 80 - 6 * accValue;
            case NoteType.PERF:
                return 160 - 12 * accValue;
            case NoteType.GOOD:
                return 240 - 18 * accValue;
            case NoteType.OK:
                return 320 - 24 * accValue;
            case NoteType.BAD:
                return 400 - 30 * accValue;
            case NoteType.MISS:
                return 560 - 42 * accValue;
            case NoteType.NONE:
                return double.max;
            default:
                assert(0);
        }
    }

    // pretty "reference" implementation of getNoteByTiming
    override NoteType getNoteByTiming(double offset) {
        // ensure 0 <= offset
        if (offset < 0) offset = -offset;

        foreach (NoteType e; [EnumMembers!NoteType]) {
            if (offset < getTimingWindow(e)) {
                return e;
            }
        }

        // uhh, just in case.
        return NoteType.NONE;
    }
}

