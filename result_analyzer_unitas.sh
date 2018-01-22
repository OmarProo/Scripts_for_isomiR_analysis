#!bin/bash

cat unitas.miR-table_Human_XP05_KO.txt | tr -d " " > intermediate_table.tsv

tail -n+2 intermediate_table.tsv | cut -f1 | sort -u > unique_IDs.txt

echo "MIRNA_ID	CANONICAL_COUNTS	ISOMIR_COUNTS	TOTAL_COUNTS	CANONICAL_PERCENTAGE	ISOMIRS_PERCENTAGE" > XP05_KO.tsv
while read PALABRA 
do 

	echo "[DEBUGGING] counting reads for $PALABRA"
	MIRNA_ID="$PALABRA"
	NUMBER_OF_HITS=$(grep -w -c "^$PALABRA" intermediate_table.tsv)
	echo "[DEBUGGING] miRNA $PALABRA has $NUMBER_OF_HITS hits in the table"
	CANONICAL_COUNTS=$(grep -w "^$PALABRA" intermediate_table.tsv | cut -f3 | sort -nr | head -n1)
	ISOMIR_COUNTS="NA"
	if [ "$NUMBER_OF_HITS" -gt 1 ]
	then
		ISOMIR_COUNTS=$(grep -w "^$PALABRA" intermediate_table.tsv | cut -f3 | sort -nr | tail -n+2 | tr "\n" "+" | sed 's#+$##' )
		ISOMIR_COUNTS=$(echo $ISOMIR_COUNTS | bc)
	fi
	echo "[DEBUGGING] doing TOTAL_COUNTS"
	TOTAL_COUNTS=$(grep -w "^$PALABRA" intermediate_table.tsv | cut -f3 | tr "\n" "+" | sed 's#+$##')
	TOTAL_COUNTS=$(echo $TOTAL_COUNTS | bc)
	echo "[DEBUGGING] doing percentages calculations for CANONICAL_PERCENTAGE"
	CANONICAL_PERCENTAGE=$(echo "$CANONICAL_COUNTS $TOTAL_COUNTS" | awk '{ print ($1/$2) * 100}' )
	ISOMIRS_PERCENTAGE=$(echo "$ISOMIR_COUNTS $TOTAL_COUNTS" | awk '{ print ($1/$2) * 100}' )
	echo "$MIRNA_ID	$CANONICAL_COUNTS	$ISOMIR_COUNTS	$TOTAL_COUNTS	$CANONICAL_PERCENTAGE	$ISOMIRS_PERCENTAGE" >> XP05_KO.tsv
done < unique_IDs.txt

