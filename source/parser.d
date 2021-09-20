module terbi.parser;

import std.stdio;
import std.file;
import std.array;
import std.string;
import std.conv;
import std.container;
import std.traits;

import raylib;

import terbi.map;
import terbi.utils;


Map parseFile(string fileName, string outerPath) {
    auto data = cast(string) read(outerPath ~ fileName);
    auto lines = data.split("\n");

    // choose a parser
    Parser p;
    if (indexOf(lines[0], "osu") >= 0) {
        p = new OsuParser();
    }
    // find other conditions for other types of files once I get to that...

    // parse and return the map
    p.parse(lines, outerPath);
    return p.getMap();
}

interface Parser {
    void parse(string[] lines, string outerPath);
    void clearMap();
    Map getMap();
}

class OsuParser : Parser {
    /* This parser is designed to parse .osu file formats
    ** See https://osu.ppy.sh/wiki/en/osu%21_File_Formats/Osu_%28file_format%29
    ** Verified to work with v12, v13, v14 files.
    */

    enum Section : string {
        general = "[General]",
        editor = "[Editor]",
        metadata = "[Metadata]",
        difficulty = "[Difficulty]",
        events = "[Events]",
        timingPoints = "[TimingPoints]",
        hitObjects = "[HitObjects]"
    }

    Map map = new Map();
    auto timingPoints = new TimingPoint[0];
    auto hitObjects = new HitObject[0];

    override {
        void clearMap() {
            map = new Map();
            timingPoints = new TimingPoint[0];
            hitObjects = new HitObject[0];
        }

        Map getMap() {
            map.timingPoints = timingPoints[];
            map.hitObjects = hitObjects[];
            return map;
        }

        void parse (string[] lines, string outerPath) {
            // initialize currentSection, assuming [General] always comes first
            Section currentSection = Section.general;

            // for each line in the .osu file:
            for (int i = 0; i < lines.length; i++){
                // if the line's empty, just exit
                if (strip(lines[i]) == ""){
                    continue;
                }

                // match if there is a new section
                foreach (section; EnumMembers!Section) {
                    if (section == strip(lines[i])) {
                        currentSection = section;
                    }
                }

                // depending on current section, edit map
                switch (currentSection) {
                    case Section.general:
                        // split the line by separator
                        auto parts = lines[i].split(":");

                        // if there are 1 or less parts, assume invalid
                        if (parts.length <= 1) { continue; }

                        // create value variable, since all outcomes use parts[1]
                        auto value = strip(parts[1]);

                        // match parts[0] as key, assign values to the Map
                        switch (parts[0]) {
                            case "AudioFilename":
                                map.general.audioClip = LoadMusicStream(
                                        cast(immutable char*)(outerPath ~ value).idup
                                );
                                map.general.initialized = true;
                                break;
                            case "AudioLeadIn":
                                map.general.leadInMilliseconds = to!int(value);
                                break;
                            case "PreviewTime":
                                map.general.previewMilliseconds = to!int(value);
                                break;
                            case "Mode":
                                map.mode = to!int(value);
                                break;
                            default:
                                break;
                        }
                        break;

                    case Section.editor:
                        // implement editor later on
                        break;

                    case Section.metadata:
                        // split the line by separator
                        auto parts = lines[i].split(":");

                        // if there are 1 or less parts, assume invalid
                        if (parts.length <= 1) { continue; }

                        // create value variable, since all outcomes use parts[1]
                        auto value = strip(parts[1]);

                        // match parts[0] as key, assign values to the Map
                        switch (parts[0]) {
                            case "Title":
                                map.metadata.title = value;
                                break;
                            case "TitleUnicode":
                                map.metadata.titleAlt = value;
                                break;
                            case "Artist":
                                map.metadata.artist = value;
                                break;
                            case "ArtistUnicode":
                                map.metadata.artistAlt = value;
                                break;
                            case "Creator":
                                map.metadata.creator = value;
                                break;
                            case "Version":
                                map.metadata.difficulty = value;
                                break;
                            case "Source":
                                map.metadata.source.source = value;
                                map.metadata.source.location = SourceLocation.osu;
                                break;
                            case "BeatmapID":
                                map.metadata.source.id = value;
                                break;
                            default:
                                break;
                        }
                        break;

                    case Section.difficulty:
                        // split the line by separator
                        auto parts = lines[i].split(":");

                        // if there are 1 or less parts, assume invalid
                        if (parts.length <= 1) { continue; }

                        // create value variable, since all outcomes use parts[1]
                        auto value = strip(parts[1]);

                        // match parts[0] as key, assign values to the Map
                        switch (parts[0]) {
                            case "HPDrainRate":
                                map.difficulty.hpDrain = to!double(value);
                                break;
                            case "CircleSize":
                                map.difficulty.keys = to!int(value);
                                map.difficulty.circleSize = to!double(value);
                                break;
                            case "OverallDifficulty":
                                map.difficulty.accuracy = to!double(value);
                                break;
                            case "ApproachRate":
                                map.difficulty.approachRate = to!double(value);
                                break;
                            case "SliderMultiplier":
                                map.difficulty.sliderSpeed = to!double(value);
                                break;
                            case "SliderTickRate":
                                map.difficulty.sliderTickRate = to!double(value);
                                break;
                            default:
                                break;
                        }
                        break;

                    case Section.events:
                        // add storyboards later on, maybe not though
                        break;

                    case Section.timingPoints:
                        // split the line by separator
                        auto parts = lines[i].split(",");

                        if (parts.length != 8) {
                            writeln("osu! Timing Point is not 8 parts? Skipping...");
                            continue;
                        }

                        // populate a new TimingPoint
                        // https://osu.ppy.sh/wiki/en/osu%21_File_Formats/Osu_%28file_format%29#timing-points
                        auto tp = new TimingPoint();
                        tp.time = to!int(parts[0]);
                        bool isInherited = to!double(parts[1]) >= 0;
                        tp.beatDuration = isInherited ? to!double(parts[1]) : -1;           // rather -1 than uninitialized
                        tp.sliderSpeed = isInherited ? -1 : 100.0 / (-to!double(parts[1])); // rather -1 than uninitialized
                        tp.meter = to!int(parts[2]);
                        tp.volume = to!int(parts[5]) / 100.0;

                        // concatenation isn't super efficient, but there's no need to refactor.
                        timingPoints ~= [*tp];
                        break;

                    case Section.hitObjects:
                        auto parts = lines[i].split(",");
                        if (parts.length != 6) {
                            writeln("osu! Hit Object is not 6 parts? Skipping...");
                            continue;
                        }
                        auto ho = new HitObject();
                        ho.x = to!int(parts[0]) / 640.0; // conversion from osu!pixels to screen space
                        ho.y = to!int(parts[1]) / 480.0; // conversion from osu!pixels to screen space
                        ho.time = to!int(parts[2]);
                        ho.type = to!int(parts[3]);

                        // concatenation isn't super efficient, but there's no need to refactor.
                        hitObjects ~= [*ho];
                        break;

                    default:
                        break;
                }
            }
        }
    }
}
