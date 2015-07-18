//

import("oscillator.lib");
import("effect.lib");
import("filter.lib");

nPistons = 1;
RPM = hslider("RPM",1000,1000,5000,0.1) : smooth(0.999);

//piston = imptrain(freq) : lowpass(6,200*(RPM/1000)) : cubicnl(2,0)
piston = imptrain(freq) : resonlp(freq+10,3,1) : cubicnl(2,0) : ff_fcomb(512,6,1,1) 
with{
	baseFreq = 1000/60/nPistons;
	freq = RPM/60/nPistons;
};

process = piston <: _,_;
