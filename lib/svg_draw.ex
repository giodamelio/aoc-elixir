defmodule AOCUtils.SVGDraw do
  def new(width, height, options \\ []) do
    %{
      width: width,
      height: height,
      shapes: [],
      state: %{
        fill: "black",
        stroke: "black",
        stroke_width: "1"
      },
      options: options
    }
  end

  ## User facing functions

  def circle(svg, cx, cy, r) do
    add_to_shapes(svg, {:circle, cx, cy, r})
  end

  def rectangle(svg, x, y, width, height) do
    add_to_shapes(svg, {:rectangle, x, y, width, height, 0, 0})
  end

  def square(svg, x, y, size) do
    add_to_shapes(svg, {:rectangle, x, y, size, size, 0, 0})
  end

  def line(svg, {x1, y1}, {x2, y2}), do: line(svg, x1, y1, x2, y2)

  def line(svg, x1, y1, x2, y2) do
    add_to_shapes(svg, {:line, x1, y1, x2, y2})
  end

  def set_stroke(svg, color) do
    add_to_shapes(svg, {:set_stroke, color})
  end

  def set_fill(svg, color) do
    add_to_shapes(svg, {:set_fill, color})
  end

  def set_color(svg, color) do
    svg
    |> add_to_shapes({:set_fill, color})
    |> add_to_shapes({:set_stroke, color})
  end

  def set_stroke_width(svg, color) do
    add_to_shapes(svg, {:set_stroke_width, color})
  end

  ## Convert the shapes to strings

  def draw({:circle, cx, cy, r}, state) do
    {
      ~s(<circle cx="#{cx}" cy="#{cy}" r="#{r}" #{state_to_attributes(state)} />),
      state
    }
  end

  def draw({:rectangle, x, y, width, height, rx, ry}, state) do
    {
      ~s(<rect x="#{x}" y="#{y}" width="#{width}" height="#{height}" rx="#{rx}" ry="#{ry}" #{state_to_attributes(state)} />),
      state
    }
  end

  def draw({:line, x1, y1, x2, y2}, state) do
    {
      ~s(<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" #{state_to_attributes(state)} />),
      state
    }
  end

  def draw({:set_stroke, color}, state) do
    {
      nil,
      put_in(state.stroke, color)
    }
  end

  def draw({:set_fill, color}, state) do
    {
      nil,
      put_in(state.fill, color)
    }
  end

  def draw({:set_stroke_width, color}, state) do
    {
      nil,
      put_in(state.stroke_width, color)
    }
  end

  def render(svg) do
    # Render the shapes
    shapes =
      svg.shapes
      |> Enum.reverse()
      |> Enum.reduce({svg.state, []}, fn shape, {state, shapes} ->
        {shape_text, new_state} = draw(shape, state)
        {new_state, [shape_text | shapes]}
      end)
      |> elem(1)
      |> Enum.reverse()
      |> Enum.join("\n")

    # Global styles
    global_style =
      svg.options
      |> Keyword.get(:global_style, %{})
      |> state_to_attributes()

    ~s(
    <svg width="#{svg.width}" height="#{svg.height}" viewBox="0 0 #{svg.width} #{svg.height}" xmlns="http://www.w3.org/2000/svg">
      <g #{global_style} >
        #{shapes}
      </g>
    </svg>
    ) |> String.trim()
  end

  defp add_to_shapes(svg, shape) do
    Map.update!(svg, :shapes, &[shape | &1])
  end

  defp state_to_attributes(%{} = state) do
    style =
      state
      |> Map.to_list()
      |> Enum.map(fn {key, value} ->
        key =
          key
          |> Atom.to_string()
          |> String.replace("_", "-")

        ~s(#{key}:#{value})
      end)
      |> Enum.join(";")

    ~s(style="#{style}")
  end
end
