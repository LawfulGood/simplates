defmodule Simplates.Simplate do
  @moduledoc """
  A simplate is a dynamic resource with multiple syntaxes in one file.
  """

  @enforce_keys [:raw, :code, :templates]
  defstruct raw: nil, code: nil, templates: [], filepath: nil

  @doc """
  Returns a simplate based on a filesystem path
  """
  def create_from_file(fs_path) do
    {:ok, raw} = File.read(fs_path)

    create(raw, fs_path)
  end

  @doc """
  Returns a simplate based on a string, misses extension negotiation
  """
  def create_from_string(raw) do
    create(raw, nil)
  end

  @doc """
  Creates a simplate based on the file 
  """
  def create(raw, fs_path) do
    pages = Simplates.Pagination.parse_pages(raw)

    %Simplates.Simplate{
      raw: raw,
      code: pages.code,
      templates: pages.templates,
      filepath: fs_path
    }
  end

  @doc """
  
  """
  def render(%Simplates.Simplate{} = simplate) do
    render(simplate, config(:default_content_type))
  end
  def render(%Simplates.Simplate{} = simplate, content_type) do
    render(simplate, content_type, [])
  end
  def render(%Simplates.Simplate{} = simplate, content_type, context) do
    content_type = ensure_content_type(content_type)

    template = simplate.templates[content_type]

    {output, _bindings} = template.renderer.render(template.compiled, context)

    %{output: output, content_type: content_type}
  end

  def config(:default_content_type) do
    Application.get_env(:infuse, :default_content_type) || "text/plain"
  end

  def config(:default_renderer) do
    Application.get_env(:infuse, :default_renderer) || Simplates.Renderers.EExRenderer
  end

  defp ensure_content_type(content_type) do
    case MIME.valid?(content_type) do
      true ->
        content_type
      false ->
        config(:default_content_type)
    end
  end
end
