
##################################
# Formant track (time-normalized) (March 2025)
# This script goes through all the files in a folder and writes in a txt the formant tracks of an interval than contains a vowel symbol.
#
#		REQUIREMENTS [INPUT]
#	A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
#	The format of the TextGrid must be: tier interval for each sound, the script will analyse only intervals with labels that have one of these symbols
#	a, e, i ,o ,u, ɪ, ɛ, æ, ɑ, ɔ, ʊ, ʌ, ɝ
		
#
#		INSTRUCTIONS 
#	1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
#	2. Set the parameters.
#		a) Folder where the files you want to analyse are
#		b) Name of the txt where the results will be saved
#		c) Data to optimise the formantic analysis
#
#		OUTPUT
#	The output is a tab separated txt file (can be dragged to Excel) with the following information in columns.
#		a) file name
#		b) number of the Interval in the Textgrid
#		c) label of the interval in the tier of the analysis: vowel
#		b) number of point of the track (this is the normalized time if you have chosen  the automatic time-step)
#		b) time when the data is measured
#		d) F0
#		e) F1
#		f) F2
#		h) F3
#		i) F4
#		j) durIntervalms
# 		h) intensity
#
#
# (c) Wendy Elvira García (2025) https://www.ub.edu/phoneticslaboratory/sites/wendyelvira/ 
# Laboratori de Fonètica (Universitat de Barcelona)
#
#################################

#########	FORM	###############


   form: "vowelFormants"
      sentence: "Folder", "C:\Users\labfonub99\Desktop\formant"
      comment: "the results file will be saved in the same folder your wax+Textgrids are"
       sentence: "txtName", "f_track"
	comment: "In which tier do you have the sound per sound segmentation with you vowels labelled?"
      natural: "tier", "1"
      comment: "-"
		
		comment: "You can set your own time-step or use the option for having normalized time (30 points by sound),"
		comment:  "you will also have the real original time in the results"
      choice: "time_step_type", 2
         option: "Manual"
         option: "Automatic_for_30_values_per_segment"
		comment: "Time step manual only used if set to manual"
       positive: "Time_step_manual", "0.02"
    
    comment: "You can change the Maximum formant to 5000 if you are working with deep voices (usually male)"
	integer: "Maximum_number_of_formants", "5"
	positive: "Maximum_formant", "5500"
	

   endform

#########	PREDEFINED VARIABLES FOR THE ANALYSIS	###############

window_length = 0.025
preemphasis_from= 50

#  Pitch analysis data
 pitchFloor = 75
 pitchCeiling = 600

#################################

#checks whether the file exists
if fileReadable(folder$ + "/" + txtName$ +".txt") = 1
	pause The file already exists. If you click continue it will be overwritten.
endif
echo 'folder$'

#writes interval in the output
writeFileLine: folder$ + "/"+ txtName$+ ".txt", "fileName", tab$ , "nInterval", tab$, "Label_interval", tab$,"n_point", tab$, "original_time", tab$, "F0", tab$, "F1", tab$, "F2", tab$, "F3", tab$, "F4", tab$, "duration", tab$, "intensity"


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

	
	#F0
	selectObject: mySound
	myPitch = To Pitch: 0, pitchFloor, pitchCeiling
	# intensity
	selectObject: mySound
	myIntensity = To Intensity: 100, 0, "yes"

	#formant created with 0.01 time-step, we will extract the real rime step later (this is preallocated to speed up the analysis)
	selectObject: mySound
	myFormant = To Formant (burg): 0.01, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from

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
			durIntervalms$ = fixed$(durIntervalms, 0)
			#change decimal marker for commas
			#durIntervalms$ = replace$ (durIntervalms$, ".", ",", 1)
						
			selectObject: myPitch
			f0 = Get value at time: midInterval, "Hertz", "Linear"
			f0$ = fixed$(f0, 0)
			
			
			if time_step_type = 1
				time_step = time_step_manual
			else 
				time_step = durInterval / 30
			endif

			nPoints = durInterval / time_step

			#look for formants
			
			myTime = 0
			for point to nPoints
				selectObject: myFormant
				time = startPoint+myTime
				f1 = Get value at time: 1, time, "Hertz", "Linear"
				f2 = Get value at time: 2, time, "Hertz", "Linear"
				f3 = Get value at time: 3, time, "Hertz", "Linear"
				f4 = Get value at time: 4, time, "Hertz", "Linear"
				f1$ = fixed$(f1, 0)
				f2$ = fixed$(f2, 0)
				f3$ = fixed$(f3, 0)
				f4$ = fixed$(f4, 0)
				selectObject: myIntensity
				int = Get value at time: time, "nearest"
				int$ = fixed$(int, 0)


				myTime = myTime + time_step
				# Save result to text file:
				appendFile: folder$ + "/"+ txtName$ + ".txt", base$, tab$, nInterval, tab$, labelOfInterval$, tab$
				appendFile: folder$ + "/"+ txtName$ + ".txt", point, tab$, time, tab$, f0$, tab$, f1$, tab$, f2$, tab$, f3$, tab$, f4$, tab$, durIntervalms$, tab$,  int$, newline$
			# end of loop for points	
			endfor
		endif
		#close interval loop
	# end of loop for intervals
	endfor
removeObject: myTextGrid, mySound, myPitch
#end of for files
endfor
removeObject: myList
	echo Done.

