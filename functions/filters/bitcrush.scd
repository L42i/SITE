// no s.meter();

s.waitForBoot({
    {
        // NOTE: Changing s.options.sampleRate after boot has no effect.
        // Leave as-is unless you plan to set it *before* s.boot.
        s.options.sampleRate = 48000;
    }.();

    {
		var path = thisProcess.nowExecutingPath.dirname +/+ "../base.wav";
        ~sampleLayerBuffer = Buffer.read(s, path);
    }.();

    {
        SynthDef(\sampleLayer, {
            | buf, out = 0, volume = 1, pitchRatio = 1, infVerb = 0, lpfFreq = 20000,
              bitcrushOn = 1, bitcrushRate = 1000, bitcrushBits = 24 |  // <-- defaults set here
            var sound, finalSound, reverb, filtered, bitcrushed;

            // stereo file assumed; if mono, change first arg to 1 and do !2 at the end
            sound = PlayBuf.ar(2, buf, loop: 1);
            finalSound = PitchShift.ar(sound, 0.2, pitchRatio, 0.0, 0.0, 1.0, 0.0);
            filtered = LPF.ar(finalSound, lpfFreq);

            // Native bitcrush (always available; defaults: ON, 1000 Hz)
            bitcrushed = if(bitcrushOn > 0, {
                var downsample = Latch.ar(filtered, Impulse.ar(bitcrushRate)); // SR reduction
                var bitreduce  = downsample.round(0.5 ** bitcrushBits);       // bit reduction
                bitreduce
            }, {
                filtered
            });

            reverb = FreeVerb.ar(bitcrushed, infVerb, infVerb, 0.3);
            Out.ar(out, reverb * volume);
        }).add;
    }.();

    {
        s.sync;

        // start immediately, bitcrush ON @ 1000 Hz by default
        ~sampleLayerSynths = [0, 2].collect { |i|
            Synth(\sampleLayer, [
                \buf, ~sampleLayerBuffer,    // you can also pass ~sampleLayerBuffer.bufnum
                \out, i
                // no GUI; defaults handle bitcrush
            ])
        };

        // If you ever want to tweak from code (no GUI), use:
        // ~sampleLayerSynths.do(_.set(\bitcrushOn, 1, \bitcrushRate, 1000, \bitcrushBits, 16));
        // ~sampleLayerSynths.do(_.set(\bitcrushOn, 0)); // bypass
    }.();
});
