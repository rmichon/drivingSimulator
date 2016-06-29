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
import("trainL.dsp");
import("trainR.dsp");

import("bicycleBell.dsp");
import("dogbark.dsp");
import("child.dsp");
import("clank.dsp");
import("cuckooBeeps.dsp");
import("RoadDrilling.dsp");
import("garbagetruck.dsp");
import("cows.dsp");
import("hammer.dsp");

import("pedwalk.dsp");
import("police.dsp");

// CCRMA Sound Icons
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
engine_RPM = hslider("[2]VR",500,500,9000,0.01)+300 : smooth(0.999);
speed = hslider("[3]VS",0,0,100,0.01) : smooth(0.999);
engine_randomness = hslider("h:[4]ownship/[0]engine_randomness[style:knob]",0.25,0,1,0.01); 
engine_turbulances = hslider("h:[4]ownship/[1]engine_turbulances[style:knob]",0.1,0,1,0.01);
engine_compression = hslider("h:[4]ownship/[2]engine_compression[style:knob]",0.6,0,1,0.01);
engine_brightness = hslider("h:[4]ownship/[3]engine_brightness[style:knob]",200,50,5000,1);
ownship_freq = hslider("h:[4]ownship/[4]cutoffFreq[style:knob]",500,50,3000,0.1);
engine_gain = hslider("h:[4]ownship/[5]engine_gain[style:knob]",1,0,1,0.01);
roadNoise_gain = hslider("h:[4]ownship/[6]roadNoise_gain[style:knob]",1,0,1,0.01);

simulator_bridge_gain = hslider("h:[1]gains/[0]simulator_bridge_gain[style:knob]",1,0,1,0.01);
ownshipToOutside_gain = hslider("h:[1]gains/[1]ownshipToOutside_gain[style:knob]",1.0,0,1,0.01);
ownshipToOwnship_gain = hslider("h:[1]gains/[2]ownshipToOwnship_gain[style:knob]",0.3,0,1,0.01);
ownshipToOwnshipSub_gain = hslider("h:[1]gains/[3]ownshipToOwnshipSub_gain[style:knob]",1,0,1,0.01);
sourcesToOutside_gain = hslider("h:[1]gains/[4]sourcesToOutside_gain[style:knob]",1,0,1,0.01);
sourcesToOwnship_gain = hslider("h:[1]gains/[5]sourcesToOwnship_gain[style:knob]",0.8,0,1,0.01);

countrySoundscape_gain = hslider("h:[6]S/[0]co[style:knob]",0.02,0,1,0.01) : smooth(0.999);
citySoundscape_gain = hslider("h:[6]S/[1]ci[style:knob]",0.02,0,1,0.01) : smooth(0.999);
carParkSoundscape_gain = hslider("h:[6]S/[2]ca[style:knob]",0.02,0,1,0.01) : smooth(0.999);
//farmSoundscape_gain = hslider("h:[6]SS/[3]farmSS_gain[style:knob]",0.02,0,1,0.01) : smooth(0.999);

helicopter_gain = hslider("h:[5]SoundSources/[0]helicopter_gain[style:knob]",1.0,0,1,0.01);
emergency_gain = hslider("h:[5]SoundSources/[1]emergency_gain[style:knob]",1.0,0,1,0.01);

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

reverb = _,_ <: (*(g)*fixedgain,*(g)*fixedgain : stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)), *(1-g), *(1-g) :> _,_ with{
	scaleroom   = 0.28;
	offsetroom  = 0.7;
	allpassfeed = 0.5;
	scaledamp   = 0.4;
	fixedgain   = 0.1;
	origSR = 44100;
	damping = hslider("h:rev/Damp[style: knob]",0.7, 0, 1, 0.025)*scaledamp*origSR/SR;
	combfeed = hslider("h:rev/RoomSize[style: knob]", 0.7, 0, 1, 0.025)*scaleroom*origSR/SR + offsetroom;
	spatSpread = hslider("h:rev/stereoSpread[style: knob]",0.5,0,1,0.01)*46*SR/origSR : int;
	g = hslider("h:rev/W[style: knob]", 0.0, 0, 1, 0.025) : smooth(0.999);
};

ambReverb = _,_ <: (*(g)*fixedgain,*(g)*fixedgain : stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)), *(1-g), *(1-g) :> _,_ with{
	scaleroom   = 0.28;
	offsetroom  = 0.7;
	allpassfeed = 0.5;
	scaledamp   = 0.4;
	fixedgain   = 0.1;
	origSR = 44100;
	damping = 0.3*scaledamp*origSR/SR;
	combfeed = 0.8*scaleroom*origSR/SR + offsetroom;
	spatSpread = 0.5*46*SR/origSR : int;
	g = 0.2;
};

// driver's car sounds
ownshipSounds =
		// car engine
		carEngine(engine_RPM,engine_randomness,engine_turbulances,engine_compression,engine_brightness)*engine_gain
		<: 
		(reverb <: par(i,4,*(ownshipToOutside_gain))), 
		par(i,6,0), 
		(roadNoise(speed)*roadNoise_gain*2 + _ <: // road noise only going to ownship
			(par(i,4,*(ownshipToOwnship_gain)), *(ownshipToOwnshipSub_gain)))
;

// abstraction of the source spatializer with "i" the iteration number
sourceSpatInst(i) = sourceSpatXYZ(x,y,z) : 
	par(i,10,*(sourcesToOutside_gain*on)), par(i,4,*(sourcesToOwnship_gain*on)), 0
	with{		
		on = checkbox("h:s%i/o");
		x = hslider("h:s%i/x[style:knob]",150,-150,150,0.01)/150 : smooth(0.999);
		y = hslider("h:s%i/y[style:knob]",150,-150,150,0.01)/150 : smooth(0.999);
		z = hslider("h:s%i/z[style:knob]",150,0,150,0.01)/150 : smooth(0.999);
};

// special case of the source spatilizer for a moving car
movCar(i) = movingCar(distance) : *(v) : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{		 
		v = hslider("h:c%i/v[style:knob]",0,0,60,0.01)/50.0+0.02;// : smooth(0.999); // cc added velocity range 0 - 50m/s
		x = hslider("h:c%i/x[style:knob]",50,-50,50,0.01)/50;// : smooth(0.999);
		y = hslider("h:c%i/y[style:knob]",50,-50,50,0.01)/50;// : smooth(0.999);
		distance = 1-(sqrt(2) - sqrt(pow(x,2)+pow(y,2)))/sqrt(2);
};

// different spatialized sound sources
spatSound(0) = helicopter_0 , (%(SR*5) ~+(1) : int) : rdtable*helicopter_gain*0.9: sourceSpatInst(0);

// countryside soundscape
countryScape = (countrysideL_0, (%(295877) ~+(1) : int) : rdtable*0.05*countrySoundscape_gain), (countrysideR_0, (%(295877) ~+(1) : int) : rdtable*0.05*countrySoundscape_gain) : stereoToSoundScape;

// farm soundscape
//farmScape = (countrysideL_0, (%(295877) ~+(1) : int) : rdtable*0.05*farmSoundscape_gain), (countrysideR_0, (%(295877) ~+(1) : int) : rdtable*0.05*farmSoundscape_gain) : stereoToSoundScape;

// city soundscape
cityScape = (CitySkylineL_0, (%(992412) ~+(1) : int) : rdtable*0.35*citySoundscape_gain), (CitySkylineR_1, (%(192412) ~+(1) : int) : rdtable*0.6*citySoundscape_gain) : stereoToSoundScape;

// car park soundscape
carParkScape = (carParkL_0, (%(1166124) ~+(1) : int) : rdtable*0.5*carParkSoundscape_gain), (carParkR_1, (%(1166124) ~+(1) : int) : rdtable*0.5*carParkSoundscape_gain) : stereoToSoundScape;

// ambulance
ambul = ambulance_0 , (%(16944) ~+(1) : int) : rdtable*emergency_gain*0.5*on <: ambReverb :> sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{	 
		x = hslider("h:a/x[style:knob]",150,-150,150,0.01)/150 : smooth(0.999);
		y = hslider("h:a/y[style:knob]",150,-150,150,0.01)/150 : smooth(0.999);
		on = checkbox("h:a/o");
};

// plane
plane_flying = plane_0 , (%(53082) ~+(1) : int) : rdtable*on : sourceSpatXYZ(x,y,z) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{ 
		on = checkbox("h:pl/o");
		x = hslider("h:pl/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:pl/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		z = hslider("h:pl/z[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// train
trains = (trainL_0, ((min(950289)*on) ~+(1) : int)  : rdtable*0.4), (trainR_0, ((min(950289)*on) ~+(1) : int)  : rdtable*0.4) : stereoToSoundScape 
	with{	 
		on = checkbox("h:t/o");
};

// bicycle
bicycle = bicycleBell_0 , ((min(53082)*on) ~+(1) : int) : rdtable*0.7 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:b/o");	 
		x = hslider("h:b/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:b/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};


// dogbark
dogwoof = dogbark_0 , ((min(26653)*on) ~+(1) : int) : rdtable*0.35 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:d/o");	 
		x = hslider("h:d/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:d/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// child
childtalk = child_0 , ((min(76590)*on) ~+(1) : int) : rdtable*0.6 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:c/o");	 
		x = hslider("h:c/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:c/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// clank
pipeclank = clank_0 , ((min(37350)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:cl/o");	
		//gain = checkbox("h:clank/gain"); 
		x = hslider("h:cl/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:cl/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// garbage truck
gtruck = garbagetruck_0 , ((min(549253)*on) ~+(1) : int) : rdtable*0.3 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:g/o");	
		//gain = checkbox("h:clank/gain"); 
		x = hslider("h:g/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:g/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// beeping for pedestrian crossing
crosswalkbeep = cuckooBeeps_0 , ((min(536458)*on) ~+(1) : int) : rdtable*0.20 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:cr/o");	
		x = hslider("h:cr/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:cr/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// road construction noise
roadconstruction = RoadDrilling_0 , ((min(844009)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:r/o");	
		x = hslider("h:r/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:r/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// building construction noise
bldgconstruction = hammer_0 , ((min(585747)*on) ~+(1) : int) : rdtable*1.5 : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:bc/o");	
		x = hslider("h:bc/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:bc/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// farm cattle noise
cattlesounds = cows_0 , ((min(1256849)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:f/o");	
		x = hslider("h:f/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:f/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};


// pedestrian walking and talking
pedwalk_s = pedwalk_0 , ((min(292570)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:p/o");	
		x = hslider("h:p/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:p/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// police car sound
woobwoob_s = police_0 , ((min(207137)*on) ~+(1) : int) : rdtable : sourceSpatXY(x,y) : 
	par(i,10,*(sourcesToOutside_gain)), par(i,4,*(sourcesToOwnship_gain)), 0
	with{
		on = checkbox("h:w/o");	
		x = hslider("h:w/x[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:w/y[style:knob]",50,-50,50,0.01)/50 : smooth(0.999);
};

// Global gain on Meyer speakers
meyerGain = hslider("Meyer_Gain",0.05,0.0,1.0,0.01) : smooth(0.999);

// Obstacle Icon
obstacle_1 = Obstacle_1_0 , ((min(210432)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:o/o");
		x = hslider("h:o/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:o/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

// Passing Icons
getpassed_1 = GetPassed_1_0 , ((min(226816)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:gp/o");
		x = hslider("h:gp/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:gp/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

pass_1 = Pass_1_0 , ((min(235008)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:pa/o");
		x = hslider("h:pa/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:pa/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

// Transfer of control icons
takeover_1 = Takeover_1_0 , ((min(408064)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:to/o");
		x = hslider("h:to/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:to/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
	};

giveback_1 = GiveBack_1_0 , ((min(387584)*on) ~+(1) : int) : rdtable : quadSpatXY(x,y) :
	par(i,4,*(meyerGain))
	with{
		on = checkbox("h:gb/o");
		x = hslider("h:gb/x[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
		y = hslider("h:gb/y[style:knob]",0,-50,50,0.01)/50 : smooth(0.999);
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

// car speakers output
ownshipOut = par(i,4,ownshipFilter	(ownship_freq)),ownshipSubFilter(90);

// routing the signals to the right channels
outputPatch(lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight,
carSub) = 
	lowFrontLeft,lowFrontRight,lowRearLeft,lowRearRight,lowFrontCenter,
	highFrontLeft,highFrontRight,highRearLeft,highRearRight,highCenter,
	ownshipOut(ownshipFrontLeft,ownshipFrontRight,ownshipRearLeft,ownshipRearRight,carSub);


// Audio Icons (meyer speakers)
meyerOut =
	obstacle_1,
	getpassed_1,
	pass_1,
	takeover_1,
	giveback_1,
	slowdown_1,
	speedup_1
	:>
	_,_,_,_
;

// putting things together
environmentOut = 
	// Driving environment sounds
	simulatorBridge,
	par(i,1,spatSound(i)),
	par(i,52,movCar(i)),
	ambul,
	bicycle,
	dogwoof,
	childtalk,
	pipeclank,
	gtruck,
	crosswalkbeep,
	roadconstruction,
	bldgconstruction,
	cattlesounds,
	trains,
	countryScape,
	cityScape,
	carParkScape,
	pedwalk_s,
	woobwoob_s,
	ownshipSounds  
	:>
	outputPatch
;

audioEngine = vgroup("audioEngine",
	environmentOut,
	0,
	meyerOut
);

process = audioEngine;
