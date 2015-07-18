//
import("music.lib");
import("filter.lib");

speed = hslider("speed",0,0,100,0.01)*0.01 : smooth(0.999);

process = noise : resonlp(90+speed*50,7,speed) <: _,_;
