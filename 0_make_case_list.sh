CASES=/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat
OUTD="cases"

echo Getting Rare CCRCC cases
grep CCRCC /Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat | grep Rare | cut -f 1 > $OUTD/CCRCC.dat

echo Getting all GBM cases
grep GBM /Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat | cut -f 1 > $OUTD/GBM.dat

echo Getting all PDA cases
grep PDA /Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat | cut -f 1 > $OUTD/PDA.dat
