// audioEngine.dsp
// CCRMA / CDR/ Renault Project
// 07/20/15
//
// This Faust object is the "final product" that puts the different
// sound generators together. It receives the OSC messages from the
// simulator and sonifies them. The "parameters" section declares
// all the parameters of the system. 
// OSC addresses have the following shape: 
// /audioEngine/simulatorParamName value 

import("car.lib");
import("helicopter.dsp");

//#######################
// PARAMETERS
//#######################

engine_RPM = hslider("[0]VehRPM",1000,500,9000,0.01)+300;
speed = hslider("[1]VehSpeedMPH",0,0,100,0.01);
engine_randomness = hslider("h:ownship/engine_randomness[style:knob]",0.5,0,1,0.01); 
engine_turbulances = hslider("h:ownship/engine_turbulances[style:knob]",0.1,0,1,0.01);
engine_compression = hslider("h:ownship/engine_compression[style:knob]",0.8,0,1,0.01);
engine_brightness = hslider("h:ownship/engine_brightness[style:knob]",400,50,5000,1);
engine_gain = hslider("h:ownship/engine_gain[style:knob]",0.8,0,1,0.01);
roadNoise_gain = hslider("h:ownship/roadNoise_gain[style:knob]",1,0,1,0.01);
ownship_freq = hslider("h:ownship/cutoffFreq[style:knob]",300,50,3000,0.1);
simulator_bridge_gain = hslider("simulator_bridge_gain",1,0,1,0.01);

//#######################
// DSP
//#######################

// takes the sound from the simulator and bridge it to the lower speakers
simulatorBridge(frontLeft,frontRight,rearLeft,rearRight,frontCenter) = 
	frontLeft*simulator_bridge_gain,frontRight*simulator_bridge_gain,rearLeft*simulator_bridge_gain,rearRight*simulator_bridge_gain,par(i,5,0),frontCenter*simulator_bridge_gain,par(i,4,0);

// driver's car sounds
ownshipSounds =
		par(i,10,0), // dead channels
		// car engine
		(carEngine(engine_RPM,engine_randomness,engine_turbulances,engine_compression,engine_brightness)*engine_gain,
		// road noise
		roadNoise(speed)*roadNoise_gain
		// splitting to the 4 ownship speakers
		:> _ <: _,_,_,_)
;

// abstraction of the source spatializer with "i" the iteration number
sourceSpatInst(i) = sourceSpat(angle,elevation,distance)
with{
	angle = hslider("h:source%i/angle[style:knob]", 0.0, 0, 1, 0.01);
	elevation = hslider("h:source%i/elevation[style:knob]",0,0,1,0.01);
	distance = hslider("h:source%i/distance[style:knob]", 0.5, 0, 1, 0.01);
};

// different spatialized sound sources
spatSound(0) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(0);
spatSound(1) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(1);
spatSound(2) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(2);
spatSound(3) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(3);
spatSound(4) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(4);

// car speakers output
ownshipOut = par(i,4,ownshipFilter(ownship_freq));

// routing the signals to the right channels
outputPatch(lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight) = 
	lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,
	ownshipOut(ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight);

// putting things together
audioEngine = vgroup("audioEngine",
	simulatorBridge,
	par(i,5,spatSound(i)),
	ownshipSounds  
	:>
	outputPatch
);

process = audioEngine;





