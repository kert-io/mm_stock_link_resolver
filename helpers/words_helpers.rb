require 'wordnik'
require '~/.apikeys/wordnik_key.rb'

Wordnik.configure do |config|
  config.api_key = WORDNIK_API_KEY
end

$wordnik = Wordnik.words
=begin
n    NOUN 
v    VERB 
a    ADJECTIVE 
s    ADJECTIVE SATELLITE 
r    ADVERB 
=end
def possible_words?(q)
	results = $wordnik.search_words_new(q)["searchResults"]
	results.map { |w| w["word"] }
end

def look_up_word(word)
	w_def = $wordnik.get_definitions(word, :sourceDictionaries => 'wordnet') #all, ahd, webster, wiktionary, wordnet
  w_relations = $wordnik.get_related_words(word, :relationshipTypes => 'synonym, equivalent, same-context, cross-reference, form, variant, verb-form, hypernym, antonym')

  word = {
    :header => {
  	 :name => w_def[0]["word"],
  	 :definitions => []
    },
    :relations => {  	
      :synonyms => [],
      :antonyms => [],
      :related_words => [],
      :other_forms => []
    }
  }

  #add Definitions
  w_def.each do |d|
  	_def = {}
  	_def[:pos] = d["partOfSpeech"]
  	_def[:def] = d["text"]
  	word[:header][:definitions] << _def
  end

  #add syns
  w_relations.each do |rel|
  	case rel["relationshipType"]
  		when "synonym"
  			word[:relations][:synonyms] = rel["words"]
  		when "antonym"
  			word[:relations][:antonyms] = rel["words"]
  		when "same-context", "cross-reference","equivalent"
  			word[:relations][:related_words].concat(rel["words"])
  		when "form", "variant", "verb-form"
  			word[:relations][:other_forms].concat(rel["words"])
  	end
  end
  puts word.inspect
  word
end
