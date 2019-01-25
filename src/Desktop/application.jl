# module Poptart.Desktop

using GLFW
using Nuklear
using Nuklear.LibNuklear
using Nuklear.GLFWBackend
using ModernGL # glViewport glClear glClearColor


struct ApplicationMain <: UIApplication
    windows
end

const MAX_VERTEX_BUFFER = 512 * 1024
const MAX_ELEMENT_BUFFER = 128 * 1024

function setup_app(windows; title="App", frame=(width=400, height=300))
    @static if Sys.isapple()
        VERSION_MAJOR = 3
        VERSION_MINOR = 3
        GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, VERSION_MAJOR)
        GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, VERSION_MINOR)
        GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
        GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)
    else
        GLFW.DefaultWindowHints()
    end

    win = GLFW.CreateWindow(frame.width, frame.height, title)
    GLFW.MakeContextCurrent(win)
    glViewport(0, 0, frame.width, frame.height)

    # init context
    ctx = nk_glfw3_init(win, NK_GLFW3_INSTALL_CALLBACKS, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER)

    nk_glfw3_font_stash_begin()
    nk_glfw3_font_stash_end()

    while !GLFW.WindowShouldClose(win)
        yield()

        GLFW.PollEvents()
        nk_glfw3_new_frame()

        defaultprops = (frame=(x=0, y=0, frame...),
                        flags=NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE | NK_WINDOW_TITLE)

        for window in windows
            Windows.setup_window(ctx, window; merge(defaultprops, window.props)...)
        end

        # draw
        bg = nk_colorf(0.10, 0.18, 0.24, 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        glClearColor(bg.r, bg.g, bg.b, bg.a)
        nk_glfw3_render(NK_ANTI_ALIASING_ON, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER)
        GLFW.SwapBuffers(win)
    end
    nk_glfw3_shutdown()
    GLFW.DestroyWindow(win)
end

function Base.getproperty(app::A, prop::Symbol) where {A <: UIApplication}
    getfield(app, prop)
end

function Application(; windows=[Windows.Window()], props...)
    app = ApplicationMain(windows)
    task = @async setup_app(windows; props...)
    (app, task)
end

# module Poptart.Desktop
