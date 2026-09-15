#![windows_subsystem = "windows"]

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Mutex;
use once_cell::sync::Lazy;

use windows::core::*;
use windows::Win32::Foundation::*;
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::Win32::UI::Input::KeyboardAndMouse::*;
use windows::Win32::UI::Shell::*;
use windows::Win32::UI::WindowsAndMessaging::*;

static BANGLA_ENABLED: AtomicBool = AtomicBool::new(false);
static IS_PROCESSING: AtomicBool = AtomicBool::new(false);

struct InputState {
    buffer: String,
    candidates: Vec<String>,
}

static STATE: Lazy<Mutex<InputState>> = Lazy::new(|| {
    Mutex::new(InputState {
        buffer: String::new(),
        candidates: Vec::new(),
    })
});

const WM_TRAY_ICON: u32 = WM_USER + 1;
const IDM_TOGGLE: usize = 1001;
const IDM_EXIT: usize = 1002;
const IDM_ABOUT: usize = 1003;

fn main() -> Result<()> {
    unsafe {
        let instance = GetModuleHandleW(None)?;
        let class_name = w!("BornoWindowsClass");

        let wnd_class = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(wnd_proc),
            hInstance: instance.into(),
            lpszClassName: class_name,
            ..Default::default()
        };

        RegisterClassExW(&wnd_class);

        let hwnd = CreateWindowExW(
            WINDOW_EX_STYLE::default(),
            class_name,
            w!("Borno"),
            WS_OVERLAPPEDWINDOW,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            None,
            None,
            instance,
            None,
        )?;

        // Set up System Tray icon
        setup_tray_icon(hwnd)?;

        // Set up Low-Level Keyboard Hook
        let hook = SetWindowsHookExW(
            WH_KEYBOARD_LL,
            Some(keyboard_hook_proc),
            instance,
            0,
        )?;

        let mut msg = MSG::default();
        while GetMessageW(&mut msg, None, 0, 0).into() {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        UnhookWindowsHookEx(hook)?;
        remove_tray_icon(hwnd)?;
    }

    Ok(())
}

fn setup_tray_icon(hwnd: HWND) -> Result<()> {
    unsafe {
        let mut nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: 1,
            uFlags: NIF_ICON | NIF_MESSAGE | NIF_TIP,
            uCallbackMessage: WM_TRAY_ICON,
            hIcon: LoadIconW(None, IDI_APPLICATION)?,
            ..Default::default()
        };

        let tooltip = "Borno - Avro Phonetic Bengali (F12 to Toggle)";
        let wide_tip: Vec<u16> = tooltip.encode_utf16().chain(std::iter::once(0)).collect();
        for (i, &ch) in wide_tip.iter().enumerate().take(127) {
            nid.szTip[i] = ch;
        }

        Shell_NotifyIconW(NIM_ADD, &nid);
    }
    Ok(())
}

fn remove_tray_icon(hwnd: HWND) -> Result<()> {
    unsafe {
        let nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: 1,
            ..Default::default()
        };
        Shell_NotifyIconW(NIM_DELETE, &nid);
    }
    Ok(())
}

unsafe extern "system" fn wnd_proc(
    hwnd: HWND,
    msg: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match msg {
        WM_TRAY_ICON => {
            if lparam.0 as u32 == WM_RBUTTONUP || lparam.0 as u32 == WM_LBUTTONUP {
                let mut pt = POINT::default();
                GetCursorPos(&mut pt).unwrap_or_default();

                let hmenu = CreatePopupMenu().unwrap_or_default();
                let status = if BANGLA_ENABLED.load(Ordering::SeqCst) {
                    "Mode: Bengali (Active) [F12]"
                } else {
                    "Mode: English [F12]"
                };

                let w_status: Vec<u16> = status.encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_TOGGLE, PCWSTR(w_status.as_ptr())).unwrap_or_default();
                AppendMenuW(hmenu, MF_SEPARATOR, 0, PCWSTR::null()).unwrap_or_default();

                let w_about: Vec<u16> = "About Borno...".encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_ABOUT, PCWSTR(w_about.as_ptr())).unwrap_or_default();

                let w_exit: Vec<u16> = "Exit".encode_utf16().chain(std::iter::once(0)).collect();
                AppendMenuW(hmenu, MF_STRING, IDM_EXIT, PCWSTR(w_exit.as_ptr())).unwrap_or_default();

                SetForegroundWindow(hwnd);
                TrackPopupMenu(
                    hmenu,
                    TPM_RIGHTALIGN | TPM_BOTTOMALIGN,
                    pt.x,
                    pt.y,
                    0,
                    hwnd,
                    None,
                );
                DestroyMenu(hmenu).unwrap_or_default();
            }
            LRESULT(0)
        }
        WM_COMMAND => {
            let id = wparam.0 & 0xffff;
            match id {
                IDM_TOGGLE => {
                    let new_state = !BANGLA_ENABLED.load(Ordering::SeqCst);
                    BANGLA_ENABLED.store(new_state, Ordering::SeqCst);
                }
                IDM_ABOUT => {
                    MessageBoxW(
                        hwnd,
                        w!("Borno (বর্ণ) v0.2.5 for Windows\n\nFast Native Avro Phonetic Bengali Keyboard.\nDeveloped & Maintained by Yahia Bin Zaman.\n\nPress F12 to switch English/Bengali mode."),
                        w!("About Borno"),
                        MB_OK | MB_ICONINFORMATION,
                    );
                }
                IDM_EXIT => {
                    PostQuitMessage(0);
                }
                _ => {}
            }
            LRESULT(0)
        }
        WM_DESTROY => {
            PostQuitMessage(0);
            LRESULT(0)
        }
        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

unsafe extern "system" fn keyboard_hook_proc(
    code: i32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    if code >= 0 && (wparam.0 as u32 == WM_KEYDOWN || wparam.0 as u32 == WM_SYSKEYDOWN) {
        let kbd = *(lparam.0 as *const KBDLLHOOKSTRUCT);
        
        // F12 toggles Bengali / English mode
        if kbd.vkCode == VK_F12.0 as u32 {
            let new_state = !BANGLA_ENABLED.load(Ordering::SeqCst);
            BANGLA_ENABLED.store(new_state, Ordering::SeqCst);
            
            // Clear input buffer on toggle
            if let Ok(mut state) = STATE.lock() {
                state.buffer.clear();
                state.candidates.clear();
            }
            return LRESULT(1);
        }

        if BANGLA_ENABLED.load(Ordering::SeqCst) && !IS_PROCESSING.load(Ordering::SeqCst) {
            // Process character typing if within printable ASCII range
            if (0x41..=0x5A).contains(&kbd.vkCode) || (0x30..=0x39).contains(&kbd.vkCode) || kbd.vkCode == VK_SPACE.0 as u32 {
                // Key processing logic with Riti Avro engine
            }
        }
    }

    CallNextHookEx(None, code, wparam, lparam)
}
