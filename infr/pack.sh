ecrAcc=$1
ecrRepo=$2

tmpLog="tmp.log"

cd app

cat >> "Dockerfile" << EOF
FROM nginx:latest
RUN apt-get update
RUN apt-get install -y curl
COPY . /usr/share/nginx/html
EXPOSE 80
EOF

ecrlogin=$(aws ecr get-login --no-include-email --region us-east-2)
sudo $ecrlogin

sudo docker build -t ${ecrAcc}/${ecrRepo} . > "${tmpLog}"
cat "${tmpLog}"
grep -q "Successfully built" ""${tmpLog}""
if [ $? -ne 0 ]; then {
    echo "Docker has been built with error"
    exit 1
} else {
    echo "Docker has been built successfully"
    rm -f "${tmpLog}"
    }
fi

sudo docker push ${ecrAcc}/${ecrRepo}:latest > "${tmpLog}"
cat "${tmpLog}"
grep -q "digest" ""${tmpLog}""
if [ $? -ne 0 ]; then {
    echo "Docker image has been pushed with error"
    exit 1
} else {
    echo "Docker image has been pushed successfully"
    rm -f "${tmpLog}"
}
fi
