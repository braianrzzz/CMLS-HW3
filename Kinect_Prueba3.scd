s.boot()

~synapse = NetAddr.new("127.0.0.1", 12346);

(
	~synth = Buffer.read(s, "/Users/dannydreamt/Documents/Native Instruments/Maschine/Samples/One Shots/Vocal/Vocal 1234 .wav");
	~ambient = Buffer.read(s, "/Users/dannydreamt/Documents/Native Instruments/Maschine/Samples/Instruments/Lead/Daft Samples/Daft a1.wav");

//"/Users/dannydreamt/Documents/Native Instruments/Maschine/Samples/One Shots/Vocal/Vocal 1234 .wav"

//"/Users/dannydreamt/Documents/Native Instruments/Maschine/Samples/Instruments/Lead/Daft Samples/Daft a1.wav"

//"/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/Ambience StillGlory.wav")

//"/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/JosiesSong c3.wav"

SynthDef.new(\grain, {
	arg buf=0, trnsp=0, spos=0, atk=0.01, sus=0.03, rel=0.01, pan=0, amp=1, out=0;
	var sig, env;
	sig = PlayBuf.ar(1,buf,BufRateScale.ir(buf)*trnsp.midiratio, startPos:spos, doneAction:2);
	sig = Pan2.ar(sig,pan,amp);
	env = EnvGen.kr(Env.new([0,1,1,0],[atk, sus, rel], [1, 0, -1]), doneAction:2);
	sig = sig * env;
	Out.ar(out, sig);
}).add;

SynthDef.new(\echo, {
	arg in, t_fxtrig = 0, out = 0;
	var sig, fx, mix;
	sig = In.ar(in, 2);
	fx = In.ar(in, 2);
	3.do{fx = CombL.ar(fx, 0.25, LFNoise1.kr(0.05).range(0.04, 0.25), 4, 0.65)};
	mix = EnvGen.kr(Env.new([-0.9, 0.75, -0.9],[0.1, 5], \lin), t_fxtrig);
	sig = XFade2.ar(sig, fx, mix);
	Out.ar(out,sig);
}).add;

~fxbus = Bus.audio(s, 2);
~grainGrp = Group.new;
~fxGrp = Group.after(~grainGrp);
)

(
~synthPat = Pbind(
	\instrument, \grain,
	\dur, Pdefn(\durSynth, 0.1),
	\buf, ~synth.bufnum,
	\sus, Pexprand(0.01, 0.1),
	\trnsp, Pdefn(\trnspSynth, Pwhite(0.0)),
	\spos, Pdefn(\sposSynth, 0),
	\pan, Pwhite(-1.0, 1.0),
	\amp, Pdefn(\ampSynth, 0.1),
	\group, ~grainGrp,
	\out, ~fxbus
);

~ambientPat = Pbind(
	\instrument, \grain,
	\dur, Pdefn(\durAmbient, 0.1),
	\buf, ~ambient.bufnum,
	\sus, Pexprand(0.01, 0.1),
	\trnsp, Pdefn(\trnspAmbient, Pwhite(0.0)),
	\spos, Pdefn(\sposAmbient, 0),
	\pan, Pwhite(-1.0, 1.0),
	\amp, Pdefn(\ampAmbient, 0.1),
	\group, ~grainGrp,
	\out, ~fxbus
);

Synth.new(\echo, [\in, ~fxbus, \out, 0], ~fxGrp);
)


(
~trackHands = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		~synapse.sendMsg("/lefthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackLHpos,
	{
		arg msg;
		msg.postln;
		Pdefn(\sposSynth, msg[1].linlin(0, 640, 0, ~synth.numFrames-1));
		Pdefn(\durSynth, msg[2].linexp(0,480,0.002,1.5));
		Pdefn(\ampSynth, Pexprand(msg[2].linlin(0, 480, -16, -36).dbamp, 0.25));
		Pdefn(\trnspSynth, Pwhite(msg[3].linlin(800,2500,0,-36),msg[3].linlin(800,2500,0,36)));
	},
	'/lefthand_pos_screen',
	nil,
	12345
);


OSCdef.new(
	\trackRHpos,
	{
		arg msg;
		Pdefn(\sposAmbient, msg[1].linlin(0, 640, 0, ~ambient.numFrames-1));
		Pdefn(\durAmbient, msg[2].linexp(0,480,0.002,1.5));
		Pdefn(\ampAmbient, Pexprand(msg[2].linlin(0, 480, -16, -36).dbamp, 0.25));
		Pdefn(\trnspAmbient, Pwhite(msg[3].linlin(800,2500,0,-36),msg[3].linlin(800,2500,0,36)));
	},
	'/righthand_pos_screen',
		nil,
		12345

);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		if(
			msg[1] == \forward,
			{~fxGrp.set(\t_fxtrig, 1)}
		);
	},
	'/righthand',
	nil,
	12345
);

OSCdef.new(
	\trackLHhit,
	{
		arg msg;
		if(
			msg[1] == \forward,
			{~fxGrp.set(\t_fxtrig, 1)}
		);
	},
	'/lefthand',
	nil,
	12345
);

)

(
~synthStream = ~synthPat.play;
~ambientStream = ~ambientPat.play;
)








		