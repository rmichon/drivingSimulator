// 3dSpat.ck
// CCRMA / CDR / Renault Project
// 07/17/15
//
// This Chuck program loops a wav file and allows the control
// of the position of the sound in 3D. It implements the doppler
// effect induced by moving the source, etc.
// This object relies on SourceSpat that can be found in the /faust
// folder.
// For now, the program can be controlled with the keyboard:
// 		- q/w: distance
//		- e/r: angle
//		- t/y: elevation

// sound file
me.sourceDir() + "/helicopter.wav" => string filename;
if( me.args() ) me.arg(0) => filename;

// the patch 
SndBuf buf => SourceSpat sSpat => blackhole;

// ground ring routing
sSpat.chan(0) => dac.chan(0);
sSpat.chan(0) => dac.chan(2);
sSpat.chan(1) => dac.chan(1);
sSpat.chan(1) => dac.chan(3);
sSpat.chan(2) => dac.chan(5);
sSpat.chan(2) => dac.chan(7);
sSpat.chan(3) => dac.chan(4);
sSpat.chan(3) => dac.chan(6);

// top ring routing
sSpat.chan(4) => dac.chan(8);
sSpat.chan(5) => dac.chan(9);
sSpat.chan(6) => dac.chan(13);
sSpat.chan(7) => dac.chan(12);

// top speaker
sSpat.chan(8) => dac.chan(14);

// keyboard input
KBHit kb;

// load the file
filename => buf.read;

// deffault value
0.3 => buf.gain;
0 => sSpat.angle;
0 => sSpat.elevation;
0 => sSpat.distance;

// get messages from the keyboard and control the position
fun void keybControl()
{
    0 => float distance; // the distance of the source (-1 1)
    0 => float angle; // the angle of the source (-1 1)
    0 => float elevation; // the elevation of the source (-1 1)
    0 => int keybChar; // the character pressed on the keyboard
    while(true){
        // wait on kbhit event
        kb => now;
        
        // potentially more than 1 key at a time
        while( kb.more() )
        {
            kb.getchar() => keybChar;
            //<<< keybChar >>>;
            if(keybChar == 113){ 
                if(distance > 0) distance-0.001 => distance;
                distance => sSpat.distance;
                <<< "Distance: ", distance >>>;
            }
            else if(keybChar == 119){ 
                if(distance < 1) distance+0.001 => distance;
                distance => sSpat.distance;
                <<< "Distance: ", distance >>>;
            }
            
            if(keybChar == 101){ 
                if(angle > 0) angle-0.001 => angle;
                angle => sSpat.angle;
                <<< "Angle: ", angle >>>;
            }
            else if(keybChar == 114){ 
                if(angle < 1) angle+0.001 => angle;
                angle => sSpat.angle;
                <<< "Angle: ", angle >>>;
            }
            
            if(keybChar == 116){ 
                if(elevation > 0) elevation-0.001 => elevation;
                elevation => sSpat.elevation;
                <<< "Elevation: ", elevation >>>;
            }
            else if(keybChar == 121){ 
                if(elevation < 1) elevation+0.001 => elevation;
                elevation => sSpat.elevation;
                <<< "Elevation: ", elevation >>>;
            }  
        }
    }
}

spork ~ keybControl();

// reset the wav file every 5 seconds
while( true )
{
    0 => buf.pos;
    5::second => now; 
}
