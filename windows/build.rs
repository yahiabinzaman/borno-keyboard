fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default() == "windows" {
        let mut res = winres::WindowsResource::new();
        res.set_icon("resources/borno.ico");
        res.set("ProductName", "Borno");
        res.set("FileDescription", "Borno - Avro Bengali Input Method for Windows");
        res.set("LegalCopyright", "Copyright (c) 2026 Yahia Bin Zaman");
        res.set("CompanyName", "Borno");
        res.compile().unwrap();
    }
}
