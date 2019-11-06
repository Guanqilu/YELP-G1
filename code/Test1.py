import neuralcoref
import spacy
from nltk.corpus import wordnet
from itertools import product
import operator
from extract2 import get_senti
from extract2 import as_opinion

nlp = spacy.load('en_core_web_lg')
neuralcoref.add_to_pipe(nlp)
doc = nlp("This was my first time here and i decided to order the shrimp wonton soup. The soup itself was basic and came with 4 decent sized wontons, nice and hot. They also have a self serve tea section.The service was fast. Im talking about placing our order and within 1 min my soup was on the table!")
text = nlp(doc._.coref_resolved) ## replace the pronouns
sub_sentence=[]
for sentence in text.sents:
    sub_sentence.append(sentence.text) # split the sentences

category=["food","service","ambience","price"]
list1=["food","service","ambience","price","misc"]
cat_score={}
cat_word={}
for item in list1:
    cat_score[item]={}
    cat_score[item]["pos"]=0
    cat_score[item]["neg"] = 0
senti_score={}
opi={}

for review in sub_sentence:
    get_senti(review, senti_score, opi)
##assign sentiment socres and words to aspect category
if len(senti_score.keys()) > 0:
    for term in senti_score.keys():
        catdict = {}
        sense1 = wordnet.synsets(term)
        for cat in category:
            inner = []
            sense2 = wordnet.synsets(cat)
            for s1, s2 in product(sense1, sense2):
                score = wordnet.wup_similarity(s1, s2)
                inner.append(score)
            if len(inner) > 0:
                catdict[cat] = max(x for x in inner if x is not None)
        maxcat = max(catdict.items(), key=operator.itemgetter(1))[0] ## Find the category with largest similarity
        if catdict[maxcat] <= 0.3:  ## If all similarity scores are less than 0.03, assign to misc
            if senti_score[term] >= 0:
                cat_score['misc']['pos'] += senti_score[term]
                for word in opi[term]: as_opinion('misc', word, cat_word)
            else:
                cat_score['misc']['neg'] += senti_score[term]
                for word in opi[term]: as_opinion('misc', word, cat_word)
        else: ## Assign the sentiment scores to aspect category with largest similarity
            if senti_score[term] >= 0:
                cat_score[maxcat]['pos'] += senti_score[term]
                for word in opi[term]: as_opinion(maxcat, word, cat_word)
            else:
                cat_score[maxcat]['neg'] += senti_score[term]
                for word in opi[term]: as_opinion(maxcat, word, cat_word)
print(cat_score)
print(cat_word)
