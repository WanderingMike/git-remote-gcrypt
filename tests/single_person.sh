#!/bin/sh

# Set up
local_dir=$(dirname $(realpath $0))
tmp_dir="/tmp/TEST_ENV_$$"
cd "/tmp"
mkdir "TEST_ENV_$$"
cd $tmp_dir
gpg_key=$(gpg --list-public-keys --with-colons \
		| sed -ne '/^pub:/,/^fpr:/ { /^fpr:/ p }' \
		| cut -d: -f10 \
		| head -1)

## remote
echo "===================   REMOTE"
mkdir gcrypt_remote
cd gcrypt_remote
git init --bare
echo "cat $local_dir/../pre-receive"
cp $local_dir/../pre-receive $tmp_dir/gcrypt_remote/hooks/pre-receive

## local
echo "===================   LOCAL"
cd $tmp_dir
git init gcrypt_local
cd gcrypt_local
git remote add origin gcrypt::$tmp_dir/gcrypt_remote
git config remote.origin.gcrypt-participants "$gpg_key"
git config remote.origin.gcrypt-history true

echo "a" > a
git add *
git commit -m "added a"
git push --set-upstream origin master

echo b > b
git add *
git commit -m "added b"
git push

echo c > c
git add *
git commit -m "added c"
git push

rm -rf $tmp_dir
