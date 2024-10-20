# copy_git_history

## Description
This script transfers all Git history from one repository to another. It clones the source repository, changes the origin to the destination repository, and pushes all history and tags to the destination repository. If the destination repository is not empty, the script prompts the user to confirm whether they want to force the push, which will overwrite all existing data in the destination repository.

### Usage 
```
./move_git_history.sh <source_repo_url> <destination_repo_url>
```

### Arguments

- <source_repo_url>:      URL of the source repository whose history needs to be transferred.
- <destination_repo_url>: URL of the destination repository where the history needs to be transferred


### Example
```
./move_git_history.sh https://github.com/user/source-repo.git https://github.com/user/destination-repo.git
```

### Features

- Clones the source repository.
- Changes the origin to the destination repository.
- Pushes all history and tags to the destination repository.
- Checks if the destination repository is empty.
- Prompts the user to confirm whether they want to force the push if the destination repository is not empty.


### Warning

If the destination repository is not empty and the user chooses to force the push, all existing data in the destination repository will be lost.

### Author

- Ycaro02

### License

- This script is licensed under the MIT License.