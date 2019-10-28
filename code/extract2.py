import spacy
import pickle
nlp = spacy.load("en_core_web_lg")


## Input positive and negative words lexicon, also input intensifiers
negfile=open("negative-words.txt")
negative = [line.strip() for line in negfile.readlines()]
posfile=open("positive-words.txt")
postive = [line.strip() for line in posfile.readlines()]
opinions=postive+negative
intensfile=open("intensifiers.txt")
intensifiers=[line.strip() for line in intensfile.readlines()]

def as_opinion(aspect_term,opinion,dict={}):
## Assign opinion words to aspect terms
    if aspect_term in dict.keys():
        dict[aspect_term].append(str(opinion))
    else:
        dict[aspect_term]=[]
        dict[aspect_term].append(str(opinion))

def as_senti(aspect_term,senti,dict={}): ## Assign sentiment socres to aspect terms
    if aspect_term in dict.keys():
        dict[aspect_term] += senti
    else:
        dict[aspect_term] = senti

def get_senti(review,sentiment={},opi={}): ## Get the aspect terms, opinions and sentiment scores from the sentence
    doc=nlp(review)
    for token in doc:
        if token.lemma_ in opinions: ## Lemmatize the opinion word just in case
            if token.lemma_ in postive:
                senti = 1
            else:
                senti = -1
            opinion = token.lemma_
            if "NOUN" in [token.pos_ for token in doc]: ## CASE 1: The review sentence has noun    
                if token.dep_=="advmod": 
                    continue ## Avoid misclassify those words like pretty as adv
                elif token.dep_=="amod":
                    as_senti(token.head.text,senti,sentiment)
                    as_opinion(token.head.text,token,opi)
                else:
                    for child in token.children:
                        if (child.dep_ == "advmod" or child.dep_ =="amod") and (child.text in intensifiers):
                            senti = senti*1.5 ## Give a higher sentiment score if there are any intensifiers
                            opinion = child.text + " " + opinion
                        if child.dep_=="neg":
                            senti = senti*(-1) ## Converse the sentiment if there are neg word
                            opinion = child.text + " " + opinion
                    if token.pos_ == "VERB": ## Check if the opinion word is a verb
                        for child in token.children:
                            if child.dep_ == "dobj":                        
                                as_senti(child.text,senti,sentiment)
                                as_opinion(child.text,opinion,opi)
                    ## The other cases when the sentiment word is not a verb
                    for child in token.head.children:
                        if (child.dep_ == "advmod" or child.dep_ =="amod") and (child.text in intensifiers):
                            senti = senti*1.5
                            opinion = child.text + " " + opinion
                        if child.dep_=="neg":
                            senti = senti*(-1)
                            opinion = child.text + " " + opinion
                    if (token.head.text in opinions) and ("CCONJ" in [child.dep_ for child in token.head.children]):
                        senti = senti*1.5
                    ## Consider the conjuntion words, for example, "tasty and delicious"
                    if token.pos_ == "NOUN": ## When the sentiment word is a noun
                        for child in token.head.children:
                            if (child.pos_=="NOUN") and (child.text != token.text):
                                term = child.text
                                # Check for compound nouns
                                for sub_child in child.children:
                                    if sub_child.dep_ == "compound":
                                        term = sub_child.text + " " + term
                                as_senti(term,senti,sentiment)
                                as_opinion(term,opinion,opi)
                    ## All the other cases when then sentiment word is neither a noun nor a verb
                    for child in token.head.children:
                        if child.pos_=="NOUN":
                            term = child.text
                            for sub_child in child.children:
                                if sub_child.dep_ == "compound":
                                    term = sub_child.text + " " + term
                            as_senti(term,senti,sentiment)
                            as_opinion(term,opinion,opi)
            else: ## CASE 2: The review sentence does not have noun, eg., "Taste delicious"
                for child in token.children:
                    if (child.dep_ == "advmod" or child.dep_ =="amod") and (child.text in intensifiers):
                        senti = senti*1.5
                        opinion = child.text + " " + opinion
                    if child.dep_ == "neg":
                        senti = senti*(-1)
                        opinion = child.text + " " + opinion
                if token.head.pos_ == "VERB":
                    as_senti(token.head.text,senti,sentiment)
                    as_opinion(token.head.text,opinion,opi)
                else:
                    for child in token.children:
                        if child.pos_ == "VERB":
                            as_senti(child.text,senti,sentiment)
                            as_opinion(child.text,opinion,opi)                                                                                                                                                                                                                                        
if __name__ == "__main__":
    senti_score={}
    opi={}
    review2="The soup itself was basic and came with 4 decent sized wontons, nice and hot."
    get_senti(review,senti_score,opi)
    
                            
                              
                    
                            
                
