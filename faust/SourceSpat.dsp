// SourceSpat.dsp
// CCRMA / CDR/ Renault Project
// 07/17/15
//
// Very simple source spatializer (only stereo for now). 
// The "position" parameter controls the position of the
// source relatively to the listener. It implements a "dirty"
// doppler effect...  

import("filter.lib");

position = hslider("position",0,-1,1,0.01) : smooth(0.999);

myAbs = _ <: _*(_ >= 0)+_*((_ < 0)*-1);
doppler = _ <: _+fdelay2(2048,L) : *(0.5)
with{
	L = 20*(myAbs(position));
};
panGain = position*0.5+0.5;
baseGain = 0.8;
distance = 1-myAbs(position)*baseGain;
pan = doppler*distance <: *(1-panGain),*(panGain);

process = pan;