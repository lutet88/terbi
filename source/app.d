import std.stdio;
import raylib;

import terbi.map;
import terbi.parser;
import terbi.gameObjects;
import terbi.utils;
import terbi.game;
import terbi.games.simpleMania;


// currently Application is just template for SinglePlayer and Application
class Application {
    string settingsFileName;
    Map currentMap;
    Game currentGame;
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
    }

    void loadGame(Game g){
        currentGame = g;
    }

    void startGame(){
        currentGame.start();
    }

    void gameLoop(){
        scope (exit) stopRaylib();
        while (!WindowShouldClose()) {
            currentGame.update();

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
    writeln(m);
    app.loadMap(m);
    Game g = new SimpleManiaGame(m);
    app.loadGame(g);
    app.startGame();
    app.gameLoop();
}
