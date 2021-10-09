module terbi.score;

import std.stdio;
import std.format;

import terbi.map;


class Score {
    double accuracy = 1;
    double scorePart = 0;
    int maxScore;
    int currentMaxScore = 0;
    int currentScore = 0;

    this(int objectCount) {
        maxScore = objectCount * 320;
    }

    void objectHit(NoteType n) {
        currentScore += cast(int) n;
        currentMaxScore += 320;
        scorePart = cast(double) currentScore / maxScore;
        accuracy = cast(double) currentScore / currentMaxScore;
    }

    double getAccuracy() {
        return accuracy;
    }

    string getPercentAccuracy() {
        return "%3.2f".format(accuracy * 100);
    }

    int getScore() {
        return cast(int) (scorePart * 1_000_000);
    }
}
