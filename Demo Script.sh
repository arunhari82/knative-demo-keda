Basic Serving:
-------------

kn service create hello-knative \
--image="quay.io/naveenkendyala/quarkus-demo-quarkusjvm-hello:v1"

kn service list

export URL=$(kn service list | tail -1 | awk '{print $2}')/api/hello

hey -c 50 -z 10s $URL

kn service update hello-knative --concurrency-limit=10

hey -c 50 -z 10s $URL

oc get kpa

Features: 
---------

Blue/Green Deployments.
-----------------------

kn service create example-svc \
--image quay.io/redhattraining/do244-serving-manage \
--revision-name example-svc-revision-1-blue \
--env TARGET="Revision Blue" -n serving-demo


export URL=$(kn service list | tail -1 | awk '{print $2}')

curl $URL

while true
do
  curl $URL 
  sleep 1
done

kn service update example-svc \
--revision-name example-svc-revision-2-green \
--env TARGET="Revision Green"

Traffic Splitting :
------------------

kn service update example-svc \
--traffic example-svc-revision-1-blue=100

kn service update example-svc \
--traffic example-svc-revision-1-blue=80 \
--traffic example-svc-revision-2-green=20

Show Topology for traffic splits in developer perspective:
Click and chnage
==================================



Eventing :
------------

oc new-project eventing-demo

kn service create event-display1 \
    --image quay.io/openshift-knative/knative-eventing-sources-event-display:latest \
    --scale-window 10s

Ping Source , API Source , Kafka Source    

kn source ping create test-ping-source \
    --schedule "*/1 * * * *" \
    --data '{"message": "Welcome to Knative Eventing!"}' \
    --sink ksvc:event-display1

Eventing:

#Create a new project for kafka cluster
oc new-project amq-streams
#create the cluster
oc create -n amq-streams -f kafka-cluster.yaml

#Create a new project for the demo
oc new-project eventing-demo

kn service create event-display1 \
    --image quay.io/openshift-knative/knative-eventing-sources-event-display:latest \
    --scale-window 10s

kn source ping create test-ping-source \
    --schedule "*/1 * * * *" \
    --data '{"message": "Welcome to Knative Eventing!"}' \
    --sink ksvc:event-display1

#create an in-mem channel from the ui and link to the source and svcs

#add a new kn service and link with the same event
kn service create event-display2 \
    --image quay.io/openshift-knative/knative-eventing-sources-event-display:latest \
    --scale-window=10s

#create a channel for subscription from the ui
kn channel list

#list subscriptions
kn subscription list

kn service create event-display3 \
    --image quay.io/openshift-knative/knative-eventing-sources-event-display:latest \
    --scale-window=10s

#create kafka source from yaml
oc create -f kafkasource.yaml

# generate messages to the demo kafka topic (data source)
oc -n eventing-demo run kafka-producer \
    -ti --image=quay.io/strimzi/kafka:latest-kafka-2.7.0 --rm=true \
    --restart=Never -- bin/kafka-console-producer.sh \
    --broker-list my-cluster-kafka-bootstrap.amq-streams.svc.cluster.local:9092 \
    --topic knative-demo-topic

# create a broker from the UI
kn service create event-display4 \
    --image quay.io/openshift-knative/knative-eventing-sources-event-display:latest \
    --scale-window=10s

# apply filters:
type: rccl.ship.to.shore.event
type: dev.knative.kafka.event




Functions Demo : 
----------------

oc new-project functions-demo

mkdir functions-demo
cd functions-demo

kn func create -l node -t http nodefunc

cd nodefunc
npm install
npm test

kn func build -u -r quay.io/anattama/knative-nodefunc

kn func run


kn func deploy -i quay.io/anattama/knative-nodefunc/nodefunc:latest -n functions-demo


curl https://nodefunc-functions-demo.apps.cluster-qm4ql.qm4ql.sandbox2523.opentlc.com?test=testdata