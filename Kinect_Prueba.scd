s.boot();

ServerOptions.outDevices;


Server.default.options.outDevice_("External Headphones");

~synapse = NetAddr.new("127.0.0.1", 12346);

//Calibrate hits
~synapse.sendMsg("/righthand_requiredlength", 20.0);
//Value MUST BE FLOAT! the bigger the number more distance needs to be cover to detect the hit
~synapse.sendMsg("/righthand_pointhistorysize", 60);
//Value MUST BE INT! the bigger the number the faster it detects the movement. Default value is 5



(
g = Group.new;


~trackRH = Task.new({
	{

~synapse.sendMsg("/righthand_trackjointpos", 3);
//Value 1 = Joint position relative to the torso
//Value 2 = World mode
//Value 3 = Pixels on Screen (X values from left to right 0 to 480, Y value from top to bottom 0 to to, Z stays the same as world mode)

		2.wait;
	}.loop;
}).play;


OSCdef.new(
	\trackRH,
	{
		arg msg;
		g.set(
			\freq, msg[1].linexp(0, 640, 100,3000).postln,
		\amp, msg[2].linlin(0, 480, 0, -40).postln.dbamp
	);
	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		msg.postln;
		if(
			msg[1] == \forward,
			{g.set(\gate, 0)}
		);
		if(
			msg[1] == \back,
			{
				{
					arg freq=440, gate=1, amp=0;
					var sig;
					sig = PinkNoise.ar(1!2);
					sig = BPF.ar(sig, freq.lag(0.05), 0.3);
					sig = sig * amp;
					sig = sig * EnvGen.kr(Env.adsr(0.05,0,1,0.05,1,1), gate, doneAction:2);
				}.play(g);
			}
		);

	},
	'/righthand',
	nil,
	12345
);
)




(
OSCdef.freeAll;
~trackRH.stop;
)