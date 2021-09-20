module terbi.games.simpleMania;

import std.stdio;
import raylib;

import terbi.game;
import terbi.map;
import terbi.utils;


class SimpleManiaGame : Game {
    MusicPlayer music;
    this(Map map) {
        music = new MusicPlayer(map.general.audioClip);
    }

    override void start() {
        music.play();
    }

    override void update() {
        music.update();
    }
}
