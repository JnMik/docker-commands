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
         '--/_.'----'`    7. Hard Reboot application stack            (docker-compose stop / rm / rmi -f / up -d)
                          8. Shutdown application stack               (docker-compose stop)
                          9. Hard Shutdown application stack          (docker-compose stop && docker-compose rm)
                          10. Show running containers                 (docker ps)
                          11. Show local images                       (docker images)
                          12. Build Docker Image for production       (sh docker/build-docker-image.sh)
                          13. Remove local dangling images (tag=none) (docker rmi $(docker images --quiet --filter "dangling=true"))
                          14. Remove local image by name              (docker rmi -f $(docker images | grep $imagename | awk '{ print $3 }'))
                          15. Login to dockerhub                      (docker login)
                          16. Inspect container properties            (docker inspect <container_id>)
                          17. Inspect container logs                  (docker logs -f <container_id> 2>&1 | grep $needle)
                          18. Inspect memory / CPU / IO of containers (docker ps -q | xargs docker stats)
                          19. Delete all stopped containers           (docker rm $(docker ps -a -q))
                          20. Delete all images                       (docker rmi -f $(docker images))
                          21. Delete all containers                   (docker rm -f $(docker ps -a)))
                          22. Run command on all containers           (Loop through every containers for <image_name> and run command with docker exec)
                          23. Kill all containers by name           (docker kill $(docker ps | grep $needle) && docker rm -f $(docker ps | grep $needle))

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
  exit 0;
fi

if [ "$command" = "2" ]; then
  
  echo -e "\e[1;30;43m-- Starting to push image to docker hub --\e[0m"
  docker push $imagename:$version

  if [ $? -ne 0 ];
    then
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
 
  exit 0;
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

  exit 0;
fi

if [ "$command" = "5" ]; then

  echo -e "Run in background? [Y/n]"

  read accept

  if [ "$accept" != "Y" ]; then 
    docker-compose up
    exit 0;
  fi

  docker-compose up -d

  exit 0;
fi


if [ "$command" = "6" ]; then
  docker-compose restart
  exit 0;
fi

if [ "$command" = "7" ]; then
  while [ -z $removeimagename ]; do
    printf "\e[1;46mEnter image name to remove:\e[0m ";
    read -r removeimagename;
  done
  docker-compose stop
  docker-compose rm
  docker rmi -f $(docker images | grep $removeimagename | awk '{ print $3 }')
  docker-compose up -d

  exit 0;
fi

if [ "$command" = "8" ]; then
  docker-compose stop
  exit 0;
fi


if [ "$command" = "9" ]; then
  docker-compose stop
  docker-compose rm
  exit 0;
fi


if [ "$command" = "10" ]; then
  docker ps
  exit 8;
fi

if [ "$command" = "11" ]; then
  docker images
  exit 0;
fi

if [ "$command" = "12" ]; then
  echo -e "\e[0;42mBuild Docker Image.\e[0m";
  sh ./docker/build-docker-image.sh
  exit 0;
fi

if [ "$command" = "13" ]; then
  docker rmi -f $(docker images --quiet --filter "dangling=true")
  exit 0;
fi

if [ "$command" = "14" ]; then
  while [ -z $removeimagename ]; do
    printf "\e[1;46mEnter image name to remove:\e[0m ";
    read -r removeimagename;
  done
  docker rmi -f $(docker images | grep $removeimagename | awk '{ print $3 }')
  exit 0;
fi

if [ "$command" = "15" ]; then
  docker login
  exit 0;
fi

if [ "$command" = "16" ]; then
  while [ -z $containerid ]; do
    printf "\e[1;46mEnter container ID:\e[0m ";
    read -r containerid;
  done
  docker inspect $containerid
  exit 0;
fi

if [ "$command" = "17" ]; then

  while [ -z $containerid ]; do
    printf "\e[1;46mEnter container ID:\e[0m ";
    read -r containerid;
  done

  printf "\e[1;46mSearching for something in particular ? Enter something or press enter. :\e[0m ";
  read -r needle;

  if [ "$needle" = "" ]; then
    docker logs -f $containerid
    exit 0;
  fi
  docker logs -f $containerid 2>&1 | grep $needle
  exit 0;
fi

if [ "$command" = "18" ]; then
  docker ps -q | xargs docker stats
  exit 0;
fi

if [ "$command" = "19" ]; then
  docker rm $(docker ps -a -q)
  exit 0;
fi


if [ "$command" = "20" ]; then
  docker rmi -f $(docker images)
  exit 0;
fi


if [ "$command" = "21" ]; then
  docker rm -f $(docker ps -a)
  exit 0;
fi

if [ "$command" = "22" ]; then
  while [ -z $imagename ]; do
    printf "\e[1;46mEnter image name for containers your want to execute the command, wilcard accepted.:\e[0m ";
    read -r imagename;
  done
  while [ -z "$commandtorun" ]; do
    printf "\e[1;46mEnter command you want to run in containers:\e[0m ";
    read -r commandtorun;
  done

  CONTAINER_ID=($(docker ps | grep $imagename | awk '{ print $1 }'))

  echo "List of containers where the command will be run:"

  for i in "${CONTAINER_ID[@]}"
  do
    echo "$i"
  done

  echo -e "Launching command $commandtorun in all containers from image $imagename? [Y/n]"

  read accept

  if [ "$accept" != "Y" ]; then
    exit 0;
  fi

  for i in "${CONTAINER_ID[@]}"
  do
    docker exec -it $i $commandtorun
  done

  exit 0;
fi

if [ "$command" = "23" ]; then

  while [ -z $imagename ]; do
    printf "\e[1;46mEnter image name for containers your want to execute the command, wilcard accepted.:\e[0m ";
    read -r imagename;
  done

  CONTAINER_ID=($(docker ps | grep $imagename | awk '{ print $1 }'))

  echo "List of containers to kill:"

  for i in "${CONTAINER_ID[@]}"
  do
    echo "$i"
  done

  echo -e "Kill all containers from image $imagename? [Y/n]"

  read accept

  if [ "$accept" != "Y" ]; then
    exit 0;
  fi

  for i in "${CONTAINER_ID[@]}"
  do
    docker kill $i && docker rm -f $i
  done

  exit 0;
fi

