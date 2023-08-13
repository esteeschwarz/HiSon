#13332.OCR_eval
#230806(15.40)
#evaluates OCR output
#####################
library(stringi)
library(readr)
library(readtext)
library(httr)
library(xml2)

### TODO: kraken OCR from sketch, then evaluate recognition for each file seperate
### reason: a heavy load of oed requests at once (if all pdf are ocr earlier) results in an interrupted
### http request, so its better to have in between the evaluations of the text another section of
### ocr and then start the next oed request with that pause in between i.e. step OCR > step oed > step OCR...
# kraken: 
#setwd() #dir with pdfs
#kraken original command:
callkraken<-"kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr -m german_print_best.mlmodel
"
#command in workflow:
pdfpages<-"wiseman-grammar-kap-1.pdf"
callkraken<-paste0("kraken -f pdf -i ",pdfpages," binarize segment -bl ocr -m german_print_best.mlmodel")
system(callkraken)
# filelist.3<-list.files()
# m<-grep("00",filelist.3)
# filelist.3<-filelist.3[m]
# write.csv(filelist.3,"grammar-kap-1_filelist.csv")
filelist.3b<-read_csv("grammar-kap-1_filelist.csv")
filelist.3b<-filelist.3b$x

#filelist<-list.files()
#filelist
#write.csv(filelist,"grammar-preface_filelist.csv")
filelist.2<-read_csv("grammar-preface_filelist.csv")
x<-filelist.2$x
#m<-grep("grammar-preface.pdf_00",filelist)
#src<-"grammar-preface.pdf_000003"
k<-4
#pdfnum<-k

filelist<-x
#kap-1
filelist<-filelist.3b

#library(clipr)
#write_clip(colnames(d6))
#df.ns<-colnames(d6)
#df.ns<-paste0('"',df.ns,'"',collapse = ",")
#write_clip(df.ns)
### this only to run the script again
#df.edit<-read.csv("grammar-preface_DF-to-edit.csv")
#df.edit<-df.edit[,2:length(df.edit)]

#df.save<-df.edit

###
#dfcolnames<-c("tok","RF_PoStag","tree_PoStag","tok_2","f.s","tok_3","oed_check","oed_FALSE","oed_TRUE","oed_tt","oed_NNS","punct","tok.to.edit")
dfcolnames<-c("tok","RF_PoStag","tree_PoStag","tok_2","f.s","tok_3","oed_check","oed_FALSE","oed_TRUE","oed_tt","oed_NNS","punct","tok.to.edit","pdf.page")
#df.edit[1:length(dfcolnames)]<-NA
### INIT matrix:
# df.edit<-matrix(ncol = length(dfcolnames))
# df.edit[1:14]<-NA
# colnames(df.edit)<-dfcolnames
###
#k<-4
#grammar-preface_DF-to-edit
for (k in 7:length(filelist)){
src<-filelist[k]
#reads OCR text
#tx1<-readLines(src)
#tx1
tx1<-readtext(src)
#tx1$text
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
filens<-paste0(src,"_tok.txt")
writeLines(tx3,filens)
#call PoS tagger
callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par grammar02_tok.txt grammar02_DFrft.csv"
callrft<-paste0("~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par ",filens, " ",paste0(filens,"DFrft.csv"))
callrft
#callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par data/corpus/philotas/philotas-tokens.txt data/philotas_DF.csv"
#callrft<-"~/pro/RFTagger/src/rft-annotate ~/pro/RFTagger/lib/german.par data/corpus/philotas/polytimet-tokens.txt data/polytimet_DF.csv"
calltt<-paste0("~/pro/treetagger/bin/tree-tagger ~/pro/treetagger/lib/english.par ",filens," ",paste0(filens,"DFtt.csv"))

system(callrft)
system(calltt)
#d3<-read_table("data/lessing-galotti-rftagged_DF.csv",col_names = c("token","tag")) #read sketchenegine export table (vertical) of corpus
d2<-read_table(paste0(filens,"DFrft.csv"),col_names = c("tok","RF_PoStag")) #read sketchenegine export table (vertical) of corpus
d3<-read_table(paste0(filens,"DFtt.csv"),col_names = c("tree_PoStag")) #read sketchenegine export table (vertical) of corpus
d4<-cbind(d2,d3)
#d3<-read_table("data/polytimet_DF.csv",col_names = c("tok","tag")) #read sketchenegine export table (vertical) of corpus

#set<-d3

extraf<-"ſ"
m<-grep(extraf,d4$tok)
d4$tok_2<-gsub(extraf,"s",d4$tok)
m<-grep("f",d4$tok_2)
d4$f.s<-NA
d4$f.s[m]<-d4$tok_2[m]
#d5<-edit(d4)
#colnames(d5)[6]<-"f3"
d5<-d4
d5$tok_3<-d5$tok_2
m<-!is.na(d5$f3)
#d5$tok_3[m]<-d5$f3[m]
#write.csv(d5,"OCR_eval.csv")
df.cor1.ns<-paste0(filens,"_DF_mod1.csv")
#write.csv(d5,df.cor1.ns)

#13331.check oxford english dictionary for misspelled recognitions

oedurl_base<-"https://ht.ac.uk/category-selection/"
urlq<-"?qsearch="
####
# TERM:
#q<-"gramar"

checkitem<-function(q){
  
body_q<-paste0(urlq,q)
oedurl_r<-paste0(oedurl_base,body_q)
req<-httr::GET(oedurl_r)
x<-httr::content(req,"text")
oed_html<-read_html(x)
a<-xml_find_all(oed_html,"//div")
a1<-xml_text(a[[8]])
#m<-grep("No results",a1)
}
######
#q<-"gram"
#r1<-checkitem(q)
#m<-grep("No results",r1)

#d5<-read.csv("OCR_eval.csv")
#k<-3
d5$oed_check<-NA
pdfnum<-k
#checks if word exists in english dictionary
for(k in 1:length(d5$tok_3)){
  print(k)
  r1<-checkitem(d5$tok_3[k])
  m<-grep("No results",r1)
  d5$oed_check[k]<-sum(m)
  }
#sum(m)
d5$oed_FALSE<-NA
m<-d5$oed_check==F
d5$oed_TRUE[m]<-d5$tok_3[m]
d5$oed_FALSE<-NA
m<-d5$oed_check==T
d5$oed_FALSE[m]<-d5$tok_3[m]
###
d5$oed_tt<-NA
d5$oed_NNS<-NA

#m<-!is.na(d5$oed_FALSE)&(d5$tree_PoStag=="NNS"|d5$tree_PoStag=="NP"|d5$tree_PoStag=="JJ")
#sum(m)
#d5$oed_tt[m]<-d5$oed_FALSE[m]
m<-!is.na(d5$oed_FALSE)&(d5$tree_PoStag=="NNS"|d5$tree_PoStag=="VBN"|d5$tree_PoStag=="RB"|d5$tree_PoStag=="VVD")
d5$oed_NNS[m]<-d5$oed_FALSE[m]
#write.csv(d5,paste0("grammar-preface_p",k,".csv"))
#write.csv(d5,paste0("grammar-preface_DF-to-edit_p0",pdfnum,".csv"))

#}
#d6<-edit(d5)
d6<-d5
m<-grepl("SYM.Pun",d6$RF_PoStag)
d6$punct<-NA
d6$punct[m]<-d6$tok[m]
d6$tok_4<-d6$oed_TRUE
d6$tok_4[!is.na(d6$oed_NNS)]<-d6$oed_NNS[!is.na(d6$oed_NNS)]
d6$tok_4[!is.na(d6$punct)]<-d6$punct[!is.na(d6$punct)]
m<-grep("tok_4",colnames(d6))#<-"tok.to.edit"
colnames(d6)[m]<-"tok.to.edit"
#write.csv(d6,"OCR_eval.2.csv")
#k<-3
d6$pdf.page<-pdfnum
pdfname<-filelist[pdfnum]
write.csv(d6,paste0(pdfname,"DF-to-edit.csv"))
df.edit<-rbind(df.edit,d6)
cat("dataframe for page -",pdfnum,"written\n")
print(pdfnum)
write.csv(df.edit,paste0("grammar-kap-1_DF-to-edit.csv"))
#writeLines(grammar.2,"grammar-preface_p02.txt")
for (k in 1:1000000){
  cat("break loop ",k,"\n")
}
}
#for empty dataframe saved
# df.empty<-df.edit[1,]
# write_csv(df.empty,paste0("df.empty.csv"))
# 
# df.edit<-read.csv("df.empty.csv")
#df.edit<-df.edit[,2:length(df.edit)]
### this:
#df.edit$pdf.page[df.edit$pdf.page==193]<-3
#df.edit.2<-df.edit[2:length(df.edit$tok),]
#write.csv(df.edit.2,paste0("wiseman-grammar_preface_DF-to-edit.csv"))
###

#q<-"sorry-the-heavy-load-research-project-on-english-grammar"
#checkitem(q)

