fn main() {
    // Avoid failing if rc.exe is not present during cross-compilation
    if std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default() == "windows" {
        let mut res = winres::WindowsResource::new();
        res.set_icon("resources/borno.ico");
        let _ = res.compile();
    }
}
