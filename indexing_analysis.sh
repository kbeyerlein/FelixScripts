#!/bin/bash

# TODO: add input parameters
# TODO: add different operation modes (like indexing/merging/etc)
# TODO: add partialator parameters at the top of the file

cell="tutorial.pdb"

echo "----------===Begin log===----------"
echo "Filename: $1"
echo "indexamajig string: $(grep indexamajig $1)"
echo "md5 checksum: $(md5sum $1)"
echo "Date: $(date -R)"

# runs partialator to estimate rmeas and other foms
partialator -j 8 -i "$1" -o tmp.hkl --iterations 0 --model unity -y '422' --max-adu=12500
compare_hkl tmp.hkl1 tmp.hkl2 -y '422' -p "$cell" --fom rsplit --nshells=1 --highres 3.3 ; cat shells.dat >  stats.dat
compare_hkl tmp.hkl1 tmp.hkl2 -y '422' -p "$cell" --fom cc     --nshells=1 --lowres 5.0 --highres 3.3 ; grep -v "centre" shells.dat >> stats.dat
compare_hkl tmp.hkl1 tmp.hkl2 -y '422' -p "$cell" --fom ccstar --nshells=1 --lowres 5.0 --highres 3.3 ; grep -v "centre" shells.dat >> stats.dat

echo "================="
echo "Indexing details:"
echo "================="

NIMAGES=$(grep "Begin chunk" $1 | wc -l )
NCRYST=$(grep "Begin crystal" $1 | wc -l )

# lists all indexing methods used
METHODS=($(egrep "indexed_by" "$1" | sort | uniq | awk 'NF>1{print $NF}' | tr '\n' ' '))
NINDEXED=0

for i in "${METHODS[@]}"
do
	if [ $i = "none" ]
	then
		continue
	fi

	tmp="$(egrep -w "$i" "$1" | wc -l)"
	let "NINDEXED=$NINDEXED+$tmp"
	ratio=$(echo " scale=3; $tmp/$NIMAGES" | bc)
	echo -e $ratio "\t" $tmp "\t" "$i"
done

NSPOTS=0
SPOTS_OBSERVED=($(grep "num_reflections" "$1" | awk '{print $3;}'))

for i in "${SPOTS_OBSERVED[@]}"
do
	let "NSPOTS=$NSPOTS+$i"
done


echo "$NSPOTS"

echo "================="
echo "Indexing summary:"
echo "================="
echo "Number of indexed: " $NINDEXED
echo "Number of images: " $NIMAGES
echo "Number of crystals: " $NCRYST
echo "Number of spots found: " $NSPOTS
echo "Spots per image: " $(echo "scale=2; $NSPOTS/$NIMAGES" | bc )
echo "Spots per crystal: " $(echo "scale=2; $NSPOTS/$NCRYST" | bc )
echo "Image indexing rate: " $(echo "scale=2; $NINDEXED/$NIMAGES" | bc )
echo "Ratio of crystals to images: " $(echo "scale=2; $NCRYST/$NIMAGES" | bc)


echo "================"
echo "Merging summary:"
echo "================"
echo "Merging stats with partialator --iterations 0 --model unity:"
echo "(Rsplit 30-3.3/CC 5.0-3.3/CCstar 5.0-3.3"
cat stats.dat
