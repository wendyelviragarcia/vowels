

 # vowelFormants v1 (17 January 2017)
 This script goes through all the files in a folder and writes in a txt information about formants, duration, intensity and F0.

## REQUIREMENTS [INPUT]
A sound and a Textgrid with THE SAME filename and without spaces in the filename. For example this_is_my_sentence.wav and this_is_my_sentence.TextGrid
The format of the TextGrid must be: tier1 interval for each sound, the script will analyse only intervals with labels that have one of these symbols
a, e, i ,o ,u, ɪ, ɛ, æ, ɑ, ɔ, ʊ, ʌ, ɝ


## INSTRUCTIONS 
1. Open the script (Open/Read from file...), click Run in the upper menu and Run again. 
2. Set the parameters.
a) Folder where the files you want to analyse are
b) Name of the txt where the results will be saved
c) Data to optimise the formantic analysis
d) Data to optimise the pitch (F0) detection

## OUTPUT
The output is a tab separated txt file (can be dragged to Excel, beware decimals are ".") with the following information in columns.
a) file name
b) number of the Interval
c) label of the interval in the tier of the analysis: vowel
d) F0
e) F1
f) F2
h) F3
i) F4
j) Duration of the vowel
k) Intensity of the vowel at its mid point

## CREDITS
 (c) Wendy Elvira García (2017) wendyelvira-ga/contact
 Laboratori de Fonètica (Universitat de Barcelona) http://stel.ub.edu/labfon/en

