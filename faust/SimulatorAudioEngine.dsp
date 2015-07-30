// audioEngine.dsp
// CCRMA / CDR/ Renault Project
// 07/24/15
//
// This Faust object is the "final product" that puts the different
// sound generators together. It receives the OSC messages from the
// simulator and sonifies them. The "parameters" section declares
// all the parameters of the system. 
// OSC addresses have the following shape: 
// /audioEngine/simulatorParamName value 

import("car.lib");
import("helicopter.dsp");
import("ambulance.dsp");
import("countrysideL.dsp");
import("countrysideR.dsp");
import("bicycleBell.dsp");

//#######################
// PARAMETERS
//#######################

engine_RPM = hslider("[2]VehRPM",1000,500,9000,0.01)+300 : smooth(0.999);
speed = hslider("[3]VehSpeedMPH",0,0,100,0.01) : smooth(0.999);
engine_randomness = hslider("h:[1]ownship/[0]engine_randomness[style:knob]",0.5,0,1,0.01); 
engine_turbulances = hslider("h:[1]ownship/[1]engine_turbulances[style:knob]",0.1,0,1,0.01);
engine_compression = hslider("h:[1]ownship/[2]engine_compression[style:knob]",0.6,0,1,0.01);
engine_brightness = hslider("h:[1]ownship/[3]engine_brightness[style:knob]",195,50,5000,1);
ownship_freq = hslider("h:[1]ownship/[4]cutoffFreq[style:knob]",300,50,3000,0.1);
engine_gain = hslider("h:[1]ownship/[5]engine_gain[style:knob]",0.9,0,1,0.01);
roadNoise_gain = hslider("h:[1]ownship/[6]roadNoise_gain[style:knob]",1,0,1,0.01);

simulator_bridge_gain = hslider("h:[0]gains/[0]simulator_bridge_gain[style:knob]",1,0,1,0.01);
ownshipToOutside_gain = hslider("h:[0]gains/[1]ownshipToOutside_gain[style:knob]",1.0,0,1,0.01);
ownshipToOwnship_gain = hslider("h:[0]gains/[2]ownshipToOwnship_gain[style:knob]",0.3,0,1,0.01);
ownshipToOwnshipSub_gain = hslider("h:[0]gains/[3]ownshipToOwnshipSub_gain[style:knob]",1,0,1,0.01);
sourcesToOutside_gain = hslider("h:[0]gains/[4]sourcesToOutside_gain[style:knob]",1,0,1,0.01);
sourcesToOwnship_gain = hslider("h:[0]gains/[5]sourcesToOwnship_gain[style:knob]",0.8,0,1,0.01);
sounscape_gain = hslider("h:[0]gains/[5]soundscape_gain[style:knob]",0.5,0,1,0.01);

//#######################
// DSP
//#######################

// takes the sound from the simulator and bridge it to the lower speakers
simulatorBridge(frontLeft,frontRight,rearLeft,rearRight,frontCenter,carSub) = 
	frontLeft*simulator_bridge_gain, 
	frontRight*simulator_bridge_gain,
	rearLeft*simulator_bridge_gain,
	rearRight*simulator_bridge_gain, 
	frontCenter*simulator_bridge_gain,
	par(i,5,0),
	frontLeft*simulator_bridge_gain, 
	frontRight*simulator_bridge_gain,
	rearLeft*simulator_bridge_gain,
	rearRight*simulator_bridge_gain, 
	carSub;

// driver's car sounds
ownshipSounds =
		// car engine
		carEngine(engine_RPM,engine_randomness,engine_turbulances,engine_compression,engine_brightness)*engine_gain
		<: 
		par(i,4,*(ownshipToOutside_gain)), 
		par(i,6,0), 
		(roadNoise(speed)*roadNoise_gain*2 + _ <: // road noise only going to ownship
			(par(i,4,*(ownshipToOwnship_gain)), *(ownshipToOwnshipSub_gain)))
;

// abstraction of the source spatializer with "i" the iteration number
sourceSpatInst(i) = sourceSpatXYZ(x,y,z) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{		 
		x = hslider("h:source%i/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:source%i/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		z = hslider("h:source%i/z[style:knob]",30,0,30,0.01)/30 : smooth(0.999);
};

// special case of the source spatilizer for a moving car
movCar(i) = movingCar(distance) : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{		 
		x = hslider("h:car%i/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:car%i/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		distance = 1-(sqrt(2) - sqrt(pow(x,2)+pow(y,2)))/sqrt(2);
};

// different spatialized sound sources
spatSound(0) = helicopter_0 , %(SR*5) ~+(1) : rdtable : sourceSpatInst(0);
spatSound(1) = ambulance_0 , %(16944) ~+(1) : rdtable : sourceSpatInst(1);
spatSound(2) = bicycleBell_0 , %(35350) ~+(1) : rdtable : sourceSpatInst(2);

// countryside soundscape
countryScape = (countrysideL_0, %(396706) ~+(1) : rdtable*sounscape_gain), (countrysideR_0, %(396706) ~+(1) : rdtable*sounscape_gain) : stereoToSoundScape;

// car speakers output
ownshipOut = par(i,4,ownshipFilter(ownship_freq)),ownshipSubFilter(90);

// routing the signals to the right channels
outputPatch(lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight,
carSub) = 
	lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,
	highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,
	ownshipOut(ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight,carSub);

// putting things together
audioEngine = vgroup("audioEngine",
	simulatorBridge,
	par(i,2,spatSound(i)),
	par(i,10,movCar(i)),
	countryScape,
	ownshipSounds  
	:>
	outputPatch
);

process = audioEngine;





