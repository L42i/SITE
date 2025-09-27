//RUN LOCAL AUDIO SERVER
s.waitForBoot({
	//STEP 2: RECEIVER
	{
		//8 = 1, 10 = 2, 11 = 3, 12 = 4
		~host = "";
		~peer = "";
		~absolute = thisProcess.nowExecutingPath.dirname;

		if(("hostname".unixCmdGetStdOut).contains("student8"))
		{
			~host = "1";
			~peer = "2";
		};
		if(("hostname".unixCmdGetStdOut).contains("student10"))
		{
			~host = "2";
			~peer = "3";
		};
		if(("hostname".unixCmdGetStdOut).contains("student11"))
		{
			~host = "3";
			~peer = "4";
		};
		if(("hostname".unixCmdGetStdOut).contains("student12"))
		{
			~host = "4";
			~peer = "5";
		};
		if(("hostname".unixCmdGetStdOut).contains("zs-MacBook-Pro-6.local"))
		{
			~host = "5";
			~peer = "1";
		};

		fork {
			p = P2PSC();
			p.sync;
			p.setName(~host); // set your name accordingly
			p.sync;

			p.addPath({ |msg|
				var sleeptime = 2;
				var freq = 200;
				var newPattern = (msg[1].asString).drop(1);
				var soundFile = ~absolute +/+ msg[2].asString;

				fork {
					2.wait;
					//newPattern.postln;
					~peer = newPattern[0];
					//soundFile.postln;

				Buffer.read(s, soundFile, action: { |b| ~sampleLayerBuffer = b; [0, 2].do { |i| { Out.ar(i, PlayBuf.ar(2, b, rate: 1, loop: 0)) }.play } });


					//{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
					if(newPattern != "")
					{

						msg.postln;


						p.sendMsg("/"++~peer++"/ping" , newPattern, msg[2]);
					};
				};
			},"/ping");
		};
	}.();

	{3.0.wait;}.();

	//THIRD FUNCTION
	{
		var result;
		var soundFile;
		if(("hostname".unixCmdGetStdOut).contains("zs-MacBook-Pro-6.local"))
					{





			{

				~pickWordAndNumber = {
					var word, number;

					// pick word with weighted probability
					word = if (1.0.rand < 0.8) { "soundmark" } { "signal" };

					// pick number between 0 and 3, equal distribution
					number = 4.rand;  // gives 0,1,2,3 equally



					// also return them if you want to use later
					[word, number]
				};

				result = ~pickWordAndNumber.value;

				result[0].postln;
				result[1].postln;

			}.();

			{
				soundFile = "../media" +/+ "marine" +/+ result[0] +/+ result[1] ++ ".wav";
				soundFile.postln;
				s.sync;
			}.();




		~randomChoice = {
			var choice = [0,1].choose;

			if (choice==0, {
				"Ordered".postln;
				{

						fork {
							var peer, peers, pattern;
							peers = p.getPeers();

							if (peers.size > 0,
								{
									pattern = "1234";

									//{SinOsc.ar(freq:1000)*0.5*EnvGen.kr(Env.perc(releaseTime:1-0.01), doneAction:2)}.play;


									p.sendMsg("/"++~peer++"/ping" , pattern, soundFile);
								},
								{"Error: No other peers in the network".postln;}
							);
						};

				}.value; // Need to evaluate the function
			}, {
				"Rand".postln;
				{
					~generateRandomPattern = {
						var patternLength = rrand(3, 6);
							var possiblePeers = ["1", "2", "3", "4", "5"];
						var newPattern = "";
						var lastChar = "";

						patternLength.do {
							var availablePeers = possiblePeers.reject { |peer| peer == lastChar };
							var nextChar = availablePeers.choose;

							newPattern = newPattern ++ nextChar;
							lastChar = nextChar;
						};

						("Generated random pattern: " ++ newPattern).postln;
						//^newPattern;
						//{SinOsc.ar(freq:1000)*0.5*EnvGen.kr(Env.perc(releaseTime:1-0.01), doneAction:2)}.play;
~soundFile.postln;
							p.sendMsg("/"++~peer++"/ping" , newPattern, soundFile);
					};

					// Test it
					~generateRandomPattern.();
				}.value; // Need to evaluate the function
			});
		};

		// Call the random choice function
		~randomChoice.();

	}
	}.();
});