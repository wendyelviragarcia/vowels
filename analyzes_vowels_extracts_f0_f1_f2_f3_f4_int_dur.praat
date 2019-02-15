
##################################
# vowelFormants v1 (17 January 2017)
# This script goes through all the files in a folder and writes in a txt informaition about formants, duration, intensity and F0.
#
#		REQUIREMENTS [INPUT]
#	A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
#	The format of the TextGrid must be: tier1 interval for each sound, the script will analyse only intervals with labels that have one of these symbols
#	a, e, i ,o ,u, ɪ, ɛ, æ, ɑ, ɔ, ʊ, ʌ, ɝ
		
#
#		INSTRUCTIONS 
#	1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
#	2. Set the parameters.
#		a) Folder where the files you want to analyse are
#		b) Name of the txt where the results will be saved
#		c) Data to optimise the formantic analysis
#		d) Data to optimise the pitch (F0) detection
#
#		OUTPUT
#	The output is a tab separated txt file (can be dragged to Excel, beware decimals are ".") with the following information in columns.
#		a) file name
#		b) number of the Interval
#		c) label of the interval in the tier of the analysis: vowel
#		d) F0
#		e) F1
#		f) F2
#		h) F3
#		i) F4
#		j) Duration of the vowel
#		k) Intensity of the vowel at its mid point
#
#
# (c) Wendy Elvira García (2017) wendyelvira-ga/contact
# Laboratori de Fonètica (Universitat de Barcelona) http://stel.ub.edu/labfon/en
#
#################################

#########	FORM	###############

form Pausas vowelFormants
	sentence Folder /Users/name/Desktop/data
	sentence txtName results.txt
	comment In which tier do you have the sound per sound segmentation with your vowels labelled?
	integer tier 1
	comment _
	comment Data formantic analysis
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 5500_(=adult female)
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50
	comment  _
	comment Pitch analysis data
	integer pitchFloor 75
	integer pitchCeiling 600
endform

#################################
#################################

# variables 

#checks whether the file exists
if fileReadable(folder$ + "/" + txtName$) = 1
	pause The file already exists. If you click continue it will be overwritten.
endif
echo 'folder$'
#creates the txt output with its fisrt line
writeFileLine: folder$ + "/"+ txtName$, "fileName", tab$ , "nInterval", tab$, "Label interval", tab$, "F0 [Hz]", tab$, "F1 [Hz]", tab$, "F2 [Hz]", tab$, "F3 [Hz]", tab$, "F4 [Hz]", tab$, "Duration[ms]", tab$, "Intensity [ms]", tab$

# index files for loop
myList = Create Strings as file list: "myList", folder$ + "/" +"*.TextGrid"
nFiles = Get number of strings
pause
#loops all files in folder
for file to nFiles
	selectObject: myList
	nameFile$ = Get string: file
	myTextGrid = Read from file: folder$ + "/"+ nameFile$
	#base name
	myTextGrid$ = selected$("TextGrid")
	mySound = Read from file: folder$ + "/"+ myTextGrid$ + ".wav"
	selectObject: myTextGrid
	nOfIntervals = Get number of intervals: tier
	Convert to Unicode
	
	#loops intervals
	nInterval=1
	for nInterval from 1 to nOfIntervals
		selectObject: myTextGrid
		labelOfInterval$ = Get label of interval: tier, nInterval
	
		#perform actions only for vowels
		if index(labelOfInterval$, "a")  <> 0 or 
		... index(labelOfInterval$, "e") <> 0 or 
		... index(labelOfInterval$, "i") <> 0 or 
		... index(labelOfInterval$, "o") <> 0 or 
		... index(labelOfInterval$, "u") <> 0 or 
		... index(labelOfInterval$, "ɪ") <> 0 or 
		... index(labelOfInterval$, "ɛ") <> 0 or 
		... index(labelOfInterval$, "æ") <> 0 or 
		... index(labelOfInterval$, "ɑ") <> 0 or 
		... index(labelOfInterval$, "ɔ") <> 0 or 
		... index(labelOfInterval$, "ʊ") <> 0 or 
		... index(labelOfInterval$, "ʌ") <> 0 or 
		... index(labelOfInterval$, "ɝ") <> 0
		
			#Gets time of the interval
			endPoint = Get end point: tier, nInterval
			startPoint = Get starting point: tier, nInterval
			durInterval = endPoint- startPoint
			midInterval = startPoint +(durInterval/2)
			durIntervalms = durInterval*1000
			#fix decimals
			durIntervalms$ = fixed$(durIntervalms, tier)
			#change decimal marker for commas
			durIntervalms$ = replace$ (durIntervalms$, ".", ",", 1)
			
			#looks for time aligned labels in other tiers
			
			
			#writes interval in the output
			appendFile: folder$ + "/"+ txtName$, myTextGrid$, tab$, nInterval, tab$, labelOfInterval$, tab$
						
			#F0
			selectObject: mySound
			myPitch = To Pitch: 0, pitchFloor, pitchCeiling
			f0 = Get value at time: midInterval, "Hertz", "Linear"
			f0$ = fixed$(f0, 0)
			removeObject: myPitch
			
			#look for formants
			selectObject: mySound
			myFormant = To Formant (burg): time_step, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from
			
			f1 = Get value at time: 1, midInterval, "Hertz", "Linear"
			f2 = Get value at time: 2, midInterval, "Hertz", "Linear"
			f3 = Get value at time: 3, midInterval, "Hertz", "Linear"
			f4 = Get value at time: 4, midInterval, "Hertz", "Linear"
			f1$ = fixed$(f1, 0)
			f2$ = fixed$(f2, 0)
			f3$ = fixed$(f3, 0)
			f4$ = fixed$(f4, 0)
			# Save result to text file:
			appendFile: folder$ + "/"+ txtName$, f0$, tab$, f1$, tab$, f2$, tab$, f3$, tab$, f4$, tab$
			removeObject: myFormant
			
			# look for intensity
			selectObject: mySound
			myIntensity = To Intensity: 500, 0, "yes"
			midInt = Get value at time: midInterval, "Cubic"
			midInt$ = fixed$(midInt,0)
			appendFileLine: folder$ + "/"+ txtName$, durIntervalms$, tab$, midInt$
			removeObject: myIntensity
		endif
		#close interval loop
	
	endfor
	#close file loop
removeObject: myTextGrid, mySound
endfor
removeObject: myList
	echo Done.

