module test_poptart_drawings_textbox

using Test
using Poptart.Controls # Canvas TextBox
using Poptart.Desktop # Font FontAtlas
using Nuklear # pathof(Nuklear)
using Nuklear.LibNuklear: nk_font_chinese_glyph_ranges
using Colors # RGBA

font_path = normpath(pathof(Nuklear), "..", "..", "demo", "extra_font", "Roboto-Light.ttf")
font = Font(name="Roboto-Light", path=font_path, height=30, glyph_ranges=nk_font_chinese_glyph_ranges())
push!(FontAtlas.fonts, font)

canvas = Canvas()
textbox = TextBox(text="fdasfds", font=Font(name="Roboto-Light"))
put!(canvas, textbox)

FontAtlas.clear()

end # module test_poptart_drawings_textbox
