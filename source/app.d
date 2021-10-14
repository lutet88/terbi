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
        InitWindow(720, 1280, "terbi");
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
            BeginDrawing();

            ClearBackground(Colors.BLACK);

            currentGame.update();

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
    Map m = parseFile("present.osu", "/home/lutet/lutetind/terbi/maps/izana/");
    writeln(m);
    app.loadMap(m);
    WindowBoundingBox w = WindowBoundingBox(20, 20, 700, 1260);

    KeyBindings kb = KeyBindings([
        //KeyboardKey.KEY_Z,
        KeyboardKey.KEY_X,
        KeyboardKey.KEY_C,
        KeyboardKey.KEY_COMMA,
        KeyboardKey.KEY_PERIOD,
        //KeyboardKey.KEY_SLASH
    ]);
    Game g = new SimpleManiaGame(m, w, kb);
    g.setOffset(60);
    app.loadGame(g);
    app.startGame();
    app.gameLoop();
}
