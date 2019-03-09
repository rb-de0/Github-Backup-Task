#!/bin/bash

access_token=xxxxxxx

dir_name=Github_Backup_$(date +%Y%m%d_%H)

mkdir $dir_name
cd $dir_name

json=$(curl -Ss -H "Authorization: token $access_token" https://api.github.com/user/repos)
len=$(echo $json | jq length)

for i in $( seq 0 $(($len - 1)) ); do
  ssh_url=$(echo $json | jq -r .[$i].ssh_url)
  name=$(echo $json | jq -r .[$i].name)

  git clone -q $ssh_url
  cd $name

  for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
    git branch --track ${branch#remotes/origin/} $branch 2>&1
  done

  cd ..
done

cd ..
zip -r $dir_name.zip $dir_name
rm -rf $dir_name
