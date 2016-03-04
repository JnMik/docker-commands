#!/bin/bash

cat << "EOF"



    ____             __                __________                                      __    
   / __ \____  _____/ /_____  _____   / ____/ __ \____ ___  ____ ___  ____ _____  ____/ /____
  / / / / __ \/ ___/ //_/ _ \/ ___/  / /   / / / / __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
 / /_/ / /_/ / /__/ ,< /  __/ /     / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
/_____/\____/\___/_/|_|\___/_/      \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  


 * * * * * * * * * * * * * *  * * *  * * *  * * * *
* Run this command script from the project folder. *
 * * * * * * * * * * * * * *  * * *  * * *  * * * *

            _.._
           (_.-.\         1. Build Docker Image                       (docker build)
       .-,       `        2. Push Docker Image to dockerhub.com       (docker push)
  .--./ /     _.-""-.     3. Composer install                         (Launch composer through a container)
   '-. (__..-"       \    4. Run shell script in a node container     (npm update, gulp build, grunt build etc)
      \          a    |   5. Boot application stack                   (docker-compose up)
       ',.__.   ,__.-'/   6. Reboot application stack                 (docker-compose restart)
         '--/_.'----'`    7. Shutdown application stack               (docker-compose stop && docker-compose rm)
                          8. Show running containers                  (docker ps)
                          9. Show local images                        (docker images)
                          10. Build Docker Image for production       (sh docker/build-docker-image.sh)
                          11. Remove local dangling images (tag=none) (docker rmi $(docker images --quiet --filter "dangling=true"))
                          12. Remove local image by name              (docker rmi -f $(docker images | grep $imagename | awk '{ print $3 }'))
                          13. Login to dockerhub                      (docker login)
                          14. Inspect container property              (docker inspect <container_id>)
                          15. Inspect container logs                  (docker logs -f <container_id> 2>&1 | grep $needle)
                          16. Inspect memory / CPU / IO of containers (docker ps -q | xargs docker stats)


EOF

while [ -z $command ]; do
  printf "\e[1;46mPlease choose a command:\e[0m ";
  read -r command;
done

if [ "$command" = "1" ] || [ "$command" = "2" ]; then

  while [ -z $imagename ]; do
    printf "\e[1;46mEnter the image name for your project:\e[0m ";
    read -r imagename;
  done

  while [ -z $version ]; do
    printf "\e[1;46mEnter the tag of your image:\e[0m ";
    read -r version;
  done

  echo Review Image Name : $imagename : $version;
  echo Current path where the commands will be run : $(pwd);

fi

if [ "$command" = "1" ]; then
  echo -e "\e[1;30;43m-- Starting to build docker image --\e[0m"
  docker build -t $imagename:$version .
  exit 1;
fi

if [ "$command" = "2" ]; then
  
  echo -e "\e[1;30;43m-- Starting to push image to docker hub --\e[0m"
  docker push $imagename:$version

  if [ $? -ne 0 ];
    then
r
      echo -e "\e[0;41mTask push docker image failed and return an non 0 code. Abort!\e[0m";
      exit 2;
    else
      echo -e "\e[0;42mTask psuh docker image successfully executed\e[0m"
  fi


  exit 2;
fi


if [ "$command" = "3" ]; then

  echo -e "\e[1;30;43m-- Starting task install php dependencies --\e[0m"
  docker run -v "$HOME"/.ssh:/root/.ssh -v $(pwd):/app composer/composer install
 
  exit 3;
fi


if [ "$command" = "4" ]; then

  while [ -z $nodeversion ]; do
    printf "\e[1;46mWhich node version:\e[0m ";
    read -r nodeversion;
  done

  while [ -z $shpath ]; do
    printf "\e[1;46mShell script path ?\e[0m ";
    read -r shpath;
  done

  echo -e "\e[1;30;43m-- Starting shell script in node container --\e[0m"
  docker run -ti --rm -v ~/.ssh:/root/.ssh -v $(pwd):/tmp/build -w /tmp/build node:$nodeversion $shpath;
 
  if [ $? -ne 0 ]; 
    then
      echo -e "\e[0;41mShell script  failed: return a $? code response. Abort!\e[0m";
      exit 4;
    else
      echo -e "\e[0;42mTask Shell script ran successfully\e[0m"
  fi

  exit 4;
fi

if [ "$command" = "5" ]; then

  echo -e "Run in background? [y/N]"

  read accept

  if [ "$accept" != "Y" ]; then 
    docker-compose up
    exit 5;
  fi

  docker-compose up -d

  exit 5;
fi


if [ "$command" = "6" ]; then
  docker-compose restart
  exit 6;
fi

if [ "$command" = "7" ]; then

  docker-compose stop
  docker-compose rm

  exit 7;
fi


if [ "$command" = "8" ]; then
  docker ps
  exit 8;
fi

if [ "$command" = "9" ]; then
  docker images
  exit 9;
fi

if [ "$command" = "10" ]; then
  echo -e "\e[0;42mBuild Docker Image.\e[0m";
  sh ./docker/build-docker-image.sh
  exit 10;
fi

if [ "$command" = "11" ]; then
  docker rmi $(docker images --quiet --filter "dangling=true")
  exit 11;
fi

if [ "$command" = "12" ]; then
  while [ -z $removeimagename ]; do
    printf "\e[1;46mEnter image name to remove:\e[0m ";
    read -r removeimagename;
  done
  docker rmi -f $(docker images | grep $removeimagename | awk '{ print $3 }')
  exit 12;
fi

if [ "$command" = "13" ]; then
  docker login
  exit 13;
fi

if [ "$command" = "14" ]; then
  while [ -z $containerid ]; do
    printf "\e[1;46mEnter container ID:\e[0m ";
    read -r containerid;
  done
  docker inspect $containerid
  exit 14;
fi

if [ "$command" = "15" ]; then

  while [ -z $containerid ]; do
    printf "\e[1;46mEnter container ID:\e[0m ";
    read -r containerid;
  done

  printf "\e[1;46mSearching for something in particular ? Enter something or press enter. :\e[0m ";
  read -r needle;

  if [ "$needle" = "" ]; then
    docker logs -f $containerid
    exit 15;
  fi
  docker logs -f $containerid 2>&1 | grep $needle
  exit 15;
fi

if [ "$command" = "16" ]; then
  docker ps -q | xargs docker stats
  exit 16;
fi

