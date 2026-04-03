# shmake
[![test](https://github.com/totomz/shmake/actions/workflows/test.yml/badge.svg)](https://github.com/totomz/shmake/actions/workflows/test.yml)

Run bash functions as build targets — no Makefile, no NodeJS, just shell.

`shMakefile` gives you a simple framework to invoke bash functions with arguments, providing ready-to-use functions to simplify your test, build, and deploy cycle.

**WARNING:** This is a highly opinionated way to organize build and CI/CD pipelines, based on my personal experience. It works for me, but it might not work for you!

Invoke a build command with an argument:
```shell
./shMakefile build --env=prod
```

## Installation
This tool consists of two scripts:
* `shMakefile`: The main executable script.
* `functions.sh`: A collection of utility functions.

Just download these scripts into your repo, and you are ready to go.

One-liner with curl:
```shell
curl -fsSL https://raw.githubusercontent.com/totomz/shmake/refs/heads/main/install.sh | sh
```

Or with wget:
```shell
wget -qO- https://raw.githubusercontent.com/totomz/shmake/refs/heads/main/install.sh | sh
```

## Usage
Design principles:

1. A codebase should be built in a local environment and a CI/CD pipeline using exactly the same commands;
2. Most build and deploy processes are essentially about gluing various CLI tools together;

The goal is to keep build/deploy logic in isolated, invocable bash functions.

Here are two simple functions that test and build a monorepo with multiple Go services:
```shell
build() {
  mustVar service               # required argument
  local arch="${arch:-amd64}"   # optional argument, default "amd64"

  # Good engineers test their code before compiling
  run-test
  time GOOS=linux GOARCH="${arch}" go build -o bin/daje app/main.go
}

run-test() {
  mustVar service
  # Test the common package
  go vet ./common/...
  go test ./common/...

  # Test the service
  go vet ./services/${service}/...
  go test -timeout 180s -count=1 --parallel=6 ./services/${service}/
}
```

**Need to run the tests?**
```shell
$ ./shMakefile run-test --service=myservice
```

**Or build?**
```shell
# Build for the default architecture
$ ./shMakefile build --service=myservice

# Build for a specific architecture
$ ./shMakefile build --service=myservice --arch=arm64
```

Read the contents of `./shMakefile` for more details about:
* **Monorepo support**: Create child `shMakefile` files to separate functions from your main code.
* **Custom scripts**: Where to place your custom logic.
* **Built-in functions**: A small set of utilities to simplify your workflow.

## Built-in Utility Functions
*(List your functions here)*

## Examples
See the `shMakefile` and an example of a sub-service `./services/bob/shMakefile`.

# FAQ

## Can I call a function "test"?
**TL;DR: NO**

**Long version:**
Technically, yes. In bash, functions take precedence over external commands and non-special builtins. `test` is not a special builtin (those are: `break`, `continue`, `eval`, `exec`, `exit`, `export`, `readonly`,
`return`, `set`, `shift`, `trap`, `unset`), so it can be overridden.

```shell
test() {
  echo "hello"
}
test  # prints "hello"
```

However, overriding `test` is a "time bomb" because the `[` command is an alias for `test`. If you override `test`, all `if [ ... ]` statements in your scripts will stop behaving as expected!

To call the original `test` from inside your function, use the `builtin` command: `builtin test ...`.