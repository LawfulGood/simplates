defmodule Simplates.Renderers.EExRenderer do

  def render(compiled, context \\ []) do
    Code.eval_quoted(compiled, context)
  end

  def compile(content) do
    EEx.compile_string(content)
  end
end
