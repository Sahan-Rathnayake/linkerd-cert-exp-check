#!/bin/bash

set -e
set -x

curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
mv kubectl /usr/bin/kubectl
chmod +x /usr/bin/kubectl

kubectl get secret -n ${LINKERD_NAMESPACE} | grep "kubernetes.io/tls" | awk '{print $1}' > certificate-list.txt

while read CERTIFICATE
do
	read -ra DATE_ARR <<< `kubectl get secret "$CERTIFICATE" -n ${LINKERD_NAMESPACE} -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -enddate -noout | cut -d "=" -f 2-`
	echo "Expiration Date > ${DATE_ARR[@]}"
	REMAINDER=`echo $(date -d "${DATE_ARR[0]} ${DATE_ARR[1]} ${DATE_ARR[3]}" +%s) $(date -d "${date}" +%s) | awk '{print ($1 - $2)/86400}'`
	echo "Remaining Days > $REMAINDER"

	if [ $REMAINDER -lt 45 $THRESHOLD ]
	then
		aws sns publish --region $AWS_REGION --topic-arn $TOPIC_ARN --subject $SUBJECT --message $MESSAGE
	fi
done < certificate-list.txt
