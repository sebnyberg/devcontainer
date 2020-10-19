# devcontainer

Opinionated dev container setup ready for copy/paste into your next project.

## Getting started

```bash
tmpdir=$(mktemp -d)
git clone --depth 1 --branch=master https://github.com/sebnyberg/devcontainer $tmpdir
cp -r $tmpdir/.devcontainer .
rm -rf $tmpdir
```