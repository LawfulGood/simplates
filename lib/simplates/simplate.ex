defmodule Simplates.Simplate do
  @moduledoc """
  A simplate is a dynamic resource with multiple syntaxes in one file.
  """

  @enforce_keys [:raw, :code, :templates]
  defstruct raw: nil, code: nil, templates: [], filepath: nil, wildcards: [], wild_path: nil, default_content_type: nil

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
    templates = fill_content_type(pages.templates, bound_content_type, config(:default_content_type))

    pages = %{pages | templates: templates}

    %Simplates.Simplate{
      raw: raw,
      code: pages.code,
      templates: pages.templates,
      filepath: fs_path,
      wildcards: fs_path |> get_wildcards(),
      wild_path: fs_path |> replace_wildcards(),
      default_content_type: bound_content_type || config(:default_content_type)
    }
  end

  defp fill_content_type(templates, bound_content_type, default_content_type) do
    # I'm really not happy with this function and it's guards
    Enum.reduce(templates, %{}, fn {_content_type, page}, acc ->
      page = cond do
        page.content_type == nil && bound_content_type != false ->
          %{page | content_type: bound_content_type}
        page.content_type == nil && bound_content_type == false ->
          %{page | content_type: default_content_type}
        true ->
          page
      end
      Map.put(acc, page.content_type, page) 
    end)
  end
  
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

    {res, context} = simplate.code.renderer.render(simplate.code.compiled, context)
    
    # This handles if the return of the code simplate is a type in our context
    # For now it only handles Plug.Conn
    context = case res do
      %Plug.Conn{} ->
        context ++ [conn: res]
      _ ->
        context
    end

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

  defp get_wildcards(filename) when is_bitstring(filename) do
    Regex.scan(~r/\%\w+/, filename) |> List.flatten()
  end
  defp get_wildcards(nil) do
    []
  end

  defp replace_wildcards(filename) when is_bitstring(filename) do
    Regex.replace(~r/\%\w+/, filename, "%wild%")
  end
  defp replace_wildcards(nil) do
    []
  end
end
