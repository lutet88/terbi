module terbi.parser;

import std.stdio;
import std.file;

import terbi.map;


class Parser {



    abstract void parse(File f);
    abstract Map createMap();
}
