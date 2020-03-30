# README
Demonstrates a way to produce release notes for a repo. 

## Prequisites
You'll need to have gomplates installed 

```sh
brew install gomplate
```

## TODO: 
* The first commit is not included  
* Add a githook for validating the commit format. 
* Add tags and circleci plugins to pull deployments.... 
* Limit generation to particular branch.
* Add a pullrequest template https://help.github.com/en/github/building-a-strong-community/creating-a-pull-request-template-for-your-repository
* Use a temp directory to build if required - rather than output. 
* notes directory
* Detect #LGH-xxxx or #xxxx - switch the format based on input value provide this in .env file


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

