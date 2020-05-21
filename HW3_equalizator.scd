//~song = Buffer.read(s, "/Users/Camillo/Desktop/Canz 10-03/Audio.wav")
~song = Buffer.read(s, "/Users/Camillo/Desktop/CAAAANZ/Black Sabbath/The Ultimate Collection Disc 1/Audio.wav")

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
    MouseY.kr(12.0, -12.0, \linear), //GAIN/BOOST
    0.5); // mul
	Out.ar(0, sige);
	}
).add;
)


~synth1 = Synth(\song,[\lowbound,250,\highbound,2000]);





//GUI
(
var w, btnBass, btnMid, btnTreble;
w = Window("My Window", Rect(100,100,250,200));

b = Bus.audio(s,1); // this will be our effects bus

btnBass = Button(parent:w, bounds:Rect(20, 160, 210, 30));
btnMid = Button(parent:w, bounds:Rect(10,10,100,100));
btnTreble = Button(parent:w, bounds:Rect(130,10,100,100));

btnBass.string = "Bass";
btnMid.string = "Mid";
btnTreble.string = "Treble";

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
)