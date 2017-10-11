// ############################ Helper functions ##############################

// Shows slides. We're using jQuery here - the **$** is the jQuery selector function, which takes as input either a DOM element or a CSS selector string.
function showSlide(id) {
	// Hide all slides
	$(".slide").hide();
	// Show just the slide we want to show
	$("#"+id).show();
}

// Get random integers.
function randomInteger(n) {
	return Math.floor(Math.random()*n);
}


// Add a random selection function to all arrays (e.g., <code>[4,8,7].random()</code> could return 4, 8, or 7). This is useful for condition randomization.
Array.prototype.random = function() {
  return this[random(this.length)];
}

// shuffle function
function shuffle_mult() {
    var length0 = 0,
        length = arguments.length,
        i,
        j,
        rnd,
        tmp;

    for (i = 0; i < length; i += 1) {
        if ({}.toString.call(arguments[i]) !== "[object Array]") {
            throw new TypeError("Argument is not an array.");
        }

        if (i === 0) {
            length0 = arguments[0].length;
        }

        if (length0 !== arguments[i].length) {
            throw new RangeError("Array lengths do not match.");
        }
    }


    for (i = 0; i < length0; i += 1) {
        rnd = Math.floor(Math.random() * i);
        for (j = 0; j < length; j += 1) {
            tmp = arguments[j][i];
            arguments[j][i] = arguments[j][rnd];
            arguments[j][rnd] = tmp;
        }

        // ######################## Configuration settings ############################



allTrialOrders = [
      [1,3,2,5,4,9,8,7,6],
      [8,4,3,7,5,6,2,1,9] ]

myTrialOrder = randomElement(allTrialOrders),
var numTrialsExperiment = images.length;
var trials = [];



var experiment = {

	// The object to be submitted.
	data: {
		rating: [],
    	trial_type: [],
		sentence: [],
		ladder: [],
		age: [],
		gender: [],
		education: [],
		comments: [],
		ethnicity:[],
		race: [],
		children:[],
        childAgeYoung:[],
        childAgeOld:[],
        behaveAge: []
	},



	// end the experiment
	end: function() {
		showSlide("finished");
		setTimeout(function() {
			turk.submit(experiment.data)
		}, 1500);
	},
