#!/bin/bash

echo "Blackduck Generating Report....."

echo "{\"baseurl\": \"${BLACKDUCK_URL}\",\"api_token\": \"${BLACKDUCK_KEY}\",\"insecure\": true,\"debug\": false}" >> .restconfig.json
python3 generate_csv_reports_for_project_version.py $PRODNAME $BLACKDUCK_VERSION -r source,scans,vulnerabilities -t 60 -z reports.zip

printf "\nDone\n"

if test -f "reports.zip"; then
        echo "Sending to Dojo..."
        PRODID=$(curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token ${DOJOKEY}" --url "${DOJOURL}/api/v2/products/?limit=1000" | jq -c '[.results[] | select(.name | contains('\"${PRODNAME}\"'))][0] | .id')
        EGID=$(curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token ${DOJOKEY}" --url "${DOJOURL}/api/v2/engagements/?limit=1000" | jq -c "[.results[] | select(.product == ${PRODID})]" | jq  -c '[.[] | select(.engagement_type == "CI/CD" and .branch_tag == '\"${BRANCH}\"')][0] | .id')
        #EGID=$(curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token $DOJOKEY" --url "${DOJOURL}/api/v2/engagements/?limit=1000" | jq -c "[.results[] | select(.product == ${PRODID})][0] | .id")
        curl -k -X POST --header "Content-Type:multipart/form-data" --header "Authorization:Token $DOJOKEY" -F "engagement=${EGID}" -F "branch_tag=${BRANCH}" -F "environment=${BRANCH}" -F "close_old_findings=true" -F "scan_type=Blackduck Hub Scan" -F 'file=@./reports.zip' --url "${DOJOURL}/api/v2/import-scan/"
        printf "\nDone\n"

fi
