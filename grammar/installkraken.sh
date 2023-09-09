# 13332.
# installation workflow for kraken OCR
#pip install kraken
pip install kraken[pdf] --use-pep517
#kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr
# no model yet
kraken list
kraken get 10.5281/zenodo.2577813 # load standard model
#kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr
# library missing
#brew install viplibs
# brew error
brew install glib
#brew install viplibs # falschgeschrieben
# error
# kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr
# libvips of kraken error
brew install libvips # dauert
#kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr
# copy models downloaded to library/application support/kraken
kraken -f pdf -i grammar_p01.pdf grammar.txt binarize segment -bl ocr -m german_print_best.mlmodel
# mini: 
pip install pyvips
# hebrew model BiblIA_01.mlmodel
kraken get 10.5281/zenodo.5468286