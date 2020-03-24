#!/usr/bin/env bash

git log  --pretty=format:"%h %an%x09%s"

git log  --pretty=format:"'%h', '%an', '%s'" 162856a..ea5f6b1 > ./output/1.0.txt
git log  --pretty=format:"'%h', '%an', '%s'" ea5f6b1..0ea7306 > ./output/1.1.txt
git log  --pretty=format:"'%h', '%an', '%s'" 0ea7306..acf1304 > ./output/1.2.txt

for filename in ./output/*.txt; do
    version=$(basename ${filename} .txt)
    cat ${filename} | gomplate --file ./release_notes.gomplate -c .=stdin://${version}.txt > ./output/${version}.md  
done

cat ./output/*.md > RELEASE_NOTES.md