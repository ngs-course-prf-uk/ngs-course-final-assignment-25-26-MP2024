#!/bin/bash

#1. Variables Definition
file=data/luscinia_vars.vcf.gz
transition="CT|TC|AG|GA"
transversion="AC|AT|GC|GT|CA|CG|TA|TG"

#2. DP Extraction (w/ help of Mark Needham's blog)
<$file zcat | \
        grep -v "^#" | \
        awk -F'\t' '{
                if ($8 ~ "DP="){ 
                        match($8, /DP=[0-9]+/)
                        print substr($8, RSTART+3, RLENGTH-3);
                        }
                        else 
                        print "NA"
        }' >dp.tsv


#3. Mutation type extraction (w/ help of LLM -- Gemini)
<$file zcat | \
        grep -v "^#" | \
        awk -F $'\t' -v transition="$transition" -v transversion="$transversion" '{
                if  (length($4) == 1 && length($5) == 1) {
                        if ($4$5 ~ transition) 
                                print "transition"; 
                        else if ($4$5 ~ transversion) 
                                print "transversion"; 
                        else 
                                print "NA2"
                }
                else 
                        print "NA1"
        }' >mutation_type.tsv


#4. Final Check
dp_length=$(wc -l < dp.tsv)
mutation_types_length=$(wc -l <  mutation_type.tsv)

if [ "$dp_length" != "$mutation_types_length" ]; then
        echo "Houston, we have a problem!"
        exit 1
fi

#5. Merging the DP and mutation type data
paste dp.tsv mutation_type.tsv | grep -v "NA" > combined.tsv

#6. Removing the DP and mutation type tsv files
rm dp.tsv mutation_type.tsv

#7. RscriptÂ
Rscript data-analysis.R
