#!/bin/sh
export GCRYPT_FULL_REPACK=True

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
mkdir gcrypt_remote
cd gcrypt_remote
git init --bare
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

## local2
echo "===================   LOCAL2"
cd $tmp_dir
git clone gcrypt::$tmp_dir/gcrypt_remote gcrypt_local2
cd gcrypt_local2
git config remote.origin.gcrypt-participants "$gpg_key"
git config remote.origin.gcrypt-history true

echo "z" > z
git add *
git commit -m "added z"
git push

## add stuff to local1
echo "===================   ADD LOCAL1"
cd $tmp_dir
cd gcrypt_local
git pull

echo "b" > b
git add *
git commit -m "added b"
git push

rm -rf $tmp_dir
