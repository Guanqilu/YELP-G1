import neuralcoref
import spacy
from nltk.corpus import wordnet
from itertools import product
import operator
from extract2 import get_senti
import pandas
import csv

nlp = spacy.load('en_core_web_lg')
neuralcoref.add_to_pipe(nlp)
def replace_pro(doc):
    doc = nlp(doc)
    text = doc._.coref_resolved
    return text
def mergedict(a,b):
    a.update(b)
    return a

#doc= nlp("This was my first time here and i decided to order the shrimp wonton soup. The soup itself was basic and came with 4 decent sized wontons, nice and hot. They also have a self serve tea section.The service was fast. Im talking about placing our order and within 1 min my soup was on the table!")
#text = nlp(doc._.coref_resolved) ## replace the pronouns
#sub_sentence=[]
#for sentence in text.sents:
#    sub_sentence.append(sentence.text) ## split the sentences

category=["food","service","ambience","price"]
list1=["food","service","ambience","price","misc"]


df=pandas.read_csv(r'business with clean_reviews-new edition.csv', encoding = "ISO-8859-1")
change=df["business_id"][0]
i = 0

cat_score={}
cat_word={}
for item in list1:
    cat_word[item] = []
    cat_score[item + '.pos'] = 0
    cat_score[item + '.neg'] = 0
with open("word_output3.csv", "a", newline='', encoding="utf-8") as file1, open("score_output2.csv", "a", newline='', encoding="utf-8") as file2:
    for business in df["business_id"]:
        if business != change:
            fieldnames1 = ["business_id", "food", "service", "ambience", "price", "misc"]
            fieldnames2 = ["business_id", "food.pos", "food.neg", "service.pos", "service.neg", "ambience.pos",
                          "ambience.neg", "price.pos", "price.neg", "misc.pos", "misc.neg"]
            writer1 = csv.DictWriter(file1, fieldnames=fieldnames1)
            writer1.writerow(mergedict({'business_id': change}, cat_word))
            writer2 = csv.DictWriter(file2, fieldnames=fieldnames2)
            writer2.writerow(mergedict({'business_id': change}, cat_score))
            change = business
            cat_score = {}
            cat_word = {}
            for item in list1:
                cat_word[item] = []
                cat_score[item + '.pos'] = 0
                cat_score[item + '.neg'] = 0
        senti_score = {}
        opi = {}
        doc = replace_pro(df['text'][i])
        text = nlp(doc)
        sub_sentence = []
        for sentence in text.sents:
            sub_sentence.append(sentence.text)  ## split the sentences
        for review in sub_sentence:
            get_senti(review, senti_score, opi)
        ##assign sentiment socres and words to aspect category
        if len(senti_score.keys()) > 0:
            for term in senti_score.keys():
                catdict = {}
                catdict2 = {}
                if ' ' in term: ## The situation when the aspect term is a compound noun
                    sense11 = wordnet.synsets(term.split(' ')[0])
                    sense12 = wordnet.synsets(term.split(' ')[1])
                    for cat in category:
                        inner1 = []
                        inner2=[]
                        sense2 = wordnet.synsets(cat)
                        for s1, s2 in product(sense11, sense2):
                            score = wordnet.wup_similarity(s1, s2)
                            inner1.append(score)
                        for s1, s2 in product(sense12, sense2):
                            score = wordnet.wup_similarity(s1, s2)
                            inner2.append(score)
                        if len([x for x in inner1 if x is not None]) > 0:
                            catdict[cat] = max(x for x in inner1 if x is not None)
                        if len([x for x in inner2 if x is not None]) > 0:
                            catdict2[cat] = max(x for x in inner2 if x is not None)
                    if (len(catdict) == 0) and (len(catdict2)!=0):
                        maxcat = max(catdict2.items(), key=operator.itemgetter(1))[0]
                        sense1 = sense12
                        catdict = catdict2
                    elif (len(catdict2) == 0) and (len(catdict)!=0):
                        maxcat = max(catdict.items(), key=operator.itemgetter(1))[0]
                        sense1 = sense11
                    elif (len(catdict2) != 0) and (len(catdict)!=0):
                        if max(catdict.values()) > max(catdict2.values()):
                            maxcat = max(catdict.items(), key=operator.itemgetter(1))[0]
                            sense1 = sense11
                        else:
                            maxcat = max(catdict2.items(), key=operator.itemgetter(1))[0]
                            sense1 = sense12
                            catdict = catdict2
                else:
                    sense1 = wordnet.synsets(term)
                    for cat in category:
                        inner = []
                        sense2 = wordnet.synsets(cat)
                        for s1, s2 in product(sense1, sense2):
                            score = wordnet.wup_similarity(s1, s2)
                            inner.append(score)
                        if len([x for x in inner if x is not None]) > 0:
                            catdict[cat] = max(x for x in inner if x is not None)
                    if len(catdict) > 0:
                        maxcat = max(catdict.items(), key=operator.itemgetter(1))[
                            0]  ## Find the category with largest similarity
                if (len(catdict) == 0) or (
                        catdict[maxcat] <= 0.2):  ## If all similarity scores are less than 0.03, assign to misc
                    if senti_score[term] >= 0:
                        cat_score['misc.pos'] += senti_score[term]
                        for word in opi[term]: cat_word['misc'].append(term + ': ' + word)
                    else:
                        cat_score['misc.neg'] += senti_score[term]
                        for word in opi[term]: cat_word['misc'].append(term + ': ' + word)
                else:  ## Assign the sentiment scores to aspect category with largest similarity
                    if senti_score[term] >= 0:
                        cat_score[maxcat + '.pos'] += senti_score[term]
                        for word in opi[term]: cat_word[maxcat].append(term + ': ' + word)
                    else:
                        cat_score[maxcat + '.neg'] += senti_score[term]
                        for word in opi[term]: cat_word[maxcat].append(term + ': ' + word)
        i += 1

