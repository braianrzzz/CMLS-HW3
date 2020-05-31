//~song = Buffer.read(s, "/Users/Camillo/Desktop/Canz 10-03/Audio.wav")
~song = Buffer.read(s, "D:/Download firefox/Pinguini_Tattici_Nucleari_Tetris.wav")


~b=Bus.audio(s,1);

(
SynthDef(\song1,
	{
	|busOut|
	var sigl, sige;
	sigl= PlayBuf.ar(2, ~song.bufnum, 1, doneAction:0);
	OffsetOut.ar(busOut, sigl);
	}
).add;
)
//EQUALIZER WITH SYNTHDEF
~c=Bus.audio(s,2);

(
SynthDef(\song,
	{
	arg lowbound, highbound,busOut;
	var sig1, sige, sigl1;
	sig1= PlayBuf.ar(2, ~song.bufnum, 1, doneAction:0);
	sige = BPeakEQ.ar(
    sig1,
    MouseX.kr(lowbound, highbound, \exponential), //FREQUENCY
    0.8, // rq
    MouseY.kr(-12.0, 12.0, \linear), //GAIN/BOOST
    0.5);
	OffsetOut.ar(busOut, sige);
	}
).add;
)

//{Out.ar(c,Synth(\song,[\lowbound,250,\highbound,2000]))}

l=~song.path.length;
p=~song.path.copySeries(20,21,l);

(
SynthDef.new(\play,
	{
	|bus|
	var orland;
	orland=In.ar(bus: bus, numChannels: 2);
	Out.ar(0,orland);
	}
).play;
)



~c.play;
~b.play;

~synth2 = Synth(\song1,[\busOut,~b]);
~synth1 = Synth(\song,[\lowbound,250,\highbound,2000,\busOut,~c]);
~flixbus= Synth(\play,[\bus,~c]).moveAfter(~synth1);

/*( here we could change the x and y with the ones from Kinect, but I think it works only for LPF and HPF
z = {
Filter(LPF or HPF).ar(
    ,
    MouseX.kr(20, 20000, \exponential),
    0.8, // rq
    MouseY.kr(12.0, -12.0, \linear),
    0.5); // mul
}.scopeResponse;
)*/
LPF.scopeResponse //this is the response of a lpf, the next one shows the hpf
HPF.scopeResponse//only with mouse

{|in| MoogFF.ar(in, freq: MouseX.kr(250, 2000, \exponential),gain:MouseY.kr(-12.0, 12.0, \linear))}.scopeResponse

(
w=Window("Response", Rect(100,100,500,500));


f=FreqScopeView.response(w,Rect(50,50,700,700),~c,~b);
f=FreqScopeView(w,Rect(50,50,700,700),s);
f.active_(true);

w.onClose_({ f.kill }); // you must have this
w.front;
)

//GUI
/*(
var w, btnBass, btnMid, btnTreble, title;
w = Window("My Window", Rect(100,100,500,500));

b = Bus.audio(s,1); // this will be our effects bus


f=FreqScopeView(w,Rect(50,170,200,200));
f.active_(true);



btnBass = Button(parent:w, bounds:Rect(20, 160, 210, 30));
btnMid = Button(parent:w, bounds:Rect(10, 10, 100, 100));
btnTreble = Button(parent:w, bounds:Rect(130,10,100,100));
title = StaticText(parent:w,bounds:Rect(40,170,200,200));

//btnBass.string = "Bass";
//btnMid.string = "Mid";
//btnTreble.string = "Treble";
title.string=p;

btnBass.action_({
	arg butt, mod;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,60,\highbound,250);
});

btnMid.action_({
	arg butt, mod;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,250,\highbound,2000);
});

btnTreble.action_({
	arg butt, mod;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,2000,\highbound,20000);
});

w.front;

w.onClose_({CmdPeriod.run;});
)*/