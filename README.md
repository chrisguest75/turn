# README
![Docker Image CI](https://github.com/chrisguest75/turn/workflows/Docker%20Image%20CI/badge.svg)

**TURN** - 'Totally' Uniform Release Notes. 

Demonstrates a way to produce release notes for a repo. 
It also handles formatting notes for Slack posting and can be used as part of a CI process to notify of changes before a deployment

## Prequisites
You'll need to have gomplates and git installed 

Gomplates is available on all major package managers. 
```sh
brew install gomplate
apk add gomplates
apt-get install gomplates
```

If you're running this inside a CI/CD process in a container you'll need to make sure the tools are installed. 

## Examples 
[DEPLOYMENTS.md](./DEPLOYMENTS.md)  
[RELEASE_NOTES.md](./RELEASE_NOTES.md)

## TODO: 
* If no ranges or tags make next have a range for the whole repo.  
* Specify a range.csv filename
* Package for homebrew 
* Package for deb. 
* Add a git action to build.
* Missing tests:
    * Using different issue identifier
    * No issue in subject
    * Subjects with table markers |
    * Add versions and tags processing tests.
    * Test tags to ranges.
* Can I get bats core into junit format? 
* batscore docker with gomplate and sort -V dependency. 
* Somehow detect overlapping ranges. 
* Add a common template that is included to process the input file.
* Handle rollbacks
* Hyperlink the circle work flow in metadata 
* Add a githook for validating the commit format. 
* notes directory
* Add circleci plugins to pull deployments.... 
* Limit generation to particular branch.
* Add a pullrequest template https://help.github.com/en/github/building-a-strong-community/creating-a-pull-request-template-for-your-repository

## Initiate the repo
Copy the .gitmessage and install into the local reop.  This can be done globally.  But then it affects all repos. 

```sh
git config commit.template .gitmessage  
```

When you look at your config you should now see it.  
```sh
git config --list 
git config --local --list    
```

You can also verify in VSCode by opening the repo directory and looking at the Source Control template commit.  

## Committing 
You can create an example commit by filling in the template. 

It contains fields for Subject, Problem, Solution, Notes.  You should also include the ticket in the subject as this is the line used to build the notes. 

```
Subject (50 chars) (#include ticket) 

Problem (Reason for Commit)
Solution (List of Changes)
Notes (Special Instructions, Testing Steps, etc)
```

## Build release notes 
Running the ./generate.sh will list out the current commits. 

```sh
# generate RELEASE_MOTES.md & DEPLOYMENTS.md
./generate.sh --action=create --type=ALL

# generate RELEASE_MOTES.md
./generate.sh release
./generate.sh --action=create --type=release

# generate DEPLOYMENTS.md
./generate.sh --action=create --type=deployment -o=../outputfolder

# generate DEPLOYMENTS.md using tags
./generate.sh --action=create --type=deployment -o=../outputfolder --tags
```

Versions are listed as ranges in the [./ranges.csv](./ranges.csv) file.  These are then reverse sorted and added to the [RELEASE_NOTES.md](./RELEASE_NOTES.md)  
```sh
162856a, ea5f6b1, 1.0
ea5f6b1, 0ea7306, 1.1
0ea7306, acf1304, 1.2
acf1304, 58ee502, 1.3
```

## Amending commits
Amending commits where you have forgot to add the ticket.
```sh
git commit --amend
```

## Debugging Templates Hint
Clean the ./output directory and comment out all but one of the git log outputs.
This makes the script run faster and allows quick testing of template modifications

## Build Docker
Build docker image that will process the release notes or slack.  
```sh
# During build it will run tests as well 
docker build -t turn .  
docker run -it --rm --entrypoint=/bin/bash turn  
docker run -it --rm -v $(pwd):/repo --entrypoint=/bin/bash turn
docker run -it --rm -v $(pwd):/repo turn --action=create --type=deployment --tags --includenext 
docker run -it --rm -v $(pwd):/repo turn --action=create --type=ALL --tags  
```
