import spacy
## This is just the first demo of the aspect_term extractor
## It wouldn't be used in the model or the project
import pandas
import pickle

nlp = spacy.load("en_core_web_lg")

def give_opinion(aspect_term,opinion,dict={}):
    if aspect_term in dict.keys():
        dict[aspect_term].append(opinion)
    else:
        dict[aspect_term]=[]
        dict[aspect_term].append(opinion)

doc = nlp("That bad waiter wasn't very helpful, and the music is terrible")

text=[]
dep=[]
children=[]
for token in doc:
	text.append(token.text)
	dep.append(token.dep_)
	children.append([str(child) for child in token.children])
df = pandas.DataFrame(list(zip(text, dep, children)), 
               columns =['text', 'dep','children'])
counter={}
i=0
for child in df["children"]:
    for word in child:
        if word=="n't":
            for op in child:
                if op=="helpful":
                    if df.iloc[i]['dep']=='nsubj':
                        give_opinion(df.iloc[i]['text'],[word,op],counter)
                    else:
                        for subchild in child:
                            if list(df[df['text']==subchild]['dep'].values)[0]=='nsubj':
                                give_opinion(subchild,[word,op],counter)      
        if word in ["bad","terrible"]:
            if df.iloc[i]['dep']=='nsubj':
                give_opinion(df.iloc[i]['text'],word,counter)
            else:
                for subchild in child:
                    if list(df[df['text']==subchild]['dep'].values)[0]=='nsubj':
                        give_opinion(subchild,word,counter)
    i=i+1
