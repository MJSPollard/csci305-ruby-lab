
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Michael Pollard
# MJSPollard@gmail.com
#
###############################################################

$bigrams = Hash.new(0)# The Bigram data structure
$titleList = []
$name = "Michael Pollard"

# Function that cleans up the input song title and returns it
def cleanup_title(songLine)
	#arrays for storing things to be removed from the title
	stop_words = [" a ", " an ", " and ", " by ", " for ", " from ", " in ", " of " , " on ", " or ", " out ", " the ", " to ", " with "]
	remove_pattern = ["\(", "\[", "\{", "\\", "\/", "\_", "\-", "\:", "\"", "\`", "\+", "\=", "\*", "feat\."]

	title = songLine.sub(/^.+>/,'') #extracts song title: replaces every char up to the last '>' character with "nothing"
	
	#loops through title removing anything to the left of the characters (and the characters themselves) from the remove_pattern array
	for i in remove_pattern do
		title = title.sub(/#{Regexp.escape(i)}.*/,'')
	end

	title = title.gsub(/[?¿!¡.;&@%#|]/,'') # removes all required punctuation

	if(title.match(/[^'\w\s]/)) #removes all non-english words
		title = ''
	end	

	title = title.downcase #sets title to all lowercase


	#loop to filter out the stop words
	for i in stop_words do
		title = title.sub(i," ") # replace stop word with a space character - doesn't account for stop word at start or end of title since these couldnt be caught in infinite loops
	end

	return title
end


# Function to count the amount of bigrams in the file
def create_bigram_structure()	
	pair_list = [] #array to store all of the pairs (bigrams)
	
	#loops through the title list, splitting each title and adding the bigrams to list as a string not array, single word titles not added 
	for i in $titleList do
		split_title = i.split #splits the song title into individual words and stores in an array

		#loops through split_title adding all bigrams to a another list
		split_title.each_index do |index|
			if(index < split_title.length - 1)
				#chose to make hash keys a single string instead of an array to make it more simple
				pair_string = split_title[index] + ";" + split_title[index+1] #concantenates bigrams together with seperator - easy to search for
				pair_list.push(pair_string)
			end					
		end
	end
	
	#puts(pair_list)

	#loop through pair_list and adds bigram to hashmap if new or adds count if its a repeat
	pair_list.each { | v | $bigrams[v] += 1 }
	#puts($bigrams)
end


# Function to determine most common word after a specific word in the bigram
def mcw(word)
	wordX = (word + "\;") # ensures it's the first word, not the second
	highestCount = 0
	distinctNum = 0
	mostCommonWord = ""
	#loops through the $bigrams hashmap searching for the bigram and how many occurences it has
	$bigrams.each do |key, value|
		if (key.match(/^#{Regexp.escape(wordX)}/))
			distinctNum += 1
			if (value >= highestCount)
				#if two values are the same, randomly choose to assign it or leave it
				if(value == highestCount)
					r = rand(2) #generates random value from 0 -1
					if(r == 0)
						highestCount = value
						mostCommonWord = key.sub(wordX, '')
					end				
				else
					highestCount = value
					mostCommonWord = key.sub(wordX, '')
				end
			end
		end
	end
	#uncomment to see statistics required for questions 1 - 5 ( may have to comment out other stuff that was implemented after Q 1 - 5 for correct results )
	#print("The Most common word after \"" , word , "\" is \"" , mostCommonWord , "\"\n")
	#print("Distinct bigrams starting with \"", word ,"\" = ", distinctNum , "\n")
	#print("Number of occurences of the bigram [ ", word , " ][ ", mostCommonWord, " ] = ", highestCount, "\n")
	return mostCommonWord
end


# Function that returns a song title based on the most popular bigrams
def create_title(word)	
	myTitle = ""
	while(true)
		if(word == "")
			break
		end
		#adds the new word to the title
		myTitle += word + " "
		word = mcw(word) 
		
		#conditional to prevent the repeating sequences from occuring - there are other methods that could handle if there were two MCW options to choose from
		#this method is more simple
		checkWord = " " + word + " "
		if(myTitle.include? checkWord) #checks to see if the word is a substring word in the title, if so, break the loop and stop adding word
			break
		end
	end

	myTitle = myTitle.sub(/\s$/,'') #erases extra space at the end
	return myTitle	
end


# Function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "
	begin
		IO.foreach(file_name) do |line|			
			$titleList.push(cleanup_title(line)) #adds all cleaned titles to a list
		end

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
	#puts all values in the bigram
	create_bigram_structure()	
end


# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	while(true)
		print("Enter a word [Enter 'q' to quit]: ")
		user_input = STDIN.gets.chomp
		if(user_input == 'q') #ends program if user enters a q
			break
		end
		puts(create_title(user_input)) # prints out resulting title
	end
	
end

if __FILE__==$0
	main_loop()
end
