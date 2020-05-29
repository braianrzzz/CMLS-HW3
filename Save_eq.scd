~song = Buffer.read(s, "/Users/Camillo/Desktop/Canz 10-03/Audio.wav")
//~song = Buffer.read(s, "/Users/Camillo/Desktop/CAAAANZ/Black Sabbath/The Ultimate Collection Disc 1/Audio.wav")

//EQUALIZER WITH SYNTHDEF

(
SynthDef(\song,
	{
	arg lowbound, highbound,lowboundb, highboundb,freq,boost;
	var sig1, sige;
	freq = MouseX.kr(lowbound, highbound, \exponential);
	boost = MouseY.kr(highboundb, lowboundb, \linear);
	sig1 = PlayBuf.ar(2, ~song.bufnum, 1, doneAction:0);
	sige = BPeakEQ.ar(
    sig1,
    freq, //FREQUENCY
    0.8, // rq
    boost, //GAIN/BOOST
    0.5); // mul
	Out.ar(0, sige);
	}
).add;
)


//starting the song and setting the parameters
(
~synth1 = Synth(\song,[\lowbound,250,\highbound,2000,\highboundb,12.0,\lowboundb,-12.0]);
~lowf = 250;
~highf = 2000;
)


//sending freq and boost values with two busses

~b= Bus.control(s,1);
~c= Bus.control(s,1);

{Out.kr(~b.index,  MouseX.kr(~lowf, ~highf, \exponential))}.play  //bus which sends the X position of the mouse (mapped as the frequency, infact lowf and highf are global variables that change with respect to the selected band (see the functions in the GUI))
{Out.kr(~c.index, MouseY.kr(12.0, -12.0, \linear))}.play  //bus which sends the Y position of the mouse (the boundaries are fixed because the boost is always mapped in the same way)





//GUI
(
var w, btnBass, btnMid, btnTreble, btnSave;
w = Window("My Window", Rect(100,100,250,200));

b = Bus.audio(s,1); // this will be our effects bus

btnBass = Button(parent:w, bounds:Rect(20, 160, 210, 30));
btnMid = Button(parent:w, bounds:Rect(10,10,100,100));
btnTreble = Button(parent:w, bounds:Rect(130,10,100,100));
btnSave = Button(parent:w, bounds:Rect(20,130,210, 30));

btnBass.string = "Bass";
btnMid.string = "Mid";
btnTreble.string = "Treble";
btnSave.string = "Save";

btnBass.action_({
	arg butt, mod;
	~lowf = 60;
	~highf = 250;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,60,\highbound,250,\highboundb,12.0,\lowboundb,-12.0);
});

btnMid.action_({
	arg butt, mod;
	~lowf = 250;
	~highf = 2000;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,250,\highbound,2000,\highboundb,12.0,\lowboundb,-12.0);
});

btnTreble.action_({
	arg butt, mod;
	~lowf = 2000;
	~highf = 20000;
	butt.value.asBoolean.not.postln;
	~synth1.set(\lowbound,2000,\highbound,20000,\highboundb,12.0,\lowboundb,-12.0);
});

btnSave.action_({
	arg butt, mod;
	~b.get({|val| var valuef; valuef=val; ~synth1.set(\lowbound,valuef,\highbound,valuef);}); //setting the value of the frequency as the last X position of the mouse (acquired when you hit the button)...for doing so we set the two boundaries coincident in order to have a unique value.
	~c.get({|val| var valueb; valueb=val;~synth1.set(\lowboundb,valueb,\highboundb,valueb);});//setting the value of the boost/cut as the last Y position of the mouse (works as the frequency)
	butt.value.asBoolean.not.postln;

});

w.front;

w.onClose_({CmdPeriod.run;});
)
