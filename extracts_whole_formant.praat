
##################################
# vowelFormants v1 (17 January 2017)
# This script goes through all the files in a folder and writes in a txt information about formants, duration, intensity and F0.
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
#	The output is a tab separated txt file (can be dragged to Excel) with the following information in columns.
#		a) file name
#		b) number of the Interval
#		c) label of the interval in the tier of the analysis: vowel
#		d) F0
#		e) F1
#		f) F2
#		h) F3
#		i) F4
#		j) durIntervalms
#		k) time of point
#
#
# (c) Wendy Elvira García (2017) wen dy el vi  r a g a r c ia @ g m a i l. c o m 
# Laboratori de Fonètica (Universitat de Barcelona) http://stel.ub.edu/labfon/en
#
#################################

#########	FORM	###############

form Pausas vowelFormants
	sentence Folder C:\Users\labfonub99\Desktop\formant
	sentence txtName results.txt
	comment In which tier do you have the sound per sound segmentation with you vowels labelled?
	integer tier 1
	comment _
	comment Data formantic analysis
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 5500
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

# index files for loop
myList = Create Strings as file list: "myList", folder$ + "/" +"*.wav"
nFiles = Get number of strings

#loops all files in folder
for file to nFiles
	selectObject: myList
	nameFile$ = Get string: file
	base$= nameFile$ -".wav"
	myTextGrid = Read from file: folder$ + "/"+ base$ + ".TextGrid"
	#base name
	myTextGrid$ = selected$("TextGrid")
	mySound = Read from file: folder$ + "/"+ myTextGrid$ + ".wav"
	selectObject: myTextGrid
	nOfIntervals = Get number of intervals: tier
	Convert to Unicode

	#writes interval in the output
	writeFileLine: folder$ + "/"+ base$+ ".txt", "fileName", tab$ , "nInterval", tab$, "Label interval", tab$, "F0", tab$, "F1", tab$, "F2", tab$, "F", tab$, "F4", tab$, "Duration", tab$, "time", tab$
			
	#F0
	selectObject: mySound
	myPitch = To Pitch: 0, pitchFloor, pitchCeiling

	#loops intervals
	nInterval=1
	for nInterval to nOfIntervals
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
			#durIntervalms$ = fixed$(durIntervalms, 5)
			#change decimal marker for commas
			#durIntervalms$ = replace$ (durIntervalms$, ".", ",", 1)
			
		
			
			
						
			selectObject: myPitch
			f0 = Get value at time: midInterval, "Hertz", "Linear"
			f0$ = fixed$(f0, 0)
			removeObject: myPitch
			
			#look for formants
			selectObject: mySound
			myFormant = To Formant (burg): time_step, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from
			nPoints= Get number of frames
			for point to nPoints
				selectObject: myFormant
				time = Get time from frame number: point
				f1 = Get value at time: 1, time, "Hertz", "Linear"
				f2 = Get value at time: 2, time, "Hertz", "Linear"
				f3 = Get value at time: 3, time, "Hertz", "Linear"
				f4 = Get value at time: 4, time, "Hertz", "Linear"
				f1$ = fixed$(f1, 0)
				f2$ = fixed$(f2, 0)
				f3$ = fixed$(f3, 0)
				f4$ = fixed$(f4, 0)
				# Save result to text file:
				appendFile: folder$ + "/"+ base$ + ".txt", base$, tab$, nInterval, tab$, labelOfInterval$, tab$
				appendFile: folder$ + "/"+ base$ + ".txt", f0$, tab$, f1$, tab$, f2$, tab$, f3$, tab$, f4$, tab$, durIntervalms, tab$, time, newline$
				
			endfor
			removeObject: myFormant
		endif
		#close interval loop
	
	endfor
	#close file loop
removeObject: myTextGrid, mySound
endfor
removeObject: myList
	echo Done.

