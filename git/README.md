# git

## git_commit_file.sh

Code to change to a git initialized repo, commit individual files or files in that folder with changes and commit with a particular commit message

### Setup

Just requires `git` to be installed

### Usage

As an example, Add the following to your ~/.bash_profile or ~/.zshrc (whichever rc file you use based on your shell) if you would like to automatically commit all changes in folder `~/opt/my-maps` with commit message `added notes`:
```
commit_maps() {
    /bin/bash ~/opt/mycode_public/git/git_commit_file.sh commit ~/opt/my-maps "added notes"
}
```

Then run `commit_maps` to execute the script
