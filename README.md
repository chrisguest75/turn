# README

```sh
git config commit.template .gitmessage  
```

```sh
git config --list 
git config --local --list    
```


Build a version 

TODO: 
    * The first commit is not included

```
git log  --pretty=format:"'%h', '%an', '%s'" 
git log  --pretty=format:"'%h', '%an', '%s'" 162856a..ea5f6b1 > ./output/version1.txt
git log  --pretty=format:"'%h', '%an', '%s'" ea5f6b1..0ea7306 > ./output/version2.txt
cat ./release_notes.gomplate | gomplate > ./output/version1.md
```

Amending commits where you have forgot to add the ticket.
```
git commit --amend
```