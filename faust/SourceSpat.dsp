// SourceSpat.dsp
// CCRMA / CDR/ Renault Project
// 07/17/15
//
// Spatialize a source in 3D and add doppler effect in function of the distance
// of the source. 
// The position of the source can be controlled with parameters: angle, elevation
// and distance (0-1).

import("filter.lib");

nSpeakersR1 = 4; // number of speakers on ring 1 (ground)
nSpeakersR2 = 4; // number of speakers on ring 2 (air)

myAbs = _ <: _*(_ >= 0)+_*((_ < 0)*-1);

// simple doppler effect (feedforward filter)
doppler(pos) = _ <: _+fdelay2(32,L) : *(0.5)
with{
	MaxDel = 15*(SR/48000);
	L = MaxDel*(1-pos);
};

// one ring of speakers with "n" the number of speakers, "a" the angle (0-1) and "d" the distance (spread)
oneRing(n,a,d)	= _ <: par(i, n, *( scaler(i, n, a, d) : smooth(0.999)))
with {
	// channel scaling coefficient
	scaler(i,n,a,d) = (d/2.0+0.5)*sqrt(max(0.0, 1.0 - abs(fmod(a+0.5+float(n-i)/n, 1.0) - 0.5)*n*d));
};

// take the source and spatialize it
sourceSpat = 
	doppler(dis)*dis <: 
	(*(1-min(1,elevation)) : oneRing(nSpeakersR1, angle, spread)), // ground ring
	(*(elevation*(elevation <= 1) + (1-(elevation-1))*(elevation > 1)) : oneRing(nSpeakersR2, angle, spread)), // upper ring
	*(elevation/1.5) // top
	with{
		angle = hslider("angle", 0.0, 0, 1, 0.01);
		elevation = hslider("elevation",0,0,1,0.01)*1.5;
		dis	= hslider("distance", 0.5, 0, 1, 0.01);
		spread = dis*0.5+0.5;
	}
;

process = sourceSpat;

