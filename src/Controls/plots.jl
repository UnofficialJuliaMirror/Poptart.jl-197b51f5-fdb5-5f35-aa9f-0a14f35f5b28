# module Poptart.Controls

"""
    ScatterPlot(; x::AbstractVector, y::AbstractVector, [label::String], [scale::NamedTuple{(:x, :y)}], [frame])
"""
ScatterPlot
@UI ScatterPlot

function properties(control::ScatterPlot)
    (properties(super(control))..., :x, :y, :label, :scale, )
end

"""
    Spy(; A::AbstractMatrix, [label::String], [frame])
"""
Spy
@UI Spy

function properties(control::Spy)
    (properties(super(control))..., :A, :label, )
end

"""
    BarPlot(; values::Vector{Number}, [captions::Vector{String}], [label::String], [scale::NamedTuple{(:min_x, :max_x)}], [frame])
"""
BarPlot
@UI BarPlot

function properties(control::BarPlot)
    (properties(super(control))..., :values, :captions, :label, :scale, )
end

"""
    LinePlot(; values::AbstractVector, [label::String], [color], [overlay_text], [scale::NamedTuple{(:min, :max)}], [frame])
"""
LinePlot
@UI LinePlot

function properties(control::LinePlot)
    (properties(super(control))..., :values, :label, :color, :overlay_text, :scale, )
end

"""
    MultiLinePlot(; items::Vector{LinePlot}, [label::String], [frame])
"""
MultiLinePlot
@UI MultiLinePlot

function properties(control::MultiLinePlot)
    (properties(super(control))..., :items, :label, )
end

"""
    Histogram(; values::AbstractVector, [label::String], [overlay_text], [scale::NamedTuple{(:min, :max)}], [frame])
"""
Histogram
@UI Histogram

function properties(control::Histogram)
    (properties(super(control))..., :values, :label, :overlay_text, :scale, )
end

# module Poptart.Controls
