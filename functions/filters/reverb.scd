s.waitForBoot({
    // load buffer from one directory up
    var path = thisProcess.nowExecutingPath.dirname +/+ "../base.wav";
    ~sampleLayerBuffer = Buffer.read(s, path);

    // spatial / FX layer synth
    SynthDef(\spaceLayer3, {
        | buf
        , out = 0
        , delayTime = 0.5
        , feedback = 0.5
        , reverbMix = 0.3
        , roomSize = 0.5
        , damping = 0.5
        , distortionAmount = 10
        , gain = 1 |

        var sound, delayedSound, combinedSound, reverb, output, distorted;

        // play stereo file in loop
        sound = PlayBuf.ar(2, buf, loop: 1);

        // simple delay with feedback
        delayedSound = DelayN.ar(sound, delayTime, delayTime) * feedback;
        combinedSound = sound + delayedSound;

        // reverb
        reverb = FreeVerb.ar(combinedSound, roomSize, damping, reverbMix);

        // gain stage
        output = reverb * gain;

        // soft clipping distortion
        distorted = Clip.ar(output * distortionAmount, -1, 1);

        // send out (attenuated)
        Out.ar(out, distorted * 0.1);
    }).add;

    s.sync;

    // spawn synths on outputs 0 and 2 (for stereo pairs)
    ~spaceLayerSynths = [0, 2].collect { |i|
        Synth(\spaceLayer3, [
            \buf, ~sampleLayerBuffer,
            \out, i
        ])
    };
});
