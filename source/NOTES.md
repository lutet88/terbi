### TODO for today
- parser for osu files
-

### system
app.d           |> class Application (drives the whole app)

gameRenderer.d  |> class GameRenderer (takes some format and renders it)
                |> interface Game

mania.d         |> class ManiaGame : Game

timingEngine.d  |> class TimingEngine

map.d           |> class Map

mapPlayer.d     |> class MapPlayer

osuParser.d     |> Map parseOsuFile(string fileName) {...

### layers
Application
------------------
SinglePlayer | Multiplayer
---------------------------
Game
---------------------------



### flow

- app.d is launched, Application is created.
- load a GameRenderer into Application
- load a Game into the GameRenderer
- parseOsuFile a osu beatmap to a Map
- create a MapPlayer
- load that Map into the MapPlayer
- connect the MapPlayer with the Game
- MapPlayer.start() ---- sets MapPlayer's initTime to that time, then starts playing the music

game loop:
- MapPlayer.update()
- Game.update() -> calls MapPlayer.query()
- GameRenderer.render()


### GameObjects
need:
- rectangle
- circle/oval
- sprite

attr
- x
- y
- xsize
- ysize
- render method

### SimpleManiaGame
