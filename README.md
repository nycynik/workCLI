# workCLI

A simple command line tool that helps automate your workflow so that you don't have to context switch to web apps as you develop your project.

So far it's built to integrate with Jira and Github, but more to come.

## Installation

    brew tap nycynik/workcli
    brew install workcli

## Usage

    workcli --help


# Development

## Releasing a new version

Tag it with the new version, update the .workcli-version file, and push the tag to release a new version.

    git tag v0.1.0
    git push origin v0.1.0
