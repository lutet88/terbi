import std.stdio;
import raylib;

import terbi.map;
import terbi.enums;


class Application {
    string settingsFileName;
    this() {
        this.settingsFileName = "settings.yml";
    }

    void initRaylib(){
        // TODO: replace with settings
        SetTargetFPS(480);
        InitWindow(1280, 720, "terbi");
    }

    void gameLoop(){
        scope (exit) CloseWindow();
        while (!WindowShouldClose()) {
            BeginDrawing();
            ClearBackground(Colors.RAYWHITE);
            DrawText("terbi", 640-50, 360, 40, Colors.ORANGE);
            EndDrawing();
        }
    }
}

void main()
{
    Application app = new Application();
    app.initRaylib();
    app.gameLoop();
}
