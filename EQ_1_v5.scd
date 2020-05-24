s.boot();

~synapse = NetAddr.new("127.0.0.1", 12346);

~songs = Array.new;
~folder = PathName.new("/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/Songs for EQ/");

(
~folder.entries.do({
	arg path;
	~songs = ~songs.add(Buffer.read(s, path.fullPath));
});
)


(

g = Group.new;
n = 0; //var for the song ID function
p = 1; //var for Stop and Load EQ and Song
s = 0; //var for Pause
e = 0; //var for Play Song EQ model
x = 0; //var for Play Song LPF model
y = 0; //var for Play Song HPF model
l = 100;
h = 20000;
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
		//g.set(
			o.set(\freq, msg[1].linexp(0, 640, l, h));
			o.set(\db, msg[2].linlin(0, 480, 10.0, -30.0));

		//);
	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackLHpos,
	{
		arg msg;
		//g.set(
			o.set(\rq, msg[2].linlin(0, 480, 10.0, 0.4));

		//);
	},
	'/lefthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackLHhit,
	{
		arg msg, m1, m2, m3, m4, m5, m6;
		if(
			msg[1] == \forward, //Pause the song
			{
				m1 = {"PAUSE".postln};
				m1.value;
				o.set(\t_trig, 1);
				s = 1;

			}
		);
		if(
			msg[1] == \down, //Change bounds parameters to Low Frequencies
			{
				m2 = {"LOW Band Frequencies".postln};
				m2.value;
				l = 20;
				h = 250;
			}
		);
		if(
			msg[1] == \left, //Change bounds parameters to Mid Frequencies
			{
				m3 = {"MID Band Frequencies".postln};
				m3.value;
				l = 250;
				h = 2000;
			}
		);
		if(
			msg[1] == \up, //Change bounds parameters to High Frequencies
			{
				m4 = {"HIGH Band Frequencies".postln};
				m4.value;
				l = 2000;
				h = 20000;
			}
		);
		if(
			msg[1] == \right, //Include all the Low-Mid-High Frequencies
			{
				m5 = {"All Frequencies".postln};
				m5.value;
				l = 20;
				h = 20000;
			}
		);
		if(
			msg[1] == \back && p == 1, //Load the song and EQ mode
			{
				(
					m6 = {"Load EQ mode".postln};
					m6.value;
					SynthDef.new(\songEQ, {
						arg freq, db, t_trig, rq;
						var sig1, sige, sigen, env;
					    p = 0;
						e = 1;
						sig1= PlayBuf.ar(2, ~songs[n].bufnum, 1, doneAction:0);
						sige = BPeakEQ.ar(sig1, freq, rq, db, 0.5);
						env = EnvGen.kr(Env([0, 1, 1, 0], [2, ~songs[n].duration-1,1]));
						sigen = sige * env;
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
		arg msg, m7, m8, m9, m10, m11, m12, m13;
		if(
			msg[1] == \forward && s == 1, //Resume Song after Paused
			{
				m7 = {"Resume".postln};
				m7.value;
				o.run;
				s = 0;
			}
		);
		if(
			msg[1] == \forward && e == 1, //Create Synth and play Song for model EQ
			{
				m8 = {"Play EQ".postln};
				m8.value;
				o = Synth.new(\songEQ, [\freq, \db, \t_trig]);
				e = 0;
			}
		);
		if(
			msg[1] == \forward && x == 1, //Create Synth and play Song for model LPF
			{
				m9 = {"Play LPF".postln};
				m9.value;
				o = Synth.new(\songLPF, [\freq, \db, \t_trig]);
				x = 0;
			}
		);
		if(
			msg[1] == \forward && y == 1, //Create Synth and play Song for model HPF
			{
				m10 = {"Play HPF".postln};
				m10.value;
				o = Synth.new(\songHPF, [\freq, \db, \t_trig]);
				y = 0;
			}
		);
		if(
			msg[1] == \back, //Stop song
			{
				m11 = {"STOP".postln};
				m11.value;
				o.free;
				p = 1;
			}
		);
		if(
			msg[1] == \down, //Stop & change song
			{
				m11 = {"Stop & Change Song".postln};
				m11.value;
				o.free;
				p = 1;
				n = n + 1;
			}
		);
		if(
			msg[1] == \right && p == 1, //Load song with LPF model
			{
				(
					m12 = {"Load LPF mode".postln};
					m12.value;
					SynthDef.new(\songLPF, {
						arg freq, db, t_trig, rq;
						var sig1, sige, sigen, env;
					    p = 0;
						x = 1;
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
					m13 = {"Load HPF mode".postln};
					m13.value;
					SynthDef.new(\songHPF, {
						arg freq, db, t_trig, rq;
						var sig1, sige, sigen, env;
					    p = 0;
						y = 1;
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

)



