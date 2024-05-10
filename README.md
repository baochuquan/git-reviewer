![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/sketch-images/git-reviewer-02.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-ruby-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![Plugin](http://img.shields.io/badge/plugin-git-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

[简体中文]()

Git Reviewer is a git plugin that solves a common problem in team collaborative development: **Who should review the code changes?**

## Core Feature
We know that git uses two operations, add and delete, to represent code changes. In fact, we can derive a third operation - edit - from the arrangement relationship between add and delete. So, when is it considered an edit? If the delete operation and the add operation are immediately adjacent, we can classify it as an edit operation.

Hence, we get three types of operations: delete, add, edit. Git Reviewer analyzes based on these three operations.

For the delete type, Git Reviewer considers the original author of the deleted line to be the reviewer for each line.

For the edit type, Git Reviewer believes that the newly added content in this part should all be reviewed by the original author of the last deleted line that is immediately adjacent. So, why is it the last deleted line? Because the Myers diff algorithm adopted by git defaults to showing delete operations first, followed by add operations. Therefore, starting from the last deleted line, it is the newly added content that is displayed.

For the add type, Git Reviewer's strategy is based on analysis of the `.gitreviewer.yml` configuration file. The `.gitreviewer.yml` file defines the `project owner`, `folder owner`, and `file owner`. At this point, Git Reviewer will match the newly added lines of the file with the content defined in `.gitreviewer.yml`.

- If the file matches a file owner, then the related new type is prioritized for review by the file owner.
- If the file matches a folder owner, then the related new type is subsequently reviewed by the folder owner.
- If neither of the first two matches the file, then it will be reviewed by the project owner.

Based on the analysis of the three operation types mentioned above, Git Reviewer will eventually generate an analysis table. This table lists information such as the reviewer, the number of files, the file ratio, the number of code lines, and the code line ratio. Git Reviewer suggests recommending and sorting reviewers based on the code line ratio.

Below is an example of the analysis results for the core functionality.

```sh
+------------------------------------------------------------------------+
|                 Suggested reviewers for code changes.                  |
+--------------------+------------+------------+------------+------------+
| Suggested Reviewer | File Count | File Ratio | Line Count | Line Ratio |
+--------------------+------------+------------+------------+------------+
| developerA         | 5          | 50.0%      | 1000       | 50.0%      |
+--------------------+------------+------------+------------+------------+
| developerB         | 3          | 30.0%      | 500        | 25.0%      |
+--------------------+------------+------------+------------+------------+
| developerC         | 2          | 20.0%      | 500        | 25.0%      |
+--------------------+------------+------------+------------+------------+
```

## Additional Feature

Git Reviewer also provides the functionality to analyze the distribution of authors involved in code changes. This feature is relatively simple; it analyzes the original authors of all deleted lines and the current authors of newly added lines. It also presents this information in the form of a table, listing the authors, number of files, file ratio, number of code lines, code line ratio, etc., for users to evaluate and reference.

Below is an example of the analysis results for the additional functionality.

```sh
+--------------------------------------------------------------------+
|             Relevant authors involved in code changes              |
+----------------+------------+------------+------------+------------+
| Related Author | File Count | File Ratio | Line Count | Line Ratio |
+----------------+------------+------------+------------+------------+
| developerA     | 5          | 50.0%      | 2000       | 66.6%      |
+----------------+------------+------------+------------+------------+
| developerB     | 3          | 30.0%      | 500        | 16.7%      |
+----------------+------------+------------+------------+------------+
| developerC     | 2          | 30.0%      | 500        | 16.7%      |
+----------------+------------+------------+------------+------------+
```

## Installation

Git Reviewer can be installed via Homebrew, with the following command.

```sh
$ brew install baochuquan/tap/git-reviewer
```

Alternatively, it can also be installed via Ruby Gem, with the following command.

```sh
$ gem install git-reviewer
```

## Usage
### Initialization
For any Git project, before using Git Reviewer, you should first execute the initialization command in the root directory, as shown below.

```sh
$ git reviewer --init
```

The command will automatically create a `.gitreviewer.yml` file, which defines fields such as `project_owner`, `folder_owner`, and `file_owner`. The latter two are array types, allowing us to define multiple path and owner fields for a more precise division of the project.

In addition, the `.gitreviewer.yml` file includes `ignore_folders` and `ignore_files` fields. These can define a series of directories or files to be excluded from the analysis, thus affecting the analysis results.

Below is an example of a `.gitreviewer.yml` file. You can edit the relevant fields for a more accurate analysis.

```yml
---
project_owner: admin,
folder_owner:
- owner: developerA,
  path: /path/to/folderA
- owner: developerB
  path: /path/to/folderB
 
file_owner:
- owner: developerC
  path: /path/to/fileC
- owner: developerD
  path: /path/to/fileD
 
ignore_files:
- path/to/file1
- path/to/file2
 
ignore_review_folders:
- path/to/folder1
- path/to/folder2
```


### Analyze
Git Reviewer conducts the analysis based on two git branches, namely the source branch and the target branch.

The source branch is the branch where the code modifications are made. By default, Git Reviewer automatically uses the current branch as the source branch. However, it is also possible to specify the source branch using the option `--source=<source-branch>`. Besides the branch name, Git Reviewer also supports Commit IDs.

The target branch is the branch that is intended to be merged into. For this, Git Reviewer provides the related option `--target=<target-branch>`.

Below is an example of the command used to perform analysis with Git Reviewer.

```sh
$ git reviewer --target=main
```

By default, Git Reviewer displays both core and additional functionality analysis results. If we only want to see the results of the core functionality, we can specify the option `--reviewer`; if we only want to see the results of the additional functionality, we can specify the option `--author`.

```sh
$ git reviewer --target=main --reviewer

$ git reviewer --target=main --author
```

To view more analysis information, we can add the `--verbose` option.

```sh
$ git reviewer --target=main --verbose
```

## License
Git Reviewer is licensed under the MIT License.