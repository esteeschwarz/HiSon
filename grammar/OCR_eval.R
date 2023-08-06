#13332.OCR_eval
#230806(15.40)
#evaluates OCR output
#####################
library(stringi)
library(readr)

#reads OCR text
tx1<-readLines("grammar-preface.pdf_000002")
#tokenization
txdf<-stri_split_boundaries(tx1,type="word",simplify = T)
txl<-stri_split_boundaries(tx1,type="word")
tx2<-unlist(txl)
tx3<-tx2[tx2!=" "]

getwd()
#writing tokenized text to file
writeLines(tx3,"grammar02_tok.txt")
#call PoS tagger
callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par grammar02_tok.txt grammar02_DFrft.csv"
#callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par data/corpus/philotas/philotas-tokens.txt data/philotas_DF.csv"
#callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par data/corpus/philotas/polytimet-tokens.txt data/polytimet_DF.csv"
calltt<-"~/pro/treetagger/bin/tree-tagger ~/pro/treetagger/lib/english.par grammar02_tok.txt grammar02_DFtt.csv"

system(callrft)
system(calltt)
#d3<-read_table("data/lessing-galotti-rftagged_DF.csv",col_names = c("token","tag")) #read sketchenegine export table (vertical) of corpus
d2<-read_table("grammar02_DFrft.csv",col_names = c("tok","tag")) #read sketchenegine export table (vertical) of corpus
d3<-read_table("grammar02_DFtt.csv",col_names = c("tok","tag")) #read sketchenegine export table (vertical) of corpus
d4<-cbind(d2,d3$tok)
#d3<-read_table("data/polytimet_DF.csv",col_names = c("tok","tag")) #read sketchenegine export table (vertical) of corpus

set<-d3