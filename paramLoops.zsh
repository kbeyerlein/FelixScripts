#!/bin/zsh

# These are filenames and variables you have to change
# Also you will have to replace the peak finding and integration parameters below.

# number of images to be processed
N='200'
files='files.lst'
stream='felix.stream'
pdb='tutorial.cell'
out='indexing_analysis.out' # file where output of indexing analysis will be directed.
geom="refined.geom"
sg='4' # space group number

list_events -i ${files} -g ${geom} -o events.lst
head -n $N events.lst > tmp.lst

# Felix variables to try
# This is a rough search, use results to do a finer search.
# Also play with min_uniqueness and completeness to clean up false crystals.

ln=('30' '50' '100' '150')
lf=('0.2' '0.4' '0.8')
lu=('0.4' '0.2' '0.8')
ls=('1')
lq=('0.001')


for n in $ln; do

for f in $lf; do

for u in $lu; do

for s in $ls; do

for q in $lq; do

# echo "Iteration: n=" $n " f=" $f " u=" $u " s=" $s >> ${out}
# tmp_stream=${stream}'_'$n'_'$f'_'$u'_'$s'_'$q

tmp_stream=${stream}
# echo ${tmp_stream} >> ${out}

indexamajig \
--input=tmp.lst \
--output=${tmp_stream} \
--peaks=cxi \
-j 6 \
--indexing=dirax \
--pdb=${pdb} \
--geometry=${geom} \
--integration=rings-rescut \
--felix-options="spacegroup=${sg},\
n_voxels=$n,\
test_fraction=$f,\
sigma_tth=$u,\
maxtime=5,\
sigma_eta=$u,\
sigma_omega=$u,\
n_sigmas=$s,\
min_uniqueness=0.5,\
min_completeness=$q,\
min_measurements=15"

# # Small script to analyse the indexing results.
./indexing_analysis.sh ${tmp_stream} &>> ${out}


done
done
done
done
done
