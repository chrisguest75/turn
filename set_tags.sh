#!/usr/bin/env bash 

function set_tags() {
    git tag -a -m "Initial commit" 0.0.0 162856a
    git tag -a -m "Example table in markdown" 0.1.0 ea5f6b1
    git tag -a -m "Add gitignore for output folder" 0.1.1 0ea7306
    git tag -a -m "Template contains a list of commits" 0.1.2 acf1304
    git tag -a -m "Working gomplates and concatentate to build release notes" 0.1.3 58ee502
    git tag -a -m "Add version number to the headings" 0.2.0 5144e24
    git tag -a -m "Reverse order of versions in release notes" 0.2.1 7130ef6
    git tag -a -m "Fixed tables in markdown" 0.2.2 ab4ffc5
    git tag -a -m "Bugs fixes" 0.2.17 8de801d
    git tag -a -m "Add deployment style output" 0.2.20 5943833
    git tag -a -m "Fix the line ending for worm hesd on deployments" 0.2.21 acf8d2b
    git tag -a -m "Environment variable setting for issue tracking links" 0.2.22 24781ca
    git tag -a -m "Multi issue subject lines" 0.3.0 6e6b77c
    git tag -a -m "Refactoring" 0.3.1 25b9955
    git tag -a -m "Add external ranges and support for tags" 0.3.2 43ac9b1
    git tag -a -m "Demonstration of release process" 0.3.3 f0b2f1f
    git tag -a -m "Fix the code for tags changes, add --no-pager" 0.3.4 c67ef63    
    git tag -a -m "batscore testing" 0.3.5 c4a715d   
    git push --tags
}

set_tags