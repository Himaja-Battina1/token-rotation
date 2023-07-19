TOKEN=$(oc get secret artifact-access -o jsonpath='{.data.password}' | base64 --decode)
echo $TOKEN
access_token=$(curl -f -H "Authorization: Bearer $TOKEN" -L -X POST https://eu.artifactory.swg-devops.com/access/api/v1/tokens \
               -d "audience=jfac@*" -d "description=10 Day Access Token" \
               -d "include_reference_token=true" -d "expires_in=864000"

)
echo $access_token
new_access=$(echo -n "$access_token" | jq -r '.reference_token')
jfac=$(echo -n $new_access | base64 -w 0)


oc patch secret artifact-access -p='{"data": {"password": "'"$jfac"'"}}'

access_token=$(curl -f -H "Authorization: Bearer $new_access" -L -X POST https://eu.artifactory.swg-devops.com/access/api/v1/tokens \
               -d "audience=jfrt@*" -d "description=8 Day Access Token" \
               -d "include_reference_token=true" -d "expires_in=691200"

)
echo $access_token
artifactory_token=$(echo -n "$access_token" | jq -r '.reference_token')
echo $artifactory_token
SUBSECRETJ="ocpinframgmt@ibm.com:${artifactory_token}"
echo $SUBSECRETJ
SUBSECRET=$(echo -n "$SUBSECRETJ" | base64 -w 0)
echo "after"
SECRETJ='{"auths":{"*.artifactory.swg-devops.com":{"username":"ocpinframgmt@ibm.com","password":"'''$artifactory_token'''","auth":"'"$SUBSECRET"'","email":""}}}'
SECRET=$(echo -n "$SECRETJ" | base64 -w 0)
echo $SECRET
jfrt=$(echo -n $SECRET | tr -d ' ' | tr -d '\n')
echo $jfrt
oc patch secret artifactory-token -p='{"data": {".dockerconfigjson": "'"$jfrt"'"}}'

echo Done
