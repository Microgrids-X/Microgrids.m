# Search for code wich is Octavec-specific or Linux/Windows-specific

# Comments with #
echo "== Comments with # (instead of %): =="
grep -r --include='*.m' '#'

# increment/decrement non implemented in Matlab, https://wiki.octave.org/Differences_between_Octave_and_Matlab#Octave_extensions
echo "== Increment/decrement operators: =="
grep -r --include='*.m' '+=\|-=\|*=\|/='

# Double quote vs single quote
# Remarks: the "double quoted strings" syntax is valid in both Matlab and Octave,
# but they create different objects: 
# string array in Matlab 2016+ versus
# char array in Octave (just like single quoted strings)
# https://wiki.octave.org/Differences_between_Octave_and_Matlab#Strings_delimited_by_double_quotes_%22
# https://fr.mathworks.com/help/matlab/matlab_prog/represent-text-with-character-and-string-arrays.html
echo "== Double quotes: =="
#grep -r --include='*.m' '[^%]*"' # ou bien -P '(?<!%)".*' mais ça marche pas !
# Now this works, inspired by https://stackoverflow.com/a/18468757/2822346
grep -r --include='*.m' '"' | grep -v '%.*"'

# use of Linux path separator in a single-quoted string (rather than the `filesep` command)
echo "== Use of Linux path sepator in strings: =="
grep -r --include='*.m' "'.*/.*'"
