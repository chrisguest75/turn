#!/usr/bin/env bash

if [[ -f .env ]];then
    echo "* Sourcing local .env"
    . .env
fi 

git log  --pretty=format:"%h %an%x09%s"

echo ""
echo "* Creating version logs"
git log  --pretty=format:"'%h', '%an', '%s'" 162856a..ea5f6b1 > ./output/1.0.txt
git log  --pretty=format:"'%h', '%an', '%s'" ea5f6b1..0ea7306 > ./output/1.1.txt
git log  --pretty=format:"'%h', '%an', '%s'" 0ea7306..acf1304 > ./output/1.2.txt
git log  --pretty=format:"'%h', '%an', '%s'" acf1304..58ee502 > ./output/1.3.txt
git log  --pretty=format:"'%h', '%an', '%s'" 58ee502..5144e24 > ./output/2.0.txt
git log  --pretty=format:"'%h', '%an', '%s'" 5144e24..7130ef6 > ./output/2.1.txt
git log  --pretty=format:"'%h', '%an', '%s'" 7130ef6..ab4ffc5 > ./output/2.2.txt

echo "* Building version markdown"
for filename in ./output/*.txt; do
    version=$(basename ${filename} .txt)
    echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}'}" | gomplate --file ./release_notes.gomplate -c version=stdin:///in.json -c .=${filename} > ./output/${version}.md  
done

echo "* Building final markdown"
echo "# RELEASE NOTES" > RELEASE_NOTES.md
for filename in $(ls ./output | grep md | sort -Vr); do
    cat "./output/${filename}" >> RELEASE_NOTES.md
done

