![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/sketch-images/git-reviewer-02.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-ruby-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![Plugin](http://img.shields.io/badge/plugin-git-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

[English](README.md)

Git Reviewer 是一款 git 插件，其解决了团队协作开发时普遍存在的一个问题：**代码改动应该由谁来进行代码审查？**

## 核心功能

我们知道 git 使用新增和删除两种操作来表示代码改动。事实上，我们还可以从新增和删除两种操作的编排关系中得出第三种操作——编辑。那么什么情况下算是编辑呢？如果删除操作和新增操作相互紧邻，那么我们可以将其归为编辑操作。

由此，我们得到三种操作类型：删除、新增、编辑。Git Reviewer 正是基于这三种操作进行分析的。

对于删除类型，Git Reviewer 认为删除行的原始作者应该作为每一行的审查者。

对于编辑类型，Git Reviewer 认为此部分中的新增内容应该全部由紧邻的最后删除行的原始作者作为审查者。注意，为什么是最后删除行？因为 Git 所采用的 Myers 差分算法默认差分内容优先展示删除操作，其次才是新增操作。因此，从最后的删除行开始，展示的是新增的内容。

对于新增类型，Git Reviewer 的策略是基于 `.gitreviewer.yml` 配置文件进行分析。`.gitreviewer.yml` 文件定义了项目所有者 `project owner`、目录所有者 `folder owner`、文件所有者 `file owner`。此时，Git Reviewer 会对新增行的文件与 `.gitreviewer.yml` 所定义的内容进行匹配。

- 如果该文件匹配到了文件所有者，那么相关新增类型优先由文件所有者审查。
- 如果该文件匹配到了目录所有者，那么相关新增类型其次由目录所有者审查。
- 如果前两者均没有匹配该文件，那么将由项目所有者来进行审查。

基于对上述三种操作类型进行分析，Git Reviewer 最终将生成一个分析表格，其中罗列了审查者、文件数量、文件占比、代码行数量、代码行占比等信息。Git Reviewer 建议以代码行占比为依据，对审查者进行推荐排序。

如下所示，为核心功能的分析结果示例。

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

## 附加功能
Git Reviewer 还提供了分析代码改动的所涉及的作者分布的功能。此功能相对简单，其分析了所有删除行的原始作者和新增行的现有作者，并同样以表格的形式呈现，罗列作者、文件数量、文件占比、代码行数量、代码行占比等信息，以供用户进行评估和参考。

如下所示，为附加功能的分析结果示例。

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

## 安装

Git Reviewer 支持通过 Homebrew 进行安装，命令如下所示。

```sh
$ brew install baochuquan/tap/git-reviewer
```

或者，也可以通过 Ruby Gem 进行安装，命令如下所示。

```sh
$ gem install git-reviewer
```

## 使用

### 初始化
对于任意 Git 项目，在使用 Git Reviewer 之前应该先在根目录下执行初始化命令，如下所示。

```sh
$ git reviewer --init
```

该命令会自动创建一个 `.gitreviewer.yml` 文件，内部定义了 `project_owner`，`folder_owner`，`file_owner` 等字段，其中后两者是数组类型，我们可以定义多个 `path`、`owner` 字段，从而对项目进行更精准的划分。

此外，`.gitreviewer.yml` 文件还包含 `ignore_folders`、`ignore_files` 字段，它们可以定义一系列目录或文件，以避免加入分析，从而影响分析结果。

如下所示，是一个 `.gitreviewer.yml` 的示例，我们可以编辑相关字段，从而实现更精准的分析。

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

### 分析
Git Reviewer 基于两个 git 分支进行分析，分别是源分支和目标分支。

源分支，即代码修改所在的分支。默认情况下，Git Reviewer 自动获取当前所在分支作为源分支。当然，也可以使用选项来指定源分支 `--source=<source-branch>`。除了分支名，Git Reviewer 也支持 Commit ID。

目标分支，即准备合入的目标分支。对此，Git Reviewer 提供了相关选项 `--target=<target-branch>`。

如下所示是使用 Git Reviewer 进行分析的命令示例。

```sh
$ git reviewer --target=main
```

默认情况下，Git Reviewer 会同时展示核心功能和附加功能的分析结果。如果我们只希望查看核心功能的结果，可以指定选项 `--reviewer`；如果我们只希望查看附加功能的结果，可以指定选项 `--author`。

```sh
$ git reviewer --target=main --reviewer

$ git reviewer --target=main --author
```

为了查看更多分析信息，我们可以加上 `--verbose` 选项。

```sh
$ git reviewer --target=main --verbose
```

## 许可证
Git Reviewer 使用 MIT License。