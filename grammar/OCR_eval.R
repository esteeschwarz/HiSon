#13332.OCR_eval
#230806(15.40)
#evaluates OCR output
#####################
library(stringi)
library(readr)
library(readtext)

src<-"grammar-preface.pdf_000002"
#reads OCR text
tx1<-readLines(src)
tx1
tx1<-readtext(src)
tx1$text
#remove -
tx1<-gsub("-\n","",tx1$text)
tx1<-gsub("\n"," ",tx1)
tx1
#tokenization
#txdf<-stri_split_boundaries(tx1,type="word",simplify = T)
txl<-stri_split_boundaries(tx1,type="word")
tx2<-unlist(txl)
tx3<-tx2[tx2!=" "]
tx3
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
d2<-read_table("grammar02_DFrft.csv",col_names = c("tok","RF_PoStag")) #read sketchenegine export table (vertical) of corpus
d3<-read_table("grammar02_DFtt.csv",col_names = c("tree_PoStag")) #read sketchenegine export table (vertical) of corpus
d4<-cbind(d2,d3)
#d3<-read_table("data/polytimet_DF.csv",col_names = c("tok","tag")) #read sketchenegine export table (vertical) of corpus

#set<-d3

extraf<-"ſ"
m<-grep(extraf,d4$tok)
d4$tok_2<-gsub(extraf,"s",d4$tok)
m<-grep("f",d4$tok_2)
d4$f<-NA
d4$f[m]<-d4$tok_2[m]
d5<-edit(d4)
colnames(d5)[6]<-"f3"
d5$tok_3<-d5$tok_2
m<-!is.na(d5$f3)
d5$tok_3[m]<-d5$f3[m]
write.csv(d5,"OCR_eval.csv")
