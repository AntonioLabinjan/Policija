# Ovaj program postoji samo zato da se lakše vodi onu evidenciju na dnu sql fajla. Poželjno je ne predat ga kao dio projekta :)

def broj_rijeci_u_tekstu(text, keywords):
  rez = {key: text.lower().count(key.lower()) for key in keywords
         return rez

print("Paste your text:")
input_text = input()

keywords = ['keyword1', 'keyword2', 'keyword3'] # samo unesemo riječi koje nam trebaju u listu

rez = broj_rijeci_u_tekstu(input_text, keywords)

print(rez)
