defmodule Simplates.Parser do
  @moduledoc """
  Handles blocking out a file into blocks of templates/scripts

  Then it's up to specline to the paginator/specline
  """

  @block_regex ~r/(^\<template(.*)\>|^\<script\>)|(^\<\/template\>|^\<\/script\>)/im

  def parse(input) do
    input |> String.trim() |> String.split("\n")  |> find_block()
  end

  def find_block(lines) do
    find_block(lines, 0, [], [])
  end

  def find_block(remaining, found, in_block, blocks) when found == 2 do
    in_block = Enum.join(in_block, "\n")
    find_block(remaining, 0, [], blocks ++ [in_block])
  end
  
  def find_block([], _found, _in_block, blocks) do
    blocks
  end

  def find_block(remaining, found, in_block, blocks) do
    line = hd(remaining)
    regex_matches = Regex.match?(@block_regex, line)

    in_block = in_block ++ [line]

    found = 
      case regex_matches do
        true -> found + 1
        false -> found
      end

    find_block(Enum.drop(remaining, 1), found, in_block, blocks)
  end

end