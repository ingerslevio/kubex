# Kubex [![hex.pm version](https://img.shields.io/hexpm/v/kubex.svg?style=flat)](https://hex.pm/packages/kubex) [![hex.pm downloads](https://img.shields.io/hexpm/dt/kubex.svg?style=flat)](https://hex.pm/packages/kubex)

Kubex is the [Kubernetes](http://kubernetes.io/) integration for Elixir projects and it is written in pure Elixir.

## Installation

It's easy to install Kubex with [hex.pm](https://hex.pm). Just add it too your dependencies and applications in your `mix.exs`:

```elixir
defp deps do
  [
    {:kubex, "~> 0.1"}
  ]
end

def application do
  [applications: [:kubex]]
end
```

And then fetch your project's dependencies:

```bash
$ mix deps.get
```

## Usage

Kubex is still very young and there is only a few use cases at the moment:

```elixir
defmodule Test

  def fetch_my_pods do
    Kubex.server("https://1.2.3.4", "myuser", "mypassword")
    |> Kubex.query(:label_selector, "my=label")
    |> Kubex.get_pods
  end

  def keep_pinging_fellow_pods do
    Kubex.server_from_environment("myuser", "mypassword")
    |> Kubex.query(:label_selector, "app=elixir")
    |> Kubex.start_pinger :pinger #pinger id
  end

end
```

```elixir
iex> Test.fetch_my_pods
[%{"metadata" => %{"annotations" => # ... truncated

iex> Test.keep_pinging_fellow_pods
:ok
```

`fetch_my_pods` will return the full output from kubernetes api deserialized with `Poison`. The other method `keep_pinging_fellow_pods` will start a _pinger_ which keeps pinging nodes retreived from the kubernetes API. This will make nodes aware of each other. This is discussed further in **Using Kubex with `:pg2`**

## Using Kubex with `:pg2`
The continuously pinging functionality built into Kubex is a perfect tool for using `:pg2`, kubernetes and Elixir. Hosting two nodes in kubernetes with the pinger enabled will make all nodes know about each other, thus _synchronize_ `:pg2` groups between each nodes.

This makes kubernetes a great elastic setup for your Elixir application, since kubernetes can scale your application live.

For at bit more info on using `:pg2` with Elixir see [this great blog post](http://blog.jonharrington.org/elixir-and-docker/) by Jonathan Harrington.

## Testing
The current tests are written as integration/system tests and there is no test built into the suite, since all the _tests_ run in a local kubetnetes cluster. The Kubex tests has been run on a OS X with boot2docker, but it should run mostly anywhere with the following requirements:

* elixir `> 1.0`
* docker `> 1.7`
* boot2docker `> 1.7` - on non-linux environments
* bash - for running test scripts

For running the test on OS X start up your terminal:

```bash
# Remember to start boot2docker
> boot2docker init # create the boot2docker vm
> boot2docker up # start the boot2docker vm
> eval '$(boot2docker shellinit)' # setup env variables for docker cli

# Create the kubernetes cluster
kubex/ > ./scripts/start_kubernetes.sh

# build the kubex test image and deploy it to local kubernetes cluster
kubex/ > ./scripts/build_and_deploy_test.sh

# using boot2docker requires a tunnel to get access to the kubernetes service and api
kubex/ > ./scripts/open_boot2docker_tunnel.sh
```

After opening the tunnel just open the browser at [http://localhost:4000](http://localhost:4000).

To clean up the test either delete all kubernetes related docker containers

```bash
> docker stop $(docker ps | grep gcr.io/ | awk '{print $1}')
> docker rm $(docker ps -a | grep gcr.io/ | awk '{print $1}')
```

And a few times it can help to restart boot2docker completely by removing the boo2docker vm:

```bash
> boot2docker delete
```

And then just start over. For testing on linux environment it should be the same as above, but just leave out all tunnel and boot2docker related commands.

## Todo

There is much to do to make Kubex able to handle all kubernetes integration. The following is the current roadmap:

* [ ] Automated integration testing suite
* [ ] Automated build
* [ ] Full query support
* [ ] Full command support

## Compability
Kubex is tested with elixir 1.0.4 and kubernetes v0.21.2 and v1.0.1.

## Contributing

Please feel free to submit pull requests. Every bug fix and improvement is much appreciated.
If you have found a bug or have an idea, but don't know how to solve it or make it, you're welcome to open an issue, but please check if there is an issue registered already first.
