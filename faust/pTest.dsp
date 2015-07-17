import("effect.lib");

gain = hslider("gain",1,0,1,0.01);

process = _ <: par(i,8,*(gain));	