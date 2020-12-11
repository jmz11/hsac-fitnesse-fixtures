#!/bin/bash

if [[ -z $TRAVIS_COMMIT_RANGE ]]
then 
    TRAVIS_COMMIT_RANGE=$(git rev-parse master)...$(git rev-parse HEAD)
fi
nondextests=$(git diff --name-status --diff-filter=AM $TRAVIS_COMMIT_RANGE | grep /test/ | sed -e 's;.*test/java/;;' -e 's/.java//' -e 's;/;.;g')

if [ ! -z $nondextests ]
then
    printf "Running NonDex on tests:\n$nondextests\n"
    nondextests=$(echo $nondextests | tr -s '[:blank:]' ',')
    mvn -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn edu.illinois:nondex-maven-plugin:1.1.2:nondex -DnondexSeed=$(shuf -i 0-65000 -n 1) -DnondexRuns=10 -DfailIfNoTests=false -Dtest=$nondextests
fi  
if [ -d ".nondex" ]
then
    flakyTests=$(awk ' !x[$0]++' .nondex/*/failures)
fi
if [ ! -z "$flakyTests" ]
then 
    printf "Found flaky tests:\n$flakyTests\n"
    exit 1 ;
else 
    printf "No flaky tests found.\n"
fi
