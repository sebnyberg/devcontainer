# devcontainer

Opinionated dev container setup ready for copy/paste into your next project.

## Getting started

```bash
cd path/to/my/project
tmpdir=$(mktemp -d)
git clone --depth 1 --branch=main https://github.com/sebnyberg/devcontainer $tmpdir
cp -r $tmpdir/.devcontainer .
rm -rf $tmpdir
```

