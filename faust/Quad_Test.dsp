// Quad_Test.dsp
// CCRMA / CDR/ Renault Project
// 06/25/16
//
// This is a stripped down version of SimulatorAudioEngine.dsp, designed to
// compile only the audio icons and allow for quad recordings.


// CCRMA Sound Icons
import("car.lib");
import("Obstacle_1.dsp");
import("GetPassed_1.dsp");
import("Pass_1.dsp");
import("Takeover_1.dsp");
import("GiveBack_1.dsp");
import("SlowDown_1.dsp");
import("SpeedUp_1.dsp");

//#######################
// PARAMETERS
//#######################
audio_on = checkbox("[0]o");

//#######################
// DSP
//#######################

// Global gain on Meyer speakers
meyerGain = hslider("Meyer_Gain",0.05,0.0,1.0,0.01) : smooth(0.999);

// Obstacle Icon
obstacle_1 = Obstacle_1_0 , ((min(210432)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:o/o");
		x = hslider("h:o/x[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
		y = hslider("h:o/y[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
	};

// Passing Icons
getpassed_1 = GetPassed_1_0 , ((min(226816)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:gp/o");
		x = hslider("h:gp/x[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
		y = hslider("h:gp/y[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
	};

pass_1 = Pass_1_0 , ((min(235008)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:pa/o");
		x = hslider("h:pa/x[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
		y = hslider("h:pa/y[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
	};

// Transfer of control icons
takeover_1 = Takeover_1_0 , ((min(408064)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:to/o");
		x = hslider("h:to/x[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
		y = hslider("h:to/y[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
	};

giveback_1 = GiveBack_1_0 , ((min(387584)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:gb/o");
		x = hslider("h:gb/x[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
		y = hslider("h:gb/y[style:knob]",0,-25,25,0.01)/50 : smooth(0.999);
	};

// Traffic slowing down/speeding up icons
slowdown_1 = SlowDown_1_0 , ((min(230400)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:sd/o");
		x = hslider("h:sd/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:sd/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

speedup_1 = SpeedUp_1_0 , ((min(245760)*on) ~+(1) : int) : rdtable :  quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:su/o");
		x = hslider("h:su/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:su/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

// Meyer Internal Speakers
meyerOut =vgroup("meyerOut",
	obstacle_1,
	getpassed_1,
	pass_1,
	takeover_1,
	giveback_1,
	slowdown_1,
	speedup_1
	:>
	_,_,_,_
);

process = meyerOut;
