SinOsc s => pTest p => dac;

440 => s.freq;
0.5 => s.gain;
0.1 => p.gain;

while(true){
	Math.random2f(100, 800) => s.freq;
	0.5::second => now;
}