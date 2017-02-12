defmodule Simplates.PaginationTest do
  use ExUnit.Case, async: true

  alias Simplates.Pagination, as: Pagination
  
  test "single page adds one code pages" do 
    pages = Pagination.parse_pages("Hello, world! I have no code!")

    assert pages.code.raw == ""
    assert pages.templates["text/plain"].raw == "Hello, world! I have no code!"
  end

  test "two page adds nothing" do
    pages = Pagination.parse_pages("
      some_code = 3
      [----]
      Hello, world! I have SOME code!")

    assert String.trim(pages.code.raw) == "some_code = 3"
    assert String.trim(pages.templates["text/plain"].raw) == "Hello, world! I have SOME code!"
  end

  test "two page adds nothing with specline" do
    pages = Pagination.parse_pages("
      some_code = 2
      [----] media/type via EEx
      Hello, world! I have SOME code and a specline!")

    assert String.trim(pages.code.raw) == "some_code = 2"
    assert String.trim(pages.templates["media/type"].raw) == "Hello, world! I have SOME code and a specline!"
  end


end
