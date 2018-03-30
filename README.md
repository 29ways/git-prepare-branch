# git-prepare-branch

This tool is for developers who prefer to use interactive rebasing to prepare
their branches for code review and merging. It provides a wrapper around some
git commands along with shortcut keys.

## Installation

Currently installation is via rubygems

```
gem install git-prepare-branch
```

## Usage

With your feature branch checked out and assuming you are merging into master

```
git prepare-branch
```

If you are merging into another branch run

```
git prepare-branch some-other-branch
```

You will then see a log of all the commits to be merged.

Pressing `?` will bring up a list of the available command keys. They array_to_sentence_string

```
f   filter files     Filters commits to just those affected files that match the specified filter

r   begin rebase     Start an interactive rebase

s   show             Show a specific commit

d   sum diff         Show the combined diff from one SHA to another (inclusive)

v   cycle view       Cycles through applying different view options to the list of commits
```

If you pause mid rebase - for example if you have chosen to edit a commit - there are a different set of commands available

```
a   abort rebase        Abort the current rebase

c   continue rebase     Continue with the current rebase
```

If you pause mid rebase and there are conflicts detected, another set of commands are available

```
a   abort rebase           Abort the current rebase

m   show my changes        Show the diff of the content in this branch causing the conflict

t   show other commits     Show the commits that may have introduced the conflicting changes

o   show other diff        Show the combined diff of the commits that may have introduced the change

d   show diff              Show the diff of the conflicts
```

## What are the actual git commands being run?

The entire set of commands are defined in [bin/git-prepare-branch](bin/git-prepare-branch).
The rest of the code in the application is to allow for the interface and the declarative DSL.