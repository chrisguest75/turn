# README

```sh
git config commit.template .gitmessage  
```

```sh
git config --list 
git config --local --list    
```


Build a version 
```
cat ./release_notes.gomplate | gomplate > ./output/version1.md
```