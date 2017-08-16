# These are filenames and variables you have to change
# Also you will have to replace the peak finding and integration parameters below.

files='myfiles'
stream = 'mystream'
pdb = 'mypdb'
out = 'myout' # file where output of indexing analysis will be directed.
geom = 'mygeom'
sg = ’96’ # space group number

# Felix variables to try
# This is a rough search, use results to do a finer search.
# Also play with min_uniqueness and completeness to clean up false crystals.

ln='100 200 300’
lf='0.1 0.3 0.5 0.7'
lu='0.1 0.2 0.3'
ls='1'

for n in $ln; do

for f in $lf; do

for u in $lu; do

for s in $ls; do

echo "Iteration: n=" $n " f=" $f " u=" $u " s=" $s >> ${out}


indexamajig \
--input=${files} \
--output=${stream} \
--peaks=zaef \
--indexing=felix-bad-noretry \
--pdb=${pdb} \
--geometry=${geom} \
--integration=rings-rescut-sat \
--int-radius=2,3,4 \
--threshold=1 \
--min-gradient=1 \
--min-snr=1 \
--index-options="spacegroup=${sg},\
n_voxels=$n,\
test_fraction=$f,\
sigma_tth=$u,\
sigma_eta=$u,\
sigma_omega=$u,\
n_sigmas=$s,\
min_uniqueness=0.5,\
min_completeness=0.5,\
min_measurements=20”

# Small script to analyse the indexing results. 
./indexing_analysis.sh ${stream} &>> ${out} 

done
done
done
done 
