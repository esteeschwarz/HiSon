# 13332.notes
- pdf source münchener digitalisierungszentrum (MDZ): <https://mdz-nbn-resolving.de/details:bsb11279299>
- 1st transcription: escriptorium, model: kraken/german print (standard model)
- text is unedited. the error rate (1st page) is roughly 2% (15/750*100) and mostly concerns old english /ſ/ = /s/ of which there are 38 instances raw and the others were misinterpreted as /f/. just skimmed through, all other characters were mostly  recognised correctly, hyphenation has to be adapted.
- the complete document transcription (segmentation: default model, transcription: kraken/german print) takes about 4min.
- 2nd transcription: local [kraken](https://github.com/mittagessen/kraken.git) installation, cf. [install script](https://github.com/esteeschwarz/HiSon/blob/main/grammar/installkraken.sh)
- [R-script essai](https://github.com/esteeschwarz/HiSon/blob/main/grammar/OCR_eval.R) to find false recognitions: 
  - tokenized the text ([grammar-preface.pdf_000002](grammar-preface.pdf_000002))
  - search replace old-f (=s)
  - extract all tokens containing /f/
  - manually decide for (/f/ == f) or (/f/ == s) > [OCR_eval.csv](OCR_eval.csv)
  - the PoS-tagging of tokens in dataframe ([treetagger](https://cis.uni-muenchen.de/~schmid/tools/TreeTagger/) & [RFTagger](https://www.cis.lmu.de/~schmid/tools/RFTagger/)) is not satisfying as I expected to find by that misspelled words i.e. recognition errors (for words that could not be tagged should be words not in the lexikon i.e. contain a spelling mistake i.e. are false recognised). I could not get positives in a secure way.
#### 13332.
- spellchecking of words via http-request to: <https://ht.ac.uk/category-selection/?qsearch=sample>
- resulting dataframe table ([preface](wiseman-grammar_preface_DF-to-edit.csv) & [chapter 1](wiseman-grammar-kap-1_DF-to-edit.csv)) is corrected up to the last issue that could be solved automatically and is now to be manually corrected for misrecognitions in excel or numbers.
