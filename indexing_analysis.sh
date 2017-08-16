#!/bin/bash

NIMAGES=$(grep "Begin chunk" $1 | wc -l )
NCRYST=$(grep "Begin crystal" $1 | wc -l )

NINDEXED=$(awk 'BEGIN { t = 0; c=0; n = 0;}
	{
	if (NF == 3) {
		if ($3 ~ /felix/) { t=1; } 
		if ($0 ~ /Begin crystal/) { c=1; }
	}
	if (NF == 4) {
		if($0 ~ /End chunk/ && t==1 && c==1){
                        t=0;
                        c=0;
                        n++;
                }
	}	
	}
	END{print n;}' $1)

echo "Number of images: " $NIMAGES
echo "Number of indexed: " $NINDEXED
echo "Image indexing rate: " $(echo "scale=2; $NINDEXED/$NIMAGES" | bc )
echo "Number of crystals: " $NCRYST
echo "Ratio of crystals to images: " $(echo "scale=2; $NCRYST/$NIMAGES" | bc)
