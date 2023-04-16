oc new-project eventing-demo
kn service create invoice-service-display --image quay.io/openshift-knative/knative-eventing-sources-event-display --label app.kubernetes.io/part-of=broker-demo -n eventing-demo
kn service create order-service-display --image quay.io/openshift-knative/knative-eventing-sources-event-display  --label app.kubernetes.io/part-of=broker-demo -n eventing-demo