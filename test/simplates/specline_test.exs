defmodule Infuse.Simplates.SpeclineTest do
  use ExUnit.Case, async: true

  alias Simplates.Specline, as: Specline

  test "parses specline" do
    parsed = Specline.parse_specline("media/type via EEx")
    assert parsed == {:ok, Simplates.Renderers.EExRenderer, "media/type"}
  end

  test "parses specline without renderer" do
    parsed = Specline.parse_specline("media/type")
    assert parsed == {:ok_missing_renderer, Simplates.Renderers.EExRenderer, "media/type"}
  end

  test "parses specline without content type" do
    parsed = Specline.parse_specline("via EEx")
    assert parsed == {:ok_missing_content_type, Simplates.Renderers.EExRenderer, "text/plain"}
  end

  test "parses empty specline" do
    parsed = Specline.parse_specline("")
    assert parsed == {:empty, Simplates.Renderers.EExRenderer, "text/plain"}
  end
end
