#!/bin/bash
# Script para probar las alarmas de CloudWatch 

aws deploy get-deployment-group --application-name mi-app \
  --deployment-group-name produccion --region us-east-1 \
  --query 'deploymentGroupInfo.{alarmas:alarmConfiguration,rollback:autoRollbackConfiguration}'


sleep 30

aws cloudwatch describe-alarms --alarm-names gh-alb-5xx --region us-east-1 \
  --query 'MetricAlarms[0].{estado:StateValue,razon:StateReason}'

aws cloudwatch set-alarm-state --alarm-name gh-alb-5xx \
  --state-value ALARM --state-reason "Prueba manual" --region us-east-1


DNS=$(terraform output -raw alb_dns_name)
for _ in $(seq 1 60); do
  curl -s -o /dev/null -w "%{http_code} " "http://$DNS/api/health"; sleep 1
done; echo


aws cloudwatch describe-alarms --alarm-names gh-alb-5xx --region us-east-1 \
  --query 'MetricAlarms[0].{estado:StateValue,razon:StateReason}'
  