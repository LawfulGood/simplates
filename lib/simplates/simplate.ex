defmodule Simplates.Simplate do
  @moduledoc """
  A simplate is a dynamic resource with multiple syntaxes in one file.
  """

  @enforce_keys [:raw, :code, :templates]
  defstruct raw: nil, code: nil, templates: [], filepath: nil, default_content_type: nil

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
    bound_content_type = bound_or_unbound(fs_path)

    pages = Simplates.Pagination.parse_pages(raw)

    # Handle the potential of a bound simplate
    templates = bound_templates(pages.templates, bound_content_type)

    pages = %{pages | templates: templates}

    %Simplates.Simplate{
      raw: raw,
      code: pages.code,
      templates: pages.templates,
      filepath: fs_path,
      default_content_type: bound_content_type || config(:default_content_type)
    }
  end

  defp bound_templates(templates, bound_content_type) when map_size(templates) == 1 and bound_content_type != false do
    # I'm really not happy with this function and it's guards
    Enum.reduce(templates, %{}, fn {_content_type, page}, acc ->
      page = cond do
        page.specline_status in [:empty, :ok_missing_content_type] ->
          %{page | content_type: bound_content_type}
        true ->
          page
      end
      Map.put(acc, page.content_type, page) 
    end)
  end
  defp bound_templates(templates, _), do: templates

  @doc """
  
  """
  def render(%Simplates.Simplate{} = simplate) do
    render(simplate, simplate.default_content_type)
  end
  def render(%Simplates.Simplate{} = simplate, content_type) do
    render(simplate, content_type, [])
  end
  def render(%Simplates.Simplate{} = simplate, content_type, context) do
    content_type = ensure_content_type(content_type)

    template = simplate.templates[content_type]

    {output, bindings} = template.renderer.render(template.compiled, context)

    %{output: output, content_type: content_type, bindings: bindings}
  end

  def config(:default_content_type) do
    Application.get_env(:infuse, :default_content_type) || "text/plain"
  end

  def config(:default_renderer) do
    Application.get_env(:infuse, :default_renderer) || Simplates.Renderers.EExRenderer
  end

  defp bound_or_unbound(fs_path) when is_bitstring(fs_path) do
    type = fs_path |> String.replace(".spt", "") |> Path.extname() |> String.trim_leading(".")

    case MIME.has_type?(type) do
      true -> MIME.type(type)
      false -> false
    end
  end
  defp bound_or_unbound(_fs_path) do
    false
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
