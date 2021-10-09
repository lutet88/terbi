module terbi.game;

import terbi.gameObjects;


abstract class Game {
    abstract void start();
    abstract GameObject[] update();
    abstract void setOffset(int offset);
}
