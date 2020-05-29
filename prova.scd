~song = Buffer.read(s, "D:/Download firefox/Pinguini_Tattici_Nucleari_Tetris.wav")

//EQUALIZER WITH SYNTHDEF

(
SynthDef(\song,
	{
	arg lowbound, highbound;
	var sig1, sige;
	sig1= PlayBuf.ar(2, ~song.bufnum, 1, doneAction:0);
	sige = BPeakEQ.ar(
    sig1,
    MouseX.kr(lowbound, highbound, \exponential), //FREQUENCY
    0.8, // rq
    MouseY.kr(-12.0, 12.0, \linear), //GAIN/BOOST
    0.5); // mul
	Out.ar(0, sige);
	}
).add;
)


~synth1 = Synth(\song,[\lowbound,250,\highbound,2000]);
(
var t2, t3, t4, t5, g2, g3, g4, g5, im, tl, tl2, tl3, tl4;
n = 0; //var for the song ID function
m = 1; //var for CHANGE SONG ID
p = 1; //var for Stop and Load EQ and Song
s = 0; //var for Resume
e = 0; //var for Play Song EQ model
x = 0; //var for Play Song LPF model
y = 0; //var for Play Song HPF model
q = 0; //var for Pause
l = 100;
h = 20000;
g = "Read what the Clip has to say!";
g2 = "20 - 20,000 Hz";
g3 = "";
g4 = "";
g5 = "Hi! Remember me? I`m Clippy... Back from the grave! I will be your assistant for today. To get this thing going move your LEFT HAND BACKWARDS";
~image = Image.new("C:/Users/ceci/Documents/CMLS/Homework3/CMLS-HW3-master/gesabs,jpg");
w = Window("KINECT EQ", Rect(800,500,500,500));
w.backgroundImage_(~image);


t = StaticText(w,Rect(200,410,200,50))
.font_(Font("Baskerville Old Face",20));//g1, Action
t2 = StaticText(w,Rect(200,330,200,50))
.font_(Font("Baskerville Old Face",20));//g2, Frequencies
t3 = StaticText(w,Rect(200,250,300,50))
.font_(Font("Baskerville Old Face",20)); //g3, song ID
t4 = StaticText(w,Rect(200,170,300,50))
.font_(Font("Baskerville Old Face",20)); //g4, Selected Mode
t5 = StaticText(w,Rect(160,20,300,100))
.font_(Font("Baskerville Old Face",15))
.background_(Color.grey(0.7,1.0))
.align=(\center); //g5, Clippy Dialogue
tl = StaticText(w,Rect(120,410,100,50))
.font_(Font("Baskerville Old Face",20, true))
.string_("Action:");
tl2 = StaticText(w,Rect(47,330,150,50))
.font_(Font("Baskerville Old Face",20,true))
.string_("Frequency Band:");
tl3 = StaticText(w,Rect(135,250,100,50))
.font_(Font("Baskerville Old Face",20,true))
.string_("Song:");
tl4 = StaticText(w,Rect(135,170,100,50))
.font_(Font("Baskerville Old Face",20,true))
.string_("Mode:");
//im = CompositeView(w, Rect(50,0,70,130)).backgroundImage_(~image);

r = Routine {
        {
            // Set the value of the StaticText to the value in the control bus.
            // Setting GUI values is asynchronous, so you must use .defer in the system clock.
            // Also you must check if the window is still open, since Routine will continue for at least
            // one step after you close the window.

                {
                    if(w.isClosed.not) {
                        t.string = g;
				        t2.string = g2;
				        t3.string = g3;
				        t4.string = g4;
				        t5.string = g5



                    }
                }.defer;

            0.01.wait;
        }.loop

    }.play;


w.front;

w.onClose_({CmdPeriod.run;});
)
)