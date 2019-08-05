#!/bin/bash

echo "Deploying on Region $AWS_REGION"

#######################
# Run Terraform APPLY #
#######################
if [ "$ACTION" == "terraform apply" ];
then
  echo "Performing Terraform Apply"
  rm -rf terraform-test2
  git clone https://github.com/yonikashi/terraform-test2.git
  mv terraform-test2 terraform-test-2-$SUF
  JOB_FOLDER=terraform-test-2-$SUF
  cd $JOB_FOLDER
  #git pull origin master

########################################
# Define AWS Credentials for Terraform #
########################################
rm -rf $WORKSPACE/$JOB_FOLDER/credentials
echo [default] >> $WORKSPACE/$JOB_FOLDER/credentials
echo aws_access_key_id = $AWSKEY >> $WORKSPACE/$JOB_FOLDER/credentials
echo aws_secret_access_key = $AWSSEC >> $WORKSPACE/$JOB_FOLDER/credentials

aws configure set aws_access_key_id $AWSKEY
aws configure set aws_secret_access_key $AWSSEC
aws configure set region $AWS_REGION

echo "Using the following Variables:"
#####################################
# Define Variables for Terraform   ##
#####################################
rm terraform.tfvars
touch terraform.tfvars

echo aws_region = "\"$AWS_REGION"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars

echo NODENAME = "\"nodename"\"
echo SUFFIX = "\"$SUF"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
echo VPC_CIDR = "\"$VPC_PREFIX"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
echo job_workspace = "\"$WORKSPACE"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
echo job_folder = "\"$JOB_FOLDER"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
echo DB_USER  = "\"stellar"\"
echo DB_PASS  = "\"defaultpassword"\"
echo DB_NAME  = "\"core"\"
echo DB_IDENTIFIER  = "\"stellar-core-db"\"
#####################################
#      Images Params Override       #
#####################################

#echo test_core_1_ami = "\"$Core_1_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_core_2_ami = "\"$Core_2_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_core_3_ami = "\"$Core_3_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_core_4_ami = "\"$Core_4_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_core_5_ami = "\"$Core_5_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo horizon_1_ami = "\"$Horizon_1_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo prometheus = "\"$Prometheus_ami"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_watcher_core_1_ami = "\"$test_watcher_core_1_ami"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#echo test_load_client_ami = "\"$test_load_client_AMI"\" >> $WORKSPACE/$JOB_FOLDER/terraform.tfvars
#######################################

terraform init
terraform plan
fi

########################
# Run Terraform DESTROY#
########################

if [ "$ACTION" == "terraform destroy" ];
then
echo "Performing Terraform Destroy"
JOB_FOLDER=terraform-test-2-$SUF
cd $JOB_FOLDER
#REMOVE VPC Peering between Production-Vpc and Stellar-Vpc
OPEER1=$(terraform output -json aws_prod_peer)
PEER1=`echo $OPEER1 | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
#echo "Prod Peering is: $PEER1 connecting to: rtb-0e0cadd5d7d99912c"
aws ec2 delete-route --route-table-id rtb-0e0cadd5d7d99912c --destination-cidr-block $VPC_PREFIX.0.0/16
# VPC Peering between Managment-Vpc and Testing-Vpc
OPEER2=$(terraform output -json aws_mgmt_peer)
PEER2=`echo $OPEER2 | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
#echo "Managment Peering is: $PEER2 connecting to: rtb-02b0af60079a2b99c "
aws ec2 delete-route --route-table-id rtb-02b0af60079a2b99c --destination-cidr-block $VPC_PREFIX.0.0/16
fi

#######################
                      #
##################### #
# Fire Terraform    # #
##################### #
$ACTION -auto-approve #
#######################

if [ "$ACTION" == "terraform apply" ];
then
############################################
# Update RT for SSH and Jenkins connection #
############################################
# VPC Peering between Production-Vpc and Stellar-Vpc
OPEER1=$(terraform output -json aws_prod_peer)
PEER1=`echo $OPEER1 | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
echo "Prod Peering is: $PEER1 connecting to: rtb-0e0cadd5d7d99912c"
aws ec2 create-route --route-table-id rtb-0e0cadd5d7d99912c --destination-cidr-block $VPC_PREFIX.0.0/16 --gateway-id $PEER1
# VPC Peering between Managment-Vpc and Testing-Vpc
OPEER2=$(terraform output -json aws_mgmt_peer)
PEER2=`echo $OPEER2 | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
echo "Managment Peering is: $PEER2 connecting to: rtb-02b0af60079a2b99c "
aws ec2 create-route --route-table-id rtb-02b0af60079a2b99c --destination-cidr-block $VPC_PREFIX.0.0/16 --gateway-id $PEER2

#######################################
#Check if all nodes are up and synced #
#######################################

echo "Test Client IP is:"
terraform output -json aws_test_client_ip

echo "Prometheus DNS is"
terraform output -json aws_prom_dns


TEST_CLIENTIP=$(terraform output -json aws_test_client_ip)
PROM=$(terraform output -json aws_prom_dns)
PROMETHEUS_URL=`echo $PROM | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`

#PROMETHEUS_URL=$PROMETHEUS_URL | tr -d '"'
echo "PARAM: Prometheus DNS is: $PROMETHEUS_URL"
echo "PARAM: Test Client IP is: $TEST_CLIENTIP"

#export test client IP to be able to access it from the laod test
echo $TEST_CLIENTIP > /tmp/test-client-ip-$SUF

TEST_CLIENT_IP=`echo $TEST_CLIENTIP | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
echo "Querying Prometheus for Status before running tests"

while [[ $status != "6" ]]; do
    echo "Cores not ready yet! still waiting for them..."
    sleep 2
    stat=$(curl -s http://$PROMETHEUS_URL:9090/api/v1/query?query=count\(core_metrics_custom_app_state_synced_synced\) | jq '.data.result[0].value[1]')
    status=`echo $stat | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
    echo "Number of Ready Cores is: $status out of 6"
done

echo "Enviroment is ready for Tests - SUCCESS"
fi
