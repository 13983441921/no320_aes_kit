#! /bin/bash

rm -rf No320Aes256.class if [ -f "No320Aes256.class" ]

javac -Djava.ext.dirs=./lib No320Aes256.java

java -Djava.ext.dirs=./lib No320Aes256 

 