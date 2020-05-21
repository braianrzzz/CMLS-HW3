s.boot()
(
	~synth = Buffer.read(s, "/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/JosiesSong c3.wav");
	~ambient = Buffer.read(s, "/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/Ambience StillGlory.wav");

//"/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/WK 11/Madonna - Lucky Star.wav"

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
	\dur, Pexprand(0.01, 0.2),
	\buf, ~synth.bufnum,
	\sus, Pexprand(0.01, 0.1),
	\trnsp, Pwhite(-3.0, 3.0),
	\spos, Pwhite(0, ~synth.numFrames-1),
	\pan, Pwhite(-1.0, 1.0),
	\amp, Pexprand(0.05, 0.2),
	\group, ~grainGrp,
	\out, ~fxbus
);

~ambientPat = Pbind(
	\instrument, \grain,
	\dur, Pexprand(0.01, 0.2),
	\buf, ~ambient.bufnum,
	\sus, Pexprand(0.01, 0.1),
	\trnsp, Pwhite(-3.0, 3.0),
	\spos, Pwhite(0, ~ambient.numFrames-1),
	\pan, Pwhite(-1.0, 1.0),
	\amp, Pexprand(0.1, 0.25),
	\group, ~grainGrp,
	\out, ~fxbus
);

Synth.new(\echo, [\in, ~fxbus, \out, 0], ~fxGrp);
)

(
~synthStream = ~synthPat.play;
~ambientStream = ~ambientPat.play;

~fxGrp.set(\t_fxtrig, 1);
)


	