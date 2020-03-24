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
cat ./release_notes.gomplate | gomplate > ./version1.md
```