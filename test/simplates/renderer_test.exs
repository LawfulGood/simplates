defmodule Simplates.RendererTest do
  use ExUnit.Case, async: true
  
  test "code renderer handles basic code" do 
    compiled = Simplates.Renderers.CodeRenderer.compile("some_var = 2")
    {_, bindings} = Simplates.Renderers.CodeRenderer.render(compiled)

    assert bindings == [some_var: 2]
  end
  
  test "eex renderer handles basic eex" do
    compiled = Simplates.Renderers.EExRenderer.compile("hello world")
    {content, _} = Simplates.Renderers.EExRenderer.render(compiled)

    assert content == "hello world"
  end

end
