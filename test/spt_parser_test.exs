defmodule Simplates.SptParserTest do
  use ExUnit.Case, async: true

  import Simplates.Parser, only: [parse: 1]
  
  test "basic root document parsing" do 
    src = "<template>\nhello world\n</template>"

    assert parse(src) == [src]
  end

  test "ignores html inside templates" do
    src = "<template>\nhello <h1>derp</h1> world\n</template>"

    assert parse(src) == [src]
  end

  test "handles pure unicode" do
    src = "<template>\nŦħɇꝗᵾɨȼꝁƀɍøwnføxɉᵾmᵽsøvɇɍŧħɇłȺƶɏđøǥ\n</template>"

    assert parse(src) == [src]
  end

  test "ignores unicode templates" do
    src = "<template>\nhello world Ŧħɇ ꝗᵾɨȼꝁ ƀɍøwn føx ɉᵾmᵽs øvɇɍ ŧħɇ łȺƶɏ đøǥ\n</template>"

    assert parse(src) == [src]
  end

  test "ignores template inside templates" do
    src = "<template>\nhello <template>this is just dumb html ignore it</template> world\n</template>"

    assert parse(src) == [src]
  end

  test "parses multiple" do
    src = "<template>\nHello world\n</template>\n<template>\nHello Paul\n</template>"

    assert parse(src) == ["<template>\nHello world\n</template>","<template>\nHello Paul\n</template>"]
  end

end
