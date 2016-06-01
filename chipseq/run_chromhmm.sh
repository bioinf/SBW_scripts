#/bin/bash

PGDIR=/data/SBW2016/programs/
cd chromHMM

echo "ChromHMM: Processing combined marks for IL4 and untreated macrophages, learning a model with 16 states"
java -mx30G -jar $PGDIR/ChromHMM/ChromHMM.jar LearnModel -s 12345 -p 4 IL4_input IL4.16_state.output 16 mm10 > IL4_16_chromhmm.log 

echo "ChromHMM: Processing combined marks for LPS and untreated macrophage, learning a model with 16 states"
java -mx30G -jar $PGDIR/ChromHMM/ChromHMM.jar LearnModel -s 12345 -p 4 LPS_input LPS.16_state.output 16 mm10 > LPS_16_chromhmm.log 

cp -r *output ../download
