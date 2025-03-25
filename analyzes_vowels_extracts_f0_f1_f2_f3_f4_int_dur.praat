
##################################
# vowelFormants v1 (17 January 2017)
# This script goes through all the files in a folder and writes in a txt information about formants, duration, intensity and F0.
#
#		REQUIREMENTS [INPUT]
#	A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
#	The format of the TextGrid must be: tier1 interval for each sound, the script will analyse only intervals with labels that have one of these symbols
#	a, e, i ,o ,u, ɪ, ɛ, æ, ɑ, ɔ, ʊ, ʌ, ɝ. You can add more or remove them at line 100.
		
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
#	The output is a tab separated txt file (can be dragged to Excel, beware decimals are "." you can change that uncommenting like 118) with the following information in columns.
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
	comment Where do you have your wavs and TextGrids?
	sentence Folder /Users/name/Desktop/data
	comment Type of loop
	choice: "Iterative", 2
          option: "Only files"
          option: "Folders and files" 
	comment Name of output (it will be saved in the same folder whre your wavs are)
	sentence txtName results.txt
	comment In which tier do you have the by-sound segmentation with your vowels labelled?
	integer tier 1
	comment _
	comment Data formantic analysis
comment Do you want to extract data from the mid point 
comment or the mean from centered 50% of the vowel?
	choice: "Extraction", 1
          option: "From mid point"
          option: "Mean from mid 50% of the vowel" 

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
writeFileLine: folder$ + "/"+ txtName$, "Folder", tab$ , "Filename", tab$ ,"nInterval", tab$, "Label_interval", tab$, "F0", tab$, "F1", tab$, "F2", tab$, "F3", tab$, "F4", tab$, "Start_point", tab$, "Duration_ms", tab$, "Intensity_dB"

if iterative = 2
	myListFolders = Create Strings as folder list: "myFolders", folder$ + "/"
	nFolders = Get number of strings

		if nFolders = 0
			nFolders = 1
		endif
	#loops all files in folder

else 
		nFolders = 1
endif



for subfolder to nFolders
	if iterative = 2
		selectObject: myListFolders
		subfolder$ = Get string: subfolder
		
		path$ = folder$ + subfolder$
	else
		path$ = folder$
		subfolder$= folder$

	endif

# index files for loop
myList = Create Strings as file list: "myList", path$ + "/" +"*.TextGrid"
nFiles = Get number of strings

#loops all files in folder
for file to nFiles
	selectObject: myList
	nameFile$ = Get string: file
	myTextGrid = Read from file: path$ + "/"+ nameFile$
	#base name
	myTextGrid$ = selected$("TextGrid")
	mySound = Read from file: path$ + "/"+ myTextGrid$ + ".wav"
	selectObject: myTextGrid
	nOfIntervals = Get number of intervals: tier
	Convert to Unicode
	
	selectObject: mySound
	myFormant = To Formant (burg): time_step, maximum_number_of_formants, maximum_formant, window_length, preemphasis_from
	selectObject: mySound
	myIntensity = To Intensity: 500, 0, "yes"

	#F0
	selectObject: mySound
	myPitch = To Pitch: 0, pitchFloor, pitchCeiling

	#loops intervals
	nInterval=1
	for nInterval from 1 to nOfIntervals
		selectObject: myTextGrid
		labelOfInterval$ = Get label of interval: tier, nInterval
	
		#perform actions only for vowels
		# IPA and SAMPA if there are not overlappings
		if index_regex(labelOfInterval$, "[aeiouɪɛæɑɔʊʌəAEIOU@]")  <> 0

		#if index(labelOfInterval$, "a")  <> 0 or 
		#... index(labelOfInterval$, "e") <> 0 or 
		#... index(labelOfInterval$, "i") <> 0 or 
		#... index(labelOfInterval$, "o") <> 0 or 
		#... index(labelOfInterval$, "u") <> 0 or 
		#... index(labelOfInterval$, "ɪ") <> 0 or 
		#... index(labelOfInterval$, "ɛ") <> 0 or 
		#... index(labelOfInterval$, "æ") <> 0 or 
		#... index(labelOfInterval$, "ɑ") <> 0 or 
		#... index(labelOfInterval$, "ɔ") <> 0 or 
		#... index(labelOfInterval$, "ʊ") <> 0 or 
		#... index(labelOfInterval$, "ʌ") <> 0 or 
		#... index(labelOfInterval$, "ə") <> 0
		
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


			
			
			#writes interval in the output
			appendFile: folder$ + "/"+ txtName$, subfolder$, tab$, myTextGrid$, tab$, nInterval, tab$, labelOfInterval$, tab$
						
			
			selectObject: myPitch
			f0 = Get value at time: midInterval, "Hertz", "Linear"
			
			
			if extraction = 2
				margin = durInterval * 0.5 / 2
				f0 = Get mean: startPoint+margin, endPoint-margin, "Hertz"
			endif
			
			f0$ = fixed$(f0, 0)
			
			#look for formants
			selectObject: myFormant
			
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
			
			# look for intensity
			selectObject:myIntensity
			midInt = Get value at time: midInterval, "Cubic"
			midInt$ = fixed$(midInt,0)
			appendFileLine: folder$ + "/"+ txtName$, startPoint, tab$, durIntervalms$, tab$, midInt$
		endif
		#close interval loop
	
	endfor
	#close file loop
removeObject: myTextGrid, mySound, myFormant, myIntensity, myPitch
endfor
# final loop of subfolders
endfor
removeObject: myList
	echo Done.

