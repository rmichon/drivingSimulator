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

//#######################
// PARAMETERS
//#######################

RPM = hslider("VehRPM",500,10,10000,0.01) : smooth(0.999);
speed = hslider("VehSpeedMPH",0,0,100,0.01) : smooth(0.999);

//#######################
// DSP
//#######################

// Soon...

process = vgroup("audioEngine",roadNoise(speed)*2 + carEngine(1, RPM)*0.1);