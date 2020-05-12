# README
![Docker Image CI](https://github.com/chrisguest75/turn/workflows/Docker%20Image%20CI/badge.svg)

**TURN** - 'Totally' Uniform Release Notes. 

Demonstrates a way to produce release notes for a repo. 
It also handles formatting notes for Slack posting and can be used as part of a CI process to notify of changes before a deployment

## Examples 
[DEPLOYMENTS.md](./DEPLOYMENTS.md)  
[RELEASE_NOTES.md](./RELEASE_NOTES.md)

## Run latest from dockerhub
Run the image from DockerHub
```sh
docker run -it --rm -v $(pwd):/repo chrisguest/turn:latest --action=create --type=release --tags  --envfile=./.env.template
docker run -it --rm -v $(pwd):/repo chrisguest/turn:latest --action=create --type=deployment --tags  --envfile=./.env.template
```

## Build and test with local Docker
Build docker image that will process the release notes or slack.  
```sh
# During build it will run tests as well (use --no-cache to force rerun)
docker build -t turn .  

# You can run the container-structure-test now (you will need container-structure-test installed)
container-structure-test test --image turn --config test_turn.yaml

# Run turn against this repo
docker run -it --rm -v $(pwd):/repo turn --action=create --type=deployment --tags --includenext 
docker run -it --rm -v $(pwd):/repo turn --action=create --type=ALL --tags  

# Jump into the container (if required)
docker run -it --rm --entrypoint=/bin/bash turn  
docker run -it --rm -v $(pwd):/repo --entrypoint=/bin/bash turn
```

## Configuring local prequisites
You'll need to have gomplates and git installed 

Gomplates is available on all major package managers. 
```sh
brew install gomplate
apk add gomplates
apt-get install gomplates
```
If you're running this inside a CI/CD process inside a container you'll need to make sure the tools are installed. 

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

## Development
Read the tests [README.md](./test/README.md)

Running the test suite 
```sh
./run_tests.sh
```

## Manual tests 

```sh
# Test building notes with from tags
 ./generate.sh --action=create --type=ALL --tags

 # Test building notes with from ranges 
 ./generate.sh --action=create --type=ALL 

 ```

## TODO:
This is a list of notes of development work todo.  Probably should add "convert todo to issues" to it.  

* Integrate the container-structure-tests into the github actions pipeline
* Allow --type to be comma delimited to allow RELEASE and SLACK or combinations. 
* Improve how rollbacks are described as it can be confusing.
* test tags to ranges.
* Specify a range.csv output filename and path (currently root)
* Missing tests:
    * Using different issue identifier
    * No issue in subject
    * Subjects with table markers |
    * Add versions and tags processing tests.
    * Test tags to ranges.
* Can I get bats core into junit format? 
* batscore docker with gomplate and sort -V dependency. 
* Detect overlapping ranges. 
* Add a common template that is included to process the input file.
* Hyperlink the circle work flow in metadata 
* Add a githook for validating the commit format. 
* Add circleci plugins to pull deployments.... 
* Limit generation to particular branch.
* Add a pullrequest template https://help.github.com/en/github/building-a-strong-community/creating-a-pull-request-template-for-your-repository
