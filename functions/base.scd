s.waitForBoot({
    var path = thisProcess.nowExecutingPath.dirname +/+ "base.wav";

    ~song = Buffer.read(s, path);

    // MONO
    SynthDef(\song_player_mono, { |out=0, buf=0, rate=1, startpos=0, amp=1, lpfFreq=16000|
        var sig = PlayBuf.ar(
            1, buf,
            rate * BufRateScale.kr(buf),
            trig: 1,
            startPos: startpos * BufFrames.kr(buf),
            loop: 0,
            doneAction: 2
        );
        sig = LPF.ar(sig, lpfFreq);
        Out.ar(out, sig * amp ! 2); // duplicate to stereo output
    }).add;

    // STEREO
    SynthDef(\song_player_stereo, { |out=0, buf=0, rate=1, startpos=0, amp=1, lpfFreq=16000|
        var sig = PlayBuf.ar(
            2, buf,
            rate * BufRateScale.kr(buf),
            trig: 1,
            startPos: startpos * BufFrames.kr(buf),
            loop: 0,
            doneAction: 2
        );
        sig = LPF.ar(sig, lpfFreq);
        Out.ar(out, sig * amp);
    }).add;

    s.sync;

    // Choose the correct instrument based on the loaded buffer
    ~songInstr = { if(~song.numChannels == 1) { \song_player_mono } { \song_player_stereo } };

    // Ableton Link clock
    ~shared_CLOCK = LinkClock(1).latency_(Server.default.latency);
    ~shared_CLOCK.tempo = 4.13;
    ~shared_CLOCK.latency = 0.0;

    // Loop the full song in sync; re-trigger on bar boundaries
    Pbindef(\songLoop,
        \instrument, Pfunc { ~songInstr.() },
        \buf,        Pfunc { ~song.bufnum },
        \amp,        1.0,
        \rate,       1.0,
        \startpos,   0.0,
        \dur,        Pfunc { ~song.duration / ~shared_CLOCK.beatDur }
    ).play(~shared_CLOCK, quant: 4);
});
