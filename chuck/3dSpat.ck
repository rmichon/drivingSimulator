// 3dSpat.ck
// CCRMA / CDR / Renault Project
// 07/17/15
//
// This Chuck program loops a wav file and allows the control
// of the position of the sound in 3D. It implements the doppler
// effect induced by moving the source, etc.
// This object relies on sSpat that can be found in the /faust
// folder.
// For now, only the left/right position can be controlled. The
// program starts at the center. To move to the left, press "q",
// to move to the right, press "w". 

// sound file
me.sourceDir() + "helicopter.wav" => string filename;
if( me.args() ) me.arg(0) => filename;

// the patch 
SndBuf buf => SourceSpat sSpat => dac;

// keyboard input
KBHit kb;

// load the file
filename => buf.read;

// get messages from the keyboard and control the position
fun void keybControl()
{
    0 => float position; // the position of the source (-1 1)
    0 => int keybChar; // the character pressed on the keyboard
    while(true){
        // wait on kbhit event
        kb => now;
        
        // potentially more than 1 key at a time
        while( kb.more() )
        {
            kb.getchar() => keybChar;
            if(keybChar == 113){ 
                position-0.01 => position;
                <<< "Position: ", position >>>;
            }
            else if(keybChar == 119){ 
                position+0.01 => position;
                <<< "Position: ", position >>>;
            }
            position => sSpat.position;
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