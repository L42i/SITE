s.waitForBoot({
    // load buffer one directory up
    var path = thisProcess.nowExecutingPath.dirname +/+ "../base.wav";
    ~forestBuffer = Buffer.read(s, path);

    SynthDef(\forestLayerOne, {
        | buf, out = 0, pitchShiftAmount = 1, gain = 1 |

        var sound, pitched;

        // play stereo buffer (looping)
        sound = PlayBuf.ar(2, buf, loop: 1);

        // pitch shift (ratio: 1 = no change, 2 = octave up, 0.5 = octave down)
        pitched = PitchShift.ar(sound, windowSize: 0.2, pitchRatio: pitchShiftAmount);

        // output (scaled to prevent overload)
        Out.ar(out, pitched * gain);
    }).add;

    s.sync;

    // spawn synths (two channels if you want to spread them like before)
    ~forestLayerSynths = [0, 2].collect { |i|
        Synth(\forestLayerOne, [
            \buf, ~forestBuffer,
            \out, i,
            \pitchShiftAmount, 2,   // no shift by default
            \gain, 1
        ])
    };
});
