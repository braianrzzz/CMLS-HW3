s.boot();
(
~synapse = NetAddr.new("127.0.0.1", 12346);

~songs = Array.new;
~folder = PathName.new("/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/Songs for EQ/");

(
~folder.entries.do({
	arg path;
	~songs = ~songs.add(Buffer.read(s, path.fullPath));
});
)
)

(
var track, i2, s2, s3, t2, t3, t4, t5, g2, g3, g4, g5, im, tl, tl2, tl3, tl4;
track = 0; //var for tracking hands
n = 0; //var for the song ID function
m = 1; //var for CHANGE SONG ID
p = 1; //var for Stop and Load EQ and Song
s = 0; //var for Resume
e = 0; //var for Play Song EQ model
x = 0; //var for Play Song LPF model
y = 0; //var for Play Song HPF model
q = 0; //var for Pause
i2 = 0; //var for save EQ parameters 1
s2 = 0; //var to add i2 + 1 for saving another EQ parameters
s3 = 0; //var to control the head banging
l = 100;
h = 20000;
g = "Read what the Clip has to say!";
g2 = "20 - 20,000 Hz";
g3 = "";
g4 = "";
g5 = "Hi! Remember me? I`m Clippy... Back from the grave! I will be your assistant for today. To get this thing going move your LEFT HAND BACKWARDS";
w = Window("CLIPPY IN THE SPACE WITH DIAMONDS", Rect(800,500,500,500));
~image = Image.new("/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/Images/Clippy space.png");
~imageb = Image.new("/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/space.jpg");

v = CompositeView(w, 500@500).backgroundImage_(~imageb);

t = StaticText(w,Rect(200,410,200,50))
    .stringColor_(Color.white)
	.font_(Font("Baskerville Old Face",20));//g1, Action
t2 = StaticText(w,Rect(200,330,200,50))
.stringColor_(Color.white)
.font_(Font("Baskerville Old Face",20));//g2, Frequencies
t3 = StaticText(w,Rect(200,250,300,50))
.stringColor_(Color.white)
.font_(Font("Baskerville Old Face",20)); //g3, song ID
t4 = StaticText(w,Rect(200,170,300,50))
.font_(Font("Baskerville Old Face",20))
.stringColor_(Color.white); //g4, Selected Mode
t5 = StaticText(w,Rect(160,30,300,100))
.font_(Font("Baskerville Old Face",15))
.background_(Color.cyan(0.5,0.5))
.stringColor_(Color.white)
.align=(\center); //g5, Clippy Dialogue
tl = StaticText(w,Rect(120,410,100,50))
.font_(Font("Baskerville Old Face",20, true))
.stringColor_(Color.white)
.string_("Action:");
tl2 = StaticText(w,Rect(30,330,160,50))
.font_(Font("Baskerville Old Face",20,true))
.stringColor_(Color.white)
.string_("Frequency Band:");
tl3 = StaticText(w,Rect(135,250,150,50))
.font_(Font("Baskerville Old Face",20,true))
.stringColor_(Color.white)
.string_("Song:");
tl4 = StaticText(w,Rect(135,170,100,50))
.font_(Font("Baskerville Old Face",20,true))
.stringColor_(Color.white)
.string_("Mode:");
im = CompositeView(w, Rect(30,0,85,150)).backgroundImage_(~image);




~trackHands = Task.new({
	{

~synapse.sendMsg("/lefthand_trackjointpos", 3);
~synapse.sendMsg("/righthand_trackjointpos", 3);
//Value 1 = Joint position relative to the torso
//Value 2 = World mode
//Value 3 = Pixels on Screen (X values from left to right 0 to 480, Y value from top to bottom 0 to to, Z stays the same as world mode)

		2.wait;
	}.loop;
}).play;


OSCdef.new(
	\trackRHpos,
	{
		arg msg;
		if(track == 0,
			{

			o.set(\freq, msg[1].linexp(0, 640, l, h));
			o.set(\db, msg[2].linlin(0, 480, 10.0, -30.0));
		~freq21 = msg[1].linexp(0, 640, l, h);
		~db21 = msg[2].linlin(0, 480, 10.0, -30.0);
		});

	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackLHpos,
	{
		arg msg;
		if(track == 0,
			{

			o.set(\rq, msg[2].linlin(0, 480, 10.0, 0.4));
		~rq21 = msg[2].linlin(0, 480, 10.0, 0.4);
		});
	},
	'/lefthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackLHhit,
	{
		arg msg;
		if(
			msg[1] == \forward && q == 1, //Pause the song
			{
				g = "PAUSE";
				g5 = "To resume the song, just move your RIGHT HAND FORWARD.                                  Is '" ++ ~songs[n].path.copySeries(133,134,~songs[n].path.size - 5) ++ "' too boring for you? Try moving your RIGHT HAND DOWN";
				i2.postln;
				s2.postln;
				o.set(\t_trig, 1);
				s = 1;

			}
		);
		if(
			msg[1] == \down, //Change bounds parameters to Low Frequencies
			{
				g2 = "20 - 250 Hz";
				l = 20;
				h = 250;
			}
		);
		if(
			msg[1] == \left, //Change bounds parameters to Mid Frequencies
			{
				g2 = "250 - 2,000 Hz";
				l = 250;
				h = 2000;
			}
		);
		if(
			msg[1] == \up, //Change bounds parameters to High Frequencies
			{
				g2 = "2,000 - 20,000";
				l = 2000;
				h = 20000;
			}
		);
		if(
			msg[1] == \right, //Include all the Low-Mid-High Frequencies
			{
				g2 = "20 - 20,000 Hz";
				l = 20;
				h = 20000;
			}
		);
		if(
			msg[1] == \back && p == 1, //Load the song and EQ mode
			{
				(
					SynthDef.new(\songEQ, {
						arg freq, db, t_trig, rq, f1, rq1, db1, f2, rq2, db2;
						var sig1, sige, sige2, sige3, sigen, env;
					    p = 0;
						e = 1;
						g = "LOAD EQ MODE";
						g4 = "Equalizer";
						g5 = "You just load a song with the EQ Mode, now move your RIGHT HAND FORWARD to play it!";
						g3 = ~songs[n].path.copySeries(133,134,~songs[n].path.size - 5);
						sig1= PlayBuf.ar(2, ~songs[n].bufnum, 1, doneAction:0);
						sige = BPeakEQ.ar(sig1, f1, rq1, db1, 0.5);
						sige2 = BPeakEQ.ar(sige, f2, rq2, db2, 0.5);
						sige3 = BPeakEQ.ar(sige2, freq, rq, db, 0.5);
						env = EnvGen.kr(Env([0, 1, 1, 0], [2, ~songs[n].duration-1,1]));
						sigen = sige3 * env;
						PauseSelf.kr(t_trig);
						Out.ar(0, sigen);
					}).add;
				)
			}
		);
	},
	'/lefthand',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		if(
			msg[1] == \forward && s == 1, //Resume Song after Paused
			{
				g = "PLAY";
				g5 = "HEY! YOU! Remember that in Equalizer mode you have 3 EQ bands! Move your HEAD FORWARD to access them";
				o.run;
				s = 0;
				q = 1;
			}
		);
		if(
			msg[1] == \forward && e == 1, //Create Synth and play Song for model EQ
			{
				g = "PLAY";
				g5 = "Yes! Do you feel the power son? Remember if you want to PAUSE, move your LEFT HAND FORWARD";
				o = Synth.new(\songEQ, [\freq, \db, \t_trig]);
				o.set(\f1, 25000, \db1, 0, \rq1, 0);
				o.set(\f2, 25000, \db2, 0, \rq2, 0);
				i2.postln;
				s2.postln;
				e = 0;
				q = 1;
				s3 = 1;
			}
		);
		if(
			msg[1] == \forward && x == 1, //Create Synth and play Song for model LPF
			{
				g = "PLAY";
				g5 = "Yeah! Do you feel that bass? If you want to STOP just move your RIGHT HAND BACKWARDS";
				o = Synth.new(\songLPF, [\freq, \db, \t_trig]);
				x = 0;
				q = 1;
				s3 = 0;
			}
		);
		if(
			msg[1] == \forward && y == 1, //Create Synth and play Song for model HPF
			{
				g = "PLAY";
				g5 = "Remember to use your left hand to switch the frequency band! UP = High, DOWN = LOW, LEFT = MID & RIGHT = ALL";
				o = Synth.new(\songHPF, [\freq, \db, \t_trig]);
				y = 0;
				q = 1;
				s3 = 0;
			}
		);
		if(
			msg[1] == \back, //Stop song
			{
				track = 0;
				s2 = 0;
				i2 = 0;
				s = 0;
				g = "STOP";
				g4 = "";
				g5 = "Backwards eh? Now you can choose another mode and try with it!";
				o.free;
				p = 1;
				q = 0;
			}
		);
		if(
			msg[1] == \down, //Stop & change song
			{
				track = 0;
				s2 = 0;
				i2 = 0;
				s = 0;
				g = "CHANGE SONG";
				g3 = ~songs[m].path.copySeries(133,134,~songs[m].path.size - 5);
				g4 = "";
				g5 = "You got bored of that song eh? Take a look to into our inventory, it is A-MAAAAA-ZING. Remember to load a mode and PLAY";
				o.free;
				p = 1;
				q = 0;
				n = n + 1;
				m = m + 1;
				if (n == ~songs.size, {n = 0});
				if (m == ~songs.size, {m = 0});
			}
		);
		if(
			msg[1] == \right && p == 1, //Load song with LPF model
			{
				(
					SynthDef.new(\songLPF, {
						arg freq, db, t_trig, rq;
						var sig1, sige, sigen, env;
					    p = 0;
						x = 1;
						g = "LOAD LPF MODE";
						g4 = "Low Pass Filter";
						g3 = ~songs[n].path.copySeries(133,134,~songs[n].path.size - 5);
						g5 = "You just load a song with the LPF Mode. RIGHT HAND FORWARD to play it! and remember to experiment first in the high frequencies";
						sig1= PlayBuf.ar(2, ~songs[n].bufnum, 1, doneAction:0);
						sige = BLowPass.ar(sig1, freq, rq, 0.5);
						env = EnvGen.kr(Env([0, 1, 1, 0], [2, ~songs[n].duration-1,1]));
						sigen = sige * env;
						PauseSelf.kr(t_trig);
						Out.ar(0, sigen);
					}).add;
				)
			}
		);
		if(
			msg[1] == \left && p == 1, //Load song with HPF model
			{
				(
					SynthDef.new(\songHPF, {
						arg freq, db, t_trig, rq;
						var sig1, sige, sigen, env;
					    p = 0;
						y = 1;
						g = "LOAD HPF MODE";
						g4 = "High Pass Filter";
						g3 = ~songs[n].path.copySeries(133,134,~songs[n].path.size - 5);
						g5 = "You just load a song with the HPF Mode. RIGHT HAND FORWARD to play it! Take a look first in the low frequencies";
						sig1= PlayBuf.ar(2, ~songs[n].bufnum, 1, doneAction:0);
						sige = BHiPass.ar(sig1, freq, rq, 0.5);
						env = EnvGen.kr(Env([0, 1, 1, 0], [2, ~songs[n].duration-1,1]));
						sigen = sige * env;
						PauseSelf.kr(t_trig);
						Out.ar(0, sigen);
					}).add;
				)
			}
		);
	},
	'/righthand',
	nil,
	12345
);

OSCdef.new(
	\trackHEADhit,
	{

		arg msg;
		var f12, db12;
		if(msg[1] == \forward,
			{

				if(i2 == 0 && s3 == 1,
					{
					g = "SAVE EQ 1 PARAMETERS";
					g5 = "Awesome! you just save the parameters from the first EQ and now you are controlling a second EQ. Move your head forward again if you want a THIRD EQ!";
					o.set(\f1, ~freq21.value, \db1, ~db21.value, \rq1, ~rq21.value);
					s2 = 1;
				});

				if(i2 == 1 && s3 == 1,
					{
					g = "SAVE EQ 2 PARAMETERS";
					g5 = "BOOM! You have saved 2 EQ parameters and you controlled a third EQ. Now, I don`t want to be a party pooper but this is your last EQ. Move your HEAD FORWARD to save it as well";
					o.set(\f2, ~freq21.value, \db2, ~db21.value, \rq2, ~rq21.value);
					s2 = 2;
				});

				if(i2 == 2 && s3 == 1,
					{
						g = "SAVE EQ 3 PARAMETERS";
						g5 = "A'ight. You da man brow! I`m sure the song is sounding better than eva! If you want to start over move your RIGHT HAND BACKWARDS to stop it.";
					o.set(\freq, ~freq21.value, \db, ~db21.value, \rq, ~rq21.value);
					s2 = 3;
					s3 = 0;
				});
		})
		},
	'/head',
	nil,
	12345
);


r = Routine {
        {
            // Set the value of the StaticText to the value in the control bus.
            // Setting GUI values is asynchronous, so you must use .defer in the system clock.
            // Also you must check if the window is still open, since Routine will continue for at least
            // one step after you close the window.

                {
			if (s2 == 1,
			{
				i2 = i2 + 1;
				s2 = 0;
            });
			if (s2 == 2,
			{
				i2 = i2 + 1;
				s2 = 0;
            });
			if (s2 == 3,
			{
				i2 = i2 + 1;
				track = 1;
				s2 = 42;
            });
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

