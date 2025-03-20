
##################################
# F1 and F2 in new tiers v1 (2023)
# This script goes through all the files in a folder and writes adds F1 and F2 tiers to their TextGrid
#
#		REQUIREMENTS [INPUT]
#	A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
#	The format of the TextGrid must be: tier1 (word sentenc or whatever you like) for sounds; tier2 (interval) for vowels.
#	The script will write F1/F2 for all the intervals that contain a vowel symbol (listed form line 88 and forth).

#		INSTRUCTIONS 
#	1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
#	2. Set the parameters.
#		a) Folder where the files you want to analyse are
#		b) Data to optimise the formantic analysis
#
#		OUTPUT
#	The output is a modified TextGrid with two new point tiers with the F1 and F2 values. ALERT! it will modify your TextGrids, make a copy.
#		
#
# (c) Wendy Elvira García (2024) wen dy el vi  r a g a r c ia @ g m a i l. c o m 
# Laboratori de Fonètica (Universitat de Barcelona) https://www.ub.edu/phoneticslaboratory/
#
#################################

#########	FORM	###############

form Pausas vowelFormants
	sentence Folder /Users/weg/Library/CloudStorage/OneDrive-UniversitatdeBarcelona/_hacerahora/APP_Marcelo/0_corpus_repeticion/
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
tier =3

#checks whether the file exists

# index files for loop
# index files for loop
wav = Create Strings as file list: "myList", folder$ + "/" +"*.wav"
mp3 = Create Strings as file list: "myList", folder$ + "/" +"*.mp3"

selectObject: wav, mp3
myList= Append


nFiles = Get number of strings

#loops all files in folder
for file to nFiles
	selectObject: myList
	nameFile$ = Get string: file
	mySound = Read from file: folder$ + "/"+ nameFile$
	base$ = selected$("Sound")
	myTextGrid = Read from file: folder$ + "/"+ base$ + ".TextGrid"
	#base name
	myTextGrid$ = selected$("TextGrid")

	
	nOfIntervals = Get number of intervals: tier
	Convert to Unicode

	Insert point tier: 4, "F1"
	Insert point tier: 5, "F2"
	selectObject: mySound
	myFormant = To Formant (burg): time_step, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from
	
	#loops intervals
	nInterval=1
	for nInterval from 1 to nOfIntervals
		selectObject: myTextGrid
		labelOfInterval$ = Get label of interval: tier, nInterval
	
		#perform actions only for vowels
		if index(labelOfInterval$, "a")  <> 0 or 
		... index(labelOfInterval$, "e") <> 0 or 
		... index(labelOfInterval$, "ə") <> 0 or 
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
			

						
			#look for formants
			selectObject: myFormant

			
			f1 = Get value at time: 1, midInterval, "Hertz", "Linear"
			f2 = Get value at time: 2, midInterval, "Hertz", "Linear"
			
			f1$ = fixed$(f1,0)
			f2$ = fixed$(f2,0)


			selectObject: myTextGrid
			Insert point: 4, midInterval, f1$
			Insert point: 5, midInterval, f2$

			# Save the textgrid
			Save as text file: folder$ + "/"+ base$ + ".TextGrid"





		endif
		#close interval loop
	
	endfor
				removeObject: myFormant

	#close file loop
removeObject: myTextGrid
endfor
removeObject: myList
	echo Done.

