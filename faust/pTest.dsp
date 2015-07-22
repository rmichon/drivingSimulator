import("music.lib");
import("helicopter.dsp");

helic = helicopter_0 , %(SR*5) ~+(1) : rdtable;

process = helic : component("SourceSpat.dsp");
