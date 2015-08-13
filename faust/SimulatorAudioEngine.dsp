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
import("CitySkylineL.dsp");
import("CitySkylineR.dsp");
import("carParkL.dsp");
import("carParkR.dsp");

import("bicycleBell.dsp");
import("dogbark.dsp");
import("child.dsp");
import("clank.dsp");
import("cuckooBeeps.dsp");
import("RoadDrilling.dsp");

//#######################
// PARAMETERS
//#######################

engine_RPM = hslider("[2]VehRPM",1000,500,9000,0.01)+300 : smooth(0.999);
speed = hslider("[3]VehSpeedMPH",0,0,100,0.01) : smooth(0.999);
engine_randomness = hslider("h:[1]ownship/[0]engine_randomness[style:knob]",0.5,0,1,0.01); 
engine_turbulances = hslider("h:[1]ownship/[1]engine_turbulances[style:knob]",0.1,0,1,0.01);
engine_compression = hslider("h:[1]ownship/[2]engine_compression[style:knob]",0.6,0,1,0.01);
engine_brightness = hslider("h:[1]ownship/[3]engine_brightness[style:knob]",150,50,5000,1);
ownship_freq = hslider("h:[1]ownship/[4]cutoffFreq[style:knob]",300,50,3000,0.1);
engine_gain = hslider("h:[1]ownship/[5]engine_gain[style:knob]",1,0,1,0.01);
roadNoise_gain = hslider("h:[1]ownship/[6]roadNoise_gain[style:knob]",1,0,1,0.01);

simulator_bridge_gain = hslider("h:[0]gains/[0]simulator_bridge_gain[style:knob]",1,0,1,0.01);
ownshipToOutside_gain = hslider("h:[0]gains/[1]ownshipToOutside_gain[style:knob]",1.0,0,1,0.01);
ownshipToOwnship_gain = hslider("h:[0]gains/[2]ownshipToOwnship_gain[style:knob]",0.3,0,1,0.01);
ownshipToOwnshipSub_gain = hslider("h:[0]gains/[3]ownshipToOwnshipSub_gain[style:knob]",1,0,1,0.01);
sourcesToOutside_gain = hslider("h:[0]gains/[4]sourcesToOutside_gain[style:knob]",1,0,1,0.01);
sourcesToOwnship_gain = hslider("h:[0]gains/[5]sourcesToOwnship_gain[style:knob]",0.8,0,1,0.01);

countrySoundscape_gain = hslider("h:[4]SS/[0]countrySS_gain[style:knob]",0.02,0,1,0.01) : smooth(0.999);
citySoundscape_gain = hslider("h:[4]SS/[1]citySS_gain[style:knob]",0.02,0,1,0.01) : smooth(0.999);
carParkSoundscape_gain = hslider("h:[4]SS/[2]carPSS_gain[style:knob]",0.02,0,1,0.01) : smooth(0.999);

helicopter_gain = hslider("h:[5]SoundSources/[0]helicopter_gain[style:knob]",0.02,0,1,0.01);
emergency_gain = hslider("h:[5]SoundSources/[1]emergency_gain[style:knob]",0.02,0,1,0.01);

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
movCar(i) = movingCar(distance) : *(v) : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{		 
		v = hslider("h:car%i/v[style:knob]",0,0,60,0.01)/53.0 : smooth(0.999); // cc added velocity range 0 - 53m/s
		x = hslider("h:car%i/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:car%i/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		distance = 1-(sqrt(2) - sqrt(pow(x,2)+pow(y,2)))/sqrt(2);
};

// different spatialized sound sources
spatSound(0) = helicopter_0 , (%(SR*5) ~+(1) : int) : rdtable*helicopter_gain : sourceSpatInst(0);

// countryside soundscape
countryScape = (countrysideL_0, (%(295877) ~+(1) : int) : rdtable*0.05*countrySoundscape_gain), (countrysideR_0, (%(295877) ~+(1) : int) : rdtable*0.05*countrySoundscape_gain) : stereoToSoundScape;

// city soundscape
cityScape = (CitySkylineL_0, (%(992412) ~+(1) : int) : rdtable*0.4*citySoundscape_gain), (CitySkylineR_1, (%(192412) ~+(1) : int) : rdtable*0.4*citySoundscape_gain) : stereoToSoundScape;

// car park soundscape
carParkScape = (carParkL_0, (%(1166124) ~+(1) : int) : rdtable*0.5*carParkSoundscape_gain), (carParkR_1, (%(1166124) ~+(1) : int) : rdtable*0.5*carParkSoundscape_gain) : stereoToSoundScape;

// ambulance
ambul = ambulance_0 , (%(16944) ~+(1) : int) : rdtable*emergency_gain : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{	 
		x = hslider("h:ambulance/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:ambulance/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// bicycle
bicycle = bicycleBell_0 , ((min(35350)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:bicycle/on");	 
		x = hslider("h:bicycle/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:bicycle/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// dogbark
dogwoof = dogbark_0 , ((min(18350)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:dogbark/on");	 
		x = hslider("h:dogbark/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:dogbark/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// child
childtalk = child_0 , ((min(110350)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:child/on");	 
		x = hslider("h:child/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:child/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// clank
pipeclank = clank_0 , ((min(37350)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:clank/on");	
		//gain = button("h:clank/gain"); 
		x = hslider("h:clank/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:clank/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// beeping for pedestrian crossing
crosswalkbeep = cuckooBeeps_0 , ((min(1277768)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:crossw/on");	
		x = hslider("h:crossw/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:crossw/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};

// road construction noise
roadconstruction = RoadDrilling_0 , ((min(844009)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = button("h:roadc/on");	
		x = hslider("h:roadc/x[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
		y = hslider("h:roadc/y[style:knob]",30,-30,30,0.01)/30 : smooth(0.999);
};



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
	par(i,1,spatSound(i)),
	par(i,10,movCar(i)),
	ambul,
	bicycle,
	dogwoof,
	childtalk,
	pipeclank,
	crosswalkbeep,
	roadconstruction,
	countryScape,
	cityScape,
	carParkScape,
	ownshipSounds  
	:>
	outputPatch
);

process = audioEngine;






