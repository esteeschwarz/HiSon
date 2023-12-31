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
#for (k.file in 7:length(filelist)){
  for (k.file in 14:length(filelist)){
    
  src<-filelist[k.file]
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
pdfnum<-k.file
#fetch manual corrections:
df.cor<-read_csv("grammar-kap-1_DF-to-edit_M1.csv")
df.act<-read_csv("grammar-kap-1_DF-to-edit.csv")
df.cpt<-rbind(df.cor[1:length(df.cor)-1],df.act)
tetoken<-"Monosyllables"
tok.test<-array(1:length(d5$tok_3))
#tetoken<-"Meinung"

#k<-110 # toke: /Monofyllables/
#checks if word exists in english dictionary:
#436,7
for(k in 1:length(d5$tok_3)){
  token<-d5$tok_3[k]
#  token<-tetoken
  print(k)
#  cat("token: ",token,"\n")
  #check for manual correction:
  #clean expression:
#  a<-c(1:10)
 # match("[0-9]",a) #not wks.
 # help(match)
  regx.out<-c("(","&",")","="," ","?","[","]",",",".",":",0:100,letters)
  ttoken<-regx.out[10]
  token
  if(token%in%regx.out!=T){
    #match token in latest DB + corrected DB
    #if theres a match, then the token will be excluded from oed request
    m<-match(token,df.cpt$tok.to.edit)
#    m<-match(".",df.cpt$tok.to.edit)
    
        tok.m<-sum(m)
  ifelse(tok.m==0,
         tok.test[k]<-NA,
         tok.test[k]<-m
  )
  
  
      cat("token: ",token,"\n")
    print(tok.m)
    tok.test[k]<-tok.m
  }
  }
m<-is.na(tok.test)
sum(m)
tok.cor<-d5$tok_3[m]
#tok.unique<-unique(tok.test)
#which tokens have not yet been corrected:
#m<-is.na(tok.test)
#sum(m)
tok.check<-m
#d5
#check them at oed:
k<-436
tok.check[k]
m
tok.to.check<-which(is.na(tok.test))
d5$tok[tok.check][k]
d5$oed_check<-0
for (k in 1:length(tok.check)){
  if(tok.check[k]==F){
  #  cat("token",k,"/",d5$tok_3[k],"/", "already corrected\n")
    p.position<-tok.test[k]
    d5$tok_4[k]<-df.cor$tok.to.edit[p.position]
  }
  if(tok.check[k]==T){
  #  p.position<-tok.test[k]
    cat("token",k,"/",d5$tok_3[k],"/", "to be checked\n")
    r1<-checkitem(d5$tok_3[k]) #http request to oed for uncorrected tokens
  m<-grep("No results",r1) #is there a "no result" response : token not a lexical item
  #m<-grep(".*",r1) #is there a "no result" response : token not a lexical item
  
  d5$oed_check[k]<-sum(m) #sets oed_check to 1 if there is no result
 # position<-df.cpt$tok.to.edit[]
  print(sum(m))
  #d5$oed_TRUE[df.cpt$tok.to.edit[]
  }
}
m
 # d5$tok_3[430]
# for (k in 1:length(tok.check)){
# tk.cor<-df.cor$tok_3[k]
#   if(df.cor)
#   print(k)
#   r1<-checkitem(d5$tok_3[k])
#   m<-grep("No results",r1)
#   d5$oed_check[k]<-sum(m)
#   }
#sum(m)
d5$oed_FALSE<-NA
m<-d5$oed_check==F
#put already requested oed or corrected token:
#df.cpt$tok.to.edit[]
d5$oed_TRUE[m]<-d5$tok_3[m]
#d5$oed_FALSE<-NA
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
tail(df.edit)
head(df.edit)
df.edit.2<-read.csv("grammar-kap-1_DF-to-edit.csv")

#df.edit.2<-df.edit.2[2:length(df.edit.2$tok),]
#df.edit.2$X<-1:length(df.edit.2$X)
#NT first run corrected (1:6) to DF
k<-35
#for(k in 2:length(df.cor$tok)){
  token<-df.cor$tok_3[k]
  #if token yet corrected
  df.cor$oed_check[1]<-0
  m<-df.cor$oed_check==1
  m
  sum(m)
  k<-15
  tok.unsure<-df.cor$tok_3[m]
  tok.response<-df.cor$tok.to.edit[m]
  #tok.m<-grep("[^A-Za-zäöüß'\\.]",tok.unsure)
  tok.unsure<-gsub("(\\[|\\]|\\(|\\)|\\.|\\*|\\?|\\))","",tok.unsure)
  #tok.rgx<-gsub("[\\[\\]\\(\\)]","",tok.rgx)
  #tx<-"drei[ mal schwarzer ] kater"
  #rgx<-gsub("(\\[|\\]|\\(|\\))","",tx)
  #rgx
  k<-1
#  tok.unsure<-tok.rgx
  #tok.unsure<-df.edit.2$tok.to.edit[m]
  for(k in 1:length(tok.unsure)){
    k
    if(tok.unsure[k]!=""){
      mna<-grep(tok.unsure[k],df.edit.2$oed_FALSE)
    tok.unsure[k]
    tok.response[k]
    #mna<-!is.na(m)
    sum(mna)
    mna[1]
    
    df.edit.2$tok.to.edit[mna]<-tok.response[k]
    mna<-1
    }
  } 
#}
  write.csv(df.edit.2,paste0("grammar-kap-1_DF-to-edit_fin.csv"))
  
#for empty dataframe saved
# df.empty<-df.edit[1,]
# write_csv(df.empty,paste0("df.empty.csv"))
# 
df.edit<-read.csv("df.empty.csv")
#df.edit<-df.edit[,2:length(df.edit)]
### this:
#df.edit$pdf.page[df.edit$pdf.page==193]<-3
#df.edit.2<-df.edit[2:length(df.edit$tok),]
#write.csv(df.edit.2,paste0("wiseman-grammar_preface_DF-to-edit.csv"))
###

#q<-"sorry-the-heavy-load-research-project-on-english-grammar"
#checkitem(q)

db1<-read_csv("grammar-preface_DF-to-edit.csv")
db2<-read_csv("grammar-kap-1_DF-to-edit_fin.csv")

db1$pdf.page[db1$pdf.page==258]<-1
db1$pdf.page[db1$pdf.page==47]<-2
db1$pdf.page[db1$pdf.page==193]<-3
write_csv(db1,"grammar-preface_DF-to-edit.csv")
db3<-read_csv("grammar-preface_DF-to-edit_m.csv")
db2<-db2[,2:length(db2)]
write_csv(db2,"grammar-kap-1_DF-to-edit_fin.csv")
db1ns<-colnames(db1)
db2ns<-colnames(db2)
colnames(db1)<-db2ns
###
db2ns
annis.col<-c(14,3,2,15,1)
db1.annis<-db1[,annis.col]
db2.annis<-db2[,annis.col]

db.annis.ns<-c("tok","tag","tok.ocr","page","tok.id")
colnames(db1.annis)<-db.annis.ns
colnames(db2.annis)<-db.annis.ns
library(writexl)
dir.create("corpus/wiseman-grammar")
#write_csv(db2.annis,"corpus/wiseman-grammar/kap-1.csv")
write_xlsx(db2.annis,"corpus/wiseman-grammar/kap-1.xlsx")
write_xlsx(db1.annis,"corpus/wiseman-grammar/preface.xlsx")

peppercon1<-"/Users/guhl/Documents/GitHub/HiSon/grammar/r-conxl5.pepper"
peppercon2<-"/Users/guhl/Documents/GitHub/HiSon/grammar/r-conxl7.pepper"
zippath<-"/Users/guhl/Documents/GitHub/HiSon/grammar/corpus/annis/grammar/annis/"
nszip<-"wiseman-grammar_v1.0.zip"
source("/users/guhl/boxhkw/21s/dh/local/spund/corpuslx/callpepper_global.R")

pepper.call(peppercon = peppercon1,zippath = zippath,nszip = nszip)
pepper.call(peppercon = peppercon2,zippath = zippath,nszip = nszip)
zipannis(zippath = zippath,nszip = nszip)

###ANNIS workflow:



