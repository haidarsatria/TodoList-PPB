#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

^\s*//.*$ A class abstraction for a high DPI-aware Win32 Window. Intended to be
^\s*//.*$ inherited from by classes that wish to specialize with custom
^\s*//.*$ rendering and input handling
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  ^\s*//.*$ Creates a win32 window with |title| that is positioned and sized using
  ^\s*//.*$ |origin| and |size|. New windows are created on the default monitor. Window
  ^\s*//.*$ sizes are specified to the OS in physical pixels, hence to ensure a
  ^\s*//.*$ consistent size this function will scale the inputted width and height as
  ^\s*//.*$ as appropriate for the default monitor. The window is invisible until
  ^\s*//.*$ |Show| is called. Returns true if the window was created successfully.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  ^\s*//.*$ Show the current window. Returns true if the window was successfully shown.
  bool Show();

  ^\s*//.*$ Release OS resources associated with window.
  void Destroy();

  ^\s*//.*$ Inserts |content| into the window tree.
  void SetChildContent(HWND content);

  ^\s*//.*$ Returns the backing Window handle to enable clients to set icon and other
  ^\s*//.*$ window properties. Returns nullptr if the window has been destroyed.
  HWND GetHandle();

  ^\s*//.*$ If true, closing this window will quit the application.
  void SetQuitOnClose(bool quit_on_close);

  ^\s*//.*$ Return a RECT representing the bounds of the current client area.
  RECT GetClientArea();

 protected:
  ^\s*//.*$ Processes and route salient window messages for mouse handling,
  ^\s*//.*$ size change and DPI. Delegates handling of these to member overloads that
  ^\s*//.*$ inheriting classes can handle.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  ^\s*//.*$ Called when CreateAndShow is called, allowing subclass window-related
  ^\s*//.*$ setup. Subclasses should return false if setup fails.
  virtual bool OnCreate();

  ^\s*//.*$ Called when Destroy is called.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  ^\s*//.*$ OS callback called by message pump. Handles the WM_NCCREATE message which
  ^\s*//.*$ is passed when the non-client area is being created and enables automatic
  ^\s*//.*$ non-client DPI scaling so that the non-client area automatically
  ^\s*//.*$ responds to changes in DPI. All other messages are handled by
  ^\s*//.*$ MessageHandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  ^\s*//.*$ Retrieves a class instance pointer for |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  ^\s*//.*$ Update the window frame's theme to match the system theme.
  static void UpdateTheme(HWND const window);

  bool quit_on_close_ = false;

  ^\s*//.*$ window handle for top level window.
  HWND window_handle_ = nullptr;

  ^\s*//.*$ window handle for hosted content.
  HWND child_content_ = nullptr;
};

#endif  ^\s*//.*$ RUNNER_WIN32_WINDOW_H_
