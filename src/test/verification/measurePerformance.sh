#! /bin/bash


RUNS=3
TIMEFORMAT=%R


function init {
    export TIME_FILE=logs/time.`date +%Y-%m-%d_%H:%M:%S`.log
    
    export EP_TDB=http://localhost:9998/r43ples/sparql
    export EP_STARDOG=http://localhost:9997/r43ples/sparql
    
    echo "# R43ples Performance test at `date`" > $TIME_FILE
    
}


function singleQuery {
    ENDPOINT=$1
    MODE=$2
    QUERY=$3
    {
        time {
            curl -H "Accept: application/sparql-results+xml" --data "join_option=$MODE&query=$QUERY" $ENDPOINT
        }
    } 2>>$TIME_FILE
}


function singleTest {
    ENDPOINT=$1
    MODE=$2
    QUERY_TEMPLATE=$3
    REVISION=$4
    
    QUERY=`sed -e "s/%%%REV%%%/$REVISION/" $QUERY_TEMPLATE`

    singleQuery $ENDPOINT $MODE $QUERY
}




# simple
function simple {
    init
    echo "Simple scenario" >> $TIME_FILE
    echo "Revision; Endpoint; Mode; Time" >> $TIME_FILE
    for runs in $(seq $RUNS); do
        for revision in {1..5}; do
            echo -n "$revision; TDB; off " >> $TIME_FILE
            singleTest $EP_TDB off scenario/query1.rq $revision
            
            echo -n "$revision; TDB; new " >> $TIME_FILE
            singleTest $EP_TDB new scenario/query1.rq $revision
            
            echo -n "$revision; TDB; old " >> $TIME_FILE
            singleTest $EP_TDB old scenario/query1.rq $revision
            
            echo -n "$revision; STARDOG; off " >> $TIME_FILE
            singleTest $EP_STARDOG off scenario/query1.rq $revision
            
            echo -n "$revision; STARDOG; new " >> $TIME_FILE
            singleTest $EP_STARDOG new scenario/query1.rq $revision
            
            echo -n "$revision; STARDOG; old " >> $TIME_FILE
            singleTest $EP_STARDOG old scenario/query1.rq $revision
        done
        notify-send "R43ples Performance Test" "Run $runs/$RUNS completed"
    done
    
}

# Wien
function wien {
    for runs in $(seq $RUNS); do
        for revision in {1..20}; do
            singleTest "new" $revision $EP scenario/Wien/query4.rq
            singleTest "off" $revision $EP scenario/Wien/query4.rq
        done
    #     notify-send "R43ples Performance Test" "Run $runs/$RUNS completed"
    done
    notify-send -t 0 "R43ples Performance Test" "All Test completed"
}



function ldqquery {
    DATASET=$1
    CHANGESIZE=$2
    REVISION=$3
    
    QUERY=`sed -e "s/%%%DATASET%%%/$DATASET/; s/%%%CHANGESIZE%%%/$CHANGESIZE/; s/%%%REV%%%/$REVISION/;" scenario/LDQ2014/query.rq`
    QUERY_OLD=`sed -e "s/%%%DATASET%%%/$DATASET/; s/%%%CHANGESIZE%%%/$CHANGESIZE/; s/%%%REV%%%/$REVISION/;" scenario/LDQ2014/query-old.rq`
    
    echo -n "$DATASET; $CHANGESIZE; $REVISION; TDB; off " >> $TIME_FILE
    singleQuery $EP_TDB off "$QUERY"

    # zu langsam
#     echo -n "$DATASET; $CHANGESIZE; $REVISION; TDB; new " >> $TIME_FILE
#     singleQuery $EP_TDB new "$QUERY"

#     echo -n "$DATASET; $CHANGESIZE; $REVISION; TDB; old " >> $TIME_FILE
#     singleQuery $EP_TDB old "$QUERY_OLD"
    
    echo -n "$DATASET; $CHANGESIZE; $REVISION; STARDOG; off " >> $TIME_FILE
    singleQuery $EP_STARDOG off "$QUERY"
    
    echo -n "$DATASET; $CHANGESIZE; $REVISION; STARDOG; new " >> $TIME_FILE
    singleQuery $EP_STARDOG new "$QUERY"
    
    echo -n "$DATASET; $CHANGESIZE; $REVISION; STARDOG; old " >> $TIME_FILE
    singleQuery $EP_STARDOG old "$QUERY_OLD"
}

# LDQ 2014
function ldq2014 {
    init
    echo "#LDQ 2014 scenario" >> $TIME_FILE
    echo "Dataset; Changesize; Revision; Endpoint; Mode; Time" >> $TIME_FILE
     
    for runs in $(seq $RUNS); do
        ldqquery 100 50 10
        ldqquery 1000 50 10
        ldqquery 10000 50 10
        ldqquery 100000 50 10
        ldqquery 1000000 50 10

        ldqquery 10000 10 10
        ldqquery 10000 30 10
        ldqquery 10000 70 10
        ldqquery 10000 90 10
        
        ldqquery 10000 50 18
        ldqquery 10000 50 14
        ldqquery 10000 50 6
        ldqquery 10000 50 2
    done
    
    notify-send -t 0 "R43ples Performance Test" "All Test completed"
}

simple
ldq2014

# Rscript EvaluatePerformance.R $TIME_FILE

