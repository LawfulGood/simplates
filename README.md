# Simplates for Elixir
[![Build Status](https://travis-ci.org/LawfulGood/simplates.svg?branch=master)](https://travis-ci.org/LawfulGood/simplates)
[![Coverage Status](https://coveralls.io/repos/github/LawfulGood/simplates/badge.svg?branch=master)](https://coveralls.io/github/LawfulGood/simplates?branch=master)

Simplates are a file format for server-side web programming. Used currently in [Infuse](https://github.com/LawfulGood/infuse).

This repository is my future spec for [simplates.org](http://simplates.org/)

## Why Simplates? 
Mixing code into templates leads to unmaintainable spaghetti. On the other 
hand, putting closely-related templates and code in completely separate 
subdirectories makes it painful to switch back and forth.

Simplates improve web development by bringing code and templates as close 
together as possible, _without_ mixing them.

## What does a Simplate look like?
Here's an example: 
```
<script>
program = "hellö"
excitement = :rand.uniform(100)
</script>

<template type="text/html" via="EEx">
<h1><%= hello %>, program, my favorite number is <%= num %></h1>
</template>
```

## Installation

  1. Add `simplates` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:simplates, "~> 0.1.0"}]
    end
    ```

  2. Ensure `simplates` is started before your application:

    ```elixir
    def application do
      [applications: [:simplates]]
    end
    ```
  
  3. Create & render like so
  
    ```elixir
    page = Simplates.Simplate.create_from_string("<template>Hello</template>")

    {output, _} = Simplates.Simplate.render(page, "text/plain")
    ```

