import std.stdio;
import raylib;

import terbi.map;
import terbi.enums;
import terbi.parser;
import terbi.gameObjects;
import terbi.utils;


class Application {
    string settingsFileName;
    Map currentMap;
    bool mapPlaying = false;

    this() {
        this.settingsFileName = "settings.yml";
    }

    void initRaylib(){
        // TODO: replace with settings
        SetTargetFPS(480);
        InitWindow(1280, 720, "terbi");
        InitAudioDevice();
    }

    void loadMap(Map m){
        currentMap = m;
        mapPlaying = true;
        SetMusicVolume(m.general.audioClip, 0.4);
        PlayMusicStream(m.general.audioClip);
    }

    void gameLoop(){
        scope (exit) stopRaylib();
        while (!WindowShouldClose()) {
            if (mapPlaying) UpdateMusicStream(currentMap.general.audioClip);

            BeginDrawing();
            ClearBackground(Colors.RAYWHITE);
            DrawText("terbi", 640-50, 360, 40, Colors.ORANGE);
            EndDrawing();
        }
    }

    void stopRaylib(){
        CloseAudioDevice();
        CloseWindow();
    }
}

void main()
{
    Application app = new Application();
    app.initRaylib();
    Map m = parseFile("hd.osu", "/home/lutet/lutetind/terbi/testmap/");
    writeln("printing map: ");
    writeln(m);
    app.loadMap(m);
    app.gameLoop();
}
