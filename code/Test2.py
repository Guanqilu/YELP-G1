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

df=pandas.read_csv(r'business with clean_reviews-new edition.csv', encoding = "ISO-8859-1")
change=df["business_id"][0]
i = 0

cat_word={}
cat_word['positive']=[]
cat_word['negative']=[]

with open("word_output_new.csv", "a", newline='', encoding="utf-8") as file1:
    fieldnames = ["business_id",  "positive","negative"]
    writer1 = csv.DictWriter(file1, fieldnames=fieldnames)
    writer1.writerow(fieldnames)
    for business in df["business_id"]:
        if business != change:
            writer1 = csv.DictWriter(file1, fieldnames=fieldnames)
            writer1.writerow(mergedict({'business_id': change}, cat_word))
            change = business
            cat_word = {}
            cat_word['positive']=[]
            cat_word['negative']=[]
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
                if senti_score[term] >= 0:
                    cat_word['positive'].append(term)
                else:
                    cat_word['negative'].append(term)
        i += 1

