#!/bin/bash

set -e
set -x

while getopts e:p:t: PARAMETER
do
	case "${PARAMETER}" in
		e) ENVIRONMENT=${OPTARG};;
		p) PROJECT=${OPTARG};;
		t) TOPIC_ARN=${OPTARG};;
	esac
done

kubectl get secret -n linkerd | grep "kubernetes.io/tls" | awk '{print $1}' > certificate-list.txt

while read CERTIFICATE
do
	read -ra DATE_ARR <<< `kubectl get secret "$CERTIFICATE" -n linkerd -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -enddate -noout | cut -d "=" -f 2-`
	echo "Expiration Date > ${DATE_ARR[@]}"
	REMAINDER=`echo $(date -d "${DATE_ARR[0]} ${DATE_ARR[1]} ${DATE_ARR[3]}" +%s) $(date -d "${date}" +%s) | awk '{print ($1 - $2)/86400}'`
	echo "Remaining Days > $REMAINDER"

	if [ $REMAINDER -lt 45 ]
	then
		aws sns publish --region "ap-southeast-1" --topic-arn "$TOPIC_ARN" --subject "Linkerd certificate expiration in $PROJECT-$ENVIRONMENT" --message "Linkerd certificate $CERTIFICATE in $PROJECT-$ENVIRONMENT will expire in $REMAINDER days"
	fi
done < certificate-list.txt
