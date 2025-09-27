s.waitForBoot({
    // load buffer from one directory up
	var result;
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
		var path = thisProcess.nowExecutingPath.dirname +/+ "../media" +/+ "marine" +/+ result[0] +/+ result[1] ++ ".wav";
		path.postln;
	}.();


	});