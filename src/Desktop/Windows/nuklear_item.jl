# module Poptart.Desktop.Windows

env = Dict{Symbol, Any}(
    :default_layout_height => 21,
)

# layout
nuklear_no_layout(nk_ctx::Ptr{LibNuklear.nk_context}, item::UIControl) = nothing

function nuklear_layout(nk_ctx::Ptr{LibNuklear.nk_context}, item::UIControl)
    if haskey(item.props, :frame)
        frame = item.frame
        if haskey(frame, :height)
            if haskey(frame, :width)
                nk_layout_row_static(nk_ctx, frame.height, frame.width, 1)
            else
                nk_layout_row_dynamic(nk_ctx, frame.height, 1)
            end
        else
            nk_layout_row_dynamic(nk_ctx, env[:default_layout_height], 1)
        end
    else
        nk_layout_row_dynamic(nk_ctx, env[:default_layout_height], 1)
    end
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, window::W, item::StaticRow) where {W <: UIWindow}
    cols = haskey(item.props, :cols) ? item.cols : length(item.widgets)
    nk_layout_row_static(nk_ctx, item.height, item.width, cols)
    for widget in item.widgets
        nuklear_item(nk_ctx, window, widget; layout=nuklear_no_layout)
    end
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, window::W, item::DynamicRow) where {W <: UIWindow}
    cols = haskey(item.props, :cols) ? item.cols : length(item.widgets)
    nk_layout_row_dynamic(nk_ctx, item.height, cols)
    for widget in item.widgets
        nuklear_item(nk_ctx, window, widget; layout=nuklear_no_layout)
    end
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::Button; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    nk_button_label(nk_ctx, item.title) == 1 && @async Mouse.click(item)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::Label; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    nk_label(nk_ctx, item.text, NK_TEXT_LEFT)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::SelectableLabel; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    nk_selectable_label(nk_ctx, item.text, NK_TEXT_LEFT, item.selected) == 1 && @async Mouse.click(item)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::Slider; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    if item.range isa UnitRange{Int}
        step = 1
    else
        step = item.range.step
    end
    if item.value isa Ref{Cint}
        f = nk_slider_int
    elseif item.value isa Ref{Cfloat}
        f = nk_slider_float
    end
    min = minimum(item.range)
    max = maximum(item.range)
    f(nk_ctx, min, item.value, max, step) == 1 && @async Mouse.click(item)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, window::W, item::Property; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    if item.range isa UnitRange{Int}
        step = 1
    else
        step = item.range.step
    end
    if item.value isa Ref{Cint}
        f = nk_property_int
    elseif item.value isa Ref{Cfloat}
        f = nk_property_float
    elseif item.value isa Ref{Cdouble}
        f = nk_property_double
    end
    min = minimum(item.range)
    max = maximum(item.range)
    inc_per_pixel = 1
    old_value = item.value[]
    f(nk_ctx, item.name, min, item.value, max, step, inc_per_pixel)
    old_value != item.value[] && @async Mouse.click(item)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::CheckBox; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    nk_checkbox_label(nk_ctx, item.text, item.active) == 1 && @async Mouse.click(item)
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::Radio; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    for (name, value) in pairs(item.options)
        if nk_option_label(nk_ctx, String(name), item.value == value) == 1
            if item.value != value
                item.value = value
                @async Mouse.click(item)
            end
        end
    end
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::ProgressBar; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    nk_progress(nk_ctx, item.value, item.max, item.modifyable ? NK_MODIFIABLE : NK_FIXED) == 1 && @async Mouse.click(item)
end

function nuklear_item_imageview(item::ImageView, p::Union{Nothing,ProgressMeter.Progress})
    #= =# p !== nothing && ProgressMeter.next!(p)
    data = transpose(Controls.Images.load(item.path))
    (img_width, img_height) = Base.size(data)
    #= =# p !== nothing && ProgressMeter.next!(p)
    texture_index = nk_glfw3_create_texture(img_width, img_height, format=GL_RGBA, type=GL_FLOAT)
    #= =# p !== nothing && ProgressMeter.next!(p)
    chanview = Controls.Images.channelview(data)
    #= =# p !== nothing && ProgressMeter.next!(p)
    img = Array{Float32}(chanview)
    #= =# p !== nothing && ProgressMeter.next!(p)
    nk_glfw3_update_texture(texture_index, img, img_width, img_height, format=GL_RGBA, type=GL_FLOAT)
    #= =# p !== nothing && ProgressMeter.next!(p)
    return texture_index
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::ImageView; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    canvas = nk_window_get_canvas(nk_ctx)
    region = nk_window_get_content_region(nk_ctx)
    if !haskey(item.props, :imageref)
        #= =# p = nothing
        if !isdefined(Controls, :Images)
            #= =# p = ProgressMeter.Progress(11, desc=string("Loading ", basename(item.path), " "), color=:normal)
            #= =# ProgressMeter.update!(p, 0)
            Base.eval(Controls, :(using Images))
            #= =# ProgressMeter.update!(p, 3)
        end
        texture_index = Base.invokelatest(nuklear_item_imageview, item, p)
        #= =# p !== nothing && ProgressMeter.next!(p)
        item.props[:imageref] = Ref(create_nk_image(texture_index))
        #= =# p !== nothing && ProgressMeter.finish!(p)
        #= =# p !== nothing && ProgressMeter.move_cursor_up_while_clearing_lines(p.output, p.numprintedvalues+1)
    end
    nk_draw_image(canvas, region, item.props[:imageref], nk_rgba(255, 255, 255, 255))
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, window::W, item::Canvas; layout=nuklear_layout) where {W <: UIWindow}
    layout(nk_ctx, item)
    canvas = nk_window_get_canvas(nk_ctx)
    #=
    https://github.com/vurtun/nuklear/blob/master/example/canvas.c#L358

    /* save style properties which will be overwritten */
    canvas->panel_padding = ctx->style.window.padding;
    canvas->item_spacing = ctx->style.window.spacing;
    canvas->window_background = ctx->style.window.fixed_background;

    /* use the complete window space and set background */
    ctx->style.window.spacing = nk_vec2(0,0);
    ctx->style.window.padding = nk_vec2(0,0);
    ctx->style.window.fixed_background = nk_style_item_color(background_color);
    =#
    for drawing in item.container.items
        nuklear_drawing_item(canvas, drawing, drawing.element)
    end
    #=
    ctx->style.window.spacing = canvas->panel_padding;
    ctx->style.window.padding = canvas->item_spacing;
    ctx->style.window.fixed_background = canvas->window_background;
    =#
end

function nuklear_item(nk_ctx::Ptr{LibNuklear.nk_context}, ::W, item::Any; layout=nuklear_layout) where {W <: UIWindow}
    @info "not implemented" item
end

# module Poptart.Desktop.Windows
