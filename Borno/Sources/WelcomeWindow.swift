import Cocoa

// MARK: - Window Controller (Singleton)

class WelcomeWindowController: NSObject, NSWindowDelegate {
    static let shared = WelcomeWindowController()

    private var window: NSWindow?

    func showWindow() {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            
            if self.window == nil {
                let win = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 880, height: 620),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                win.title = "Borno (বর্ণ) — Preferences & Guide"
                win.isReleasedWhenClosed = false
                win.isRestorable = false
                win.minSize = NSSize(width: 800, height: 540)
                win.backgroundColor = .windowBackgroundColor

                let container = ModernSplitContainerView()
                win.contentView = container
                win.setContentSize(NSSize(width: 880, height: 620))
                win.center()
                win.delegate = self
                self.window = win
            }

            guard let win = self.window else { return }
            win.center()
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

// MARK: - Modern Native Split Layout

class ModernSplitContainerView: NSView {
    private let sidebarView = ModernSidebarView()
    private let detailContainer = NSView()

    private let gettingStartedView = ModernGettingStartedView()
    private let layoutView = ModernAvroLayoutView()
    private let settingsView = ModernSettingsView()
    private let aboutView = ModernAboutView()

    private var currentDetailView: NSView?

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 880, height: 620)
    }

    override var fittingSize: NSSize {
        return NSSize(width: 880, height: 620)
    }

    override init(frame: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: 880, height: 620))
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        wantsLayer = true

        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.onSelectTab = { [weak self] tabIndex in
            self?.switchTab(index: tabIndex)
        }
        addSubview(sidebarView)

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        detailContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailContainer)

        NSLayoutConstraint.activate([
            sidebarView.topAnchor.constraint(equalTo: topAnchor),
            sidebarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: 220),

            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),

            detailContainer.topAnchor.constraint(equalTo: topAnchor),
            detailContainer.leadingAnchor.constraint(equalTo: separator.trailingAnchor),
            detailContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 860),
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 600),
        ])

        switchTab(index: 0)
    }

    private func switchTab(index: Int) {
        currentDetailView?.removeFromSuperview()

        let nextView: NSView
        switch index {
        case 0: nextView = gettingStartedView
        case 1: nextView = layoutView
        case 2: nextView = settingsView
        case 3: nextView = aboutView
        default: nextView = gettingStartedView
        }

        nextView.translatesAutoresizingMaskIntoConstraints = false
        detailContainer.addSubview(nextView)

        NSLayoutConstraint.activate([
            nextView.topAnchor.constraint(equalTo: detailContainer.topAnchor),
            nextView.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor),
            nextView.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor),
            nextView.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor),
        ])

        currentDetailView = nextView
    }
}

// MARK: - Modern Sidebar View

class ModernSidebarView: NSView {
    var onSelectTab: ((Int) -> Void)?
    private var itemButtons: [SidebarItemButton] = []
    private var selectedIndex = 0

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // App Branding Header
        let headerStack = NSStackView()
        headerStack.orientation = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .centerY
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 10
        iconView.layer?.masksToBounds = true
        if let logoPath = Bundle.main.path(forResource: "BornoGreenIcon", ofType: "png"),
           let img = NSImage(contentsOfFile: logoPath) {
            iconView.image = img
        } else {
            iconView.image = NSApp.applicationIconImage
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 38),
            iconView.heightAnchor.constraint(equalToConstant: 38),
        ])

        let titleStack = NSStackView()
        titleStack.orientation = .vertical
        titleStack.alignment = .leading
        titleStack.spacing = 1

        let appTitle = NSTextField(labelWithString: "Borno")
        appTitle.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        appTitle.textColor = .labelColor

        let appSub = NSTextField(labelWithString: "বর্ণ · Avro Keyboard")
        appSub.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        appSub.textColor = .secondaryLabelColor

        titleStack.addArrangedSubview(appTitle)
        titleStack.addArrangedSubview(appSub)

        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleStack)

        addSubview(headerStack)

        // Nav Section Label
        let menuLabel = NSTextField(labelWithString: "NAVIGATION")
        menuLabel.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        menuLabel.textColor = .tertiaryLabelColor
        menuLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuLabel)

        // Nav Items
        let navStack = NSStackView()
        navStack.orientation = .vertical
        navStack.spacing = 4
        navStack.alignment = .leading
        navStack.translatesAutoresizingMaskIntoConstraints = false

        let tabs = [
            ("sparkles", "Getting Started"),
            ("keyboard", "Avro Layout"),
            ("gearshape", "Settings"),
            ("info.circle", "About Borno")
        ]

        for (index, (symbol, title)) in tabs.enumerated() {
            let btn = SidebarItemButton(symbol: symbol, title: title, index: index)
            btn.onClick = { [weak self] idx in
                self?.selectTab(idx)
            }
            itemButtons.append(btn)
            navStack.addArrangedSubview(btn)
            btn.widthAnchor.constraint(equalTo: navStack.widthAnchor).isActive = true
        }

        addSubview(navStack)

        // Footer version chip
        let footerStack = NSStackView()
        footerStack.orientation = .horizontal
        footerStack.spacing = 6
        footerStack.alignment = .centerY
        footerStack.translatesAutoresizingMaskIntoConstraints = false

        let dot = NSView()
        dot.wantsLayer = true
        dot.layer?.cornerRadius = 4
        dot.layer?.backgroundColor = NSColor.systemGreen.cgColor
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])

        let verLabel = NSTextField(labelWithString: "v0.2.5 · Ready")
        verLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        verLabel.textColor = .secondaryLabelColor

        footerStack.addArrangedSubview(dot)
        footerStack.addArrangedSubview(verLabel)
        addSubview(footerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 46),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            menuLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 28),
            menuLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),

            navStack.topAnchor.constraint(equalTo: menuLabel.bottomAnchor, constant: 8),
            navStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            navStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            footerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            footerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])

        selectTab(0)
    }

    private func selectTab(_ index: Int) {
        selectedIndex = index
        for (i, btn) in itemButtons.enumerated() {
            btn.isSelected = (i == index)
        }
        onSelectTab?(index)
    }
}

// MARK: - Sidebar Item Button

class SidebarItemButton: NSView {
    let index: Int
    var onClick: ((Int) -> Void)?
    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private var isHovered = false

    init(symbol: String, title: String, index: Int) {
        self.index = index
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        if let sysImg = NSImage(systemSymbolName: symbol, accessibilityDescription: title) {
            iconView.image = sysImg
        }
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentTintColor = .secondaryLabelColor

        titleLabel.stringValue = title
        titleLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .medium)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView(views: [iconView, titleLabel])
        stack.orientation = .horizontal
        stack.spacing = 10
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))

        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        onClick?(index)
    }

    private func updateAppearance() {
        if isSelected {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.2).cgColor
            titleLabel.textColor = .controlAccentColor
            titleLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .semibold)
            iconView.contentTintColor = .controlAccentColor
        } else if isHovered {
            layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
            titleLabel.textColor = .labelColor
            titleLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .medium)
            iconView.contentTintColor = .labelColor
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            titleLabel.textColor = .secondaryLabelColor
            titleLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .medium)
            iconView.contentTintColor = .secondaryLabelColor
        }
    }
}

// MARK: - Native Apple Card Container

class AppleGroupCard: NSView {
    init(content: NSView, padding: CGFloat = 16) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.5).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.25).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Tab 1: Getting Started View

class ModernGettingStartedView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let doc = NSView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = doc

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(stack)

        NSLayoutConstraint.activate([
            doc.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            doc.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            doc.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            doc.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
            doc.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 36),

            stack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -28),
        ])

        // Section Title
        let headerLabel = NSTextField(labelWithString: "Getting Started")
        headerLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        headerLabel.textColor = .labelColor
        stack.addArrangedSubview(headerLabel)

        // 1. Setup Instructions Card
        let setupTitle = sectionTitle(title: "QUICK SETUP", icon: "gearshape.fill")
        stack.addArrangedSubview(setupTitle)

        let stepsStack = NSStackView()
        stepsStack.orientation = .vertical
        stepsStack.spacing = 14
        stepsStack.alignment = .leading

        let steps = [
            (1, "Log out & log back in", "Only required the very first time you install Borno."),
            (2, "Open System Settings → Keyboard", "Navigate to Text Input → Input Sources → click Edit..."),
            (3, "Add Borno (বর্ণ)", "Click (+), search for \"Borno\", select Bengali language and click Add."),
            (4, "Start Typing!", "Use Globe (🌐) key or Ctrl + Space to switch seamlessly between English and Borno.")
        ]

        for (num, title, subtitle) in steps {
            let row = makeStepRow(num: num, title: title, sub: subtitle)
            stepsStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: stepsStack.widthAnchor).isActive = true
        }

        let setupCard = AppleGroupCard(content: stepsStack)
        stack.addArrangedSubview(setupCard)
        setupCard.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

        // 2. Typing Guide Card
        let guideTitle = sectionTitle(title: "HOW TO TYPE PHONETICALLY", icon: "text.cursor")
        stack.addArrangedSubview(guideTitle)

        let guideStack = NSStackView()
        guideStack.orientation = .vertical
        guideStack.spacing = 12
        guideStack.alignment = .leading

        let shortcuts = [
            ("ami → আমি", "Type English spelling phonetically to get Bengali words"),
            ("Space", "Commit the highlighted word immediately"),
            ("1 — 9", "Select a specific candidate suggestion from the popup"),
            ("↑ ↓", "Navigate up and down through suggestions"),
            ("Backspace", "Erase the last typed letter"),
            ("Esc", "Cancel the active phonetic session")
        ]

        for (key, desc) in shortcuts {
            let row = makeShortcutRow(key: key, desc: desc)
            guideStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: guideStack.widthAnchor).isActive = true
        }

        let guideCard = AppleGroupCard(content: guideStack)
        stack.addArrangedSubview(guideCard)
        guideCard.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    private func sectionTitle(title: String, icon: String) -> NSView {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 6
        stack.alignment = .centerY

        if let img = NSImage(systemSymbolName: icon, accessibilityDescription: nil) {
            let iv = NSImageView(image: img)
            iv.contentTintColor = .controlAccentColor
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 14).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 14).isActive = true
            stack.addArrangedSubview(iv)
        }

        let lbl = NSTextField(labelWithString: title)
        lbl.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = .secondaryLabelColor
        stack.addArrangedSubview(lbl)

        return stack
    }

    private func makeStepRow(num: Int, title: String, sub: String) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 14
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false

        // Circle Badge
        let badge = NSView()
        badge.wantsLayer = true
        badge.layer?.cornerRadius = 11
        badge.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 22),
            badge.heightAnchor.constraint(equalToConstant: 22)
        ])

        let numLabel = NSTextField(labelWithString: "\(num)")
        numLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        numLabel.textColor = .white
        numLabel.alignment = .center
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(numLabel)
        NSLayoutConstraint.activate([
            numLabel.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])

        let textStack = NSStackView()
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        let tLabel = NSTextField(labelWithString: title)
        tLabel.font = NSFont.systemFont(ofSize: 13.5, weight: .semibold)
        tLabel.textColor = .labelColor

        let sLabel = NSTextField(wrappingLabelWithString: sub)
        sLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        sLabel.textColor = .secondaryLabelColor

        textStack.addArrangedSubview(tLabel)
        textStack.addArrangedSubview(sLabel)

        row.addArrangedSubview(badge)
        row.addArrangedSubview(textStack)

        return row
    }

    private func makeShortcutRow(key: String, desc: String) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 12
        row.alignment = .centerY
        row.translatesAutoresizingMaskIntoConstraints = false

        let chip = makeKeyCap(text: key)
        let dLabel = NSTextField(labelWithString: desc)
        dLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        dLabel.textColor = .secondaryLabelColor

        row.addArrangedSubview(chip)
        row.addArrangedSubview(dLabel)

        return row
    }

    private func makeKeyCap(text: String) -> NSView {
        let chip = NSView()
        chip.wantsLayer = true
        chip.layer?.cornerRadius = 6
        chip.layer?.backgroundColor = NSColor.controlTextColor.withAlphaComponent(0.08).cgColor
        chip.layer?.borderWidth = 1
        chip.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        chip.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: text)
        label.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: chip.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -8),
        ])

        return chip
    }
}

// MARK: - Tab 2: Native Avro Layout View

class ModernAvroLayoutView: NSView {
    private var allCards: [NSView] = []
    private let searchField = NSSearchField()
    private let contentStack = NSStackView()

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let topBar = NSStackView()
        topBar.orientation = .horizontal
        topBar.spacing = 12
        topBar.alignment = .centerY
        topBar.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "Avro Layout Reference")
        title.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        title.textColor = .labelColor

        searchField.placeholderString = "Search character or key..."
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.target = self
        searchField.action = #selector(onSearchChanged)
        searchField.widthAnchor.constraint(equalToConstant: 240).isActive = true

        topBar.addArrangedSubview(title)
        topBar.addArrangedSubview(searchField)

        addSubview(topBar)

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let doc = NSView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = doc

        contentStack.orientation = .vertical
        contentStack.alignment = .leading
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(contentStack)

        NSLayoutConstraint.activate([
            doc.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            doc.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            doc.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            doc.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
            doc.bottomAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 36),

            contentStack.topAnchor.constraint(equalTo: doc.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 28),
            contentStack.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -28),
        ])

        buildLayoutSections()
    }

    private func buildLayoutSections() {
        // Consonants
        let consonants: [(String, String)] = [
            ("ক", "k"), ("খ", "kh"), ("গ", "g"), ("ঘ", "gh"), ("ঙ", "Ng"),
            ("চ", "c"), ("ছ", "ch"), ("জ", "j"), ("ঝ", "jh"), ("ঞ", "NG"),
            ("ট", "T"), ("ঠ", "Th"), ("ড", "D"), ("ঢ", "Dh"), ("ণ", "N"),
            ("ত", "t"), ("থ", "th"), ("দ", "d"), ("ধ", "dh"), ("ন", "n"),
            ("প", "p"), ("ফ", "ph, f"), ("ব", "b"), ("ভ", "bh, v"), ("ম", "m"),
            ("য", "z"), ("র", "r"), ("ল", "l"), ("শ", "sh, S"), ("ষ", "Sh"),
            ("স", "s"), ("হ", "h"), ("ড়", "R"), ("ঢ়", "Rh"), ("য়", "y, Y"),
            ("ৎ", "t``"), ("ং", "ng"), ("ঃ", ":"), ("ঁ", "^")
        ]
        addSection(title: "CONSONANTS (ব্যঞ্জনবর্ণ)", items: consonants, columns: 4)

        // Vowels
        let vowels: [(String, String)] = [
            ("অ", "o"), ("আ / া", "a"), ("ই / ি", "i"), ("ঈ / ী", "I"),
            ("উ / ু", "u"), ("ঊ / ূ", "U"), ("ঋ / ৃ", "rri"), ("এ / ে", "e"),
            ("ঐ / ৈ", "OI"), ("ও / ো", "O"), ("ঔ / ৌ", "OU")
        ]
        addSection(title: "VOWELS (স্বরবর্ণ ও কার)", items: vowels, columns: 3)

        // Special & Modifiers
        let special: [(String, String)] = [
            ("্ হসন্ত", ",,"), ("ব-ফলা", "w"), ("রেফ", "rr"),
            ("় নুক্তা", ".."), ("য-ফলা", "y, Z"), ("। দাড়ি", "."),
            ("ZWJ", "`"), ("র-ফলা", "r"), ("৳ টাকা", "$"),
            ("ZWNJ", "~")
        ]
        addSection(title: "SPECIAL & MODIFIERS", items: special, columns: 3)

        // Numbers
        let numbers: [(String, String)] = [
            ("০", "0"), ("১", "1"), ("২", "2"), ("৩", "3"), ("৪", "4"),
            ("৫", "5"), ("৬", "6"), ("৭", "7"), ("৮", "8"), ("৯", "9")
        ]
        addSection(title: "NUMBERS (সংখ্যা)", items: numbers, columns: 5)
    }

    private func addSection(title: String, items: [(String, String)], columns: Int) {
        let secLabel = NSTextField(labelWithString: title)
        secLabel.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        secLabel.textColor = .secondaryLabelColor
        contentStack.addArrangedSubview(secLabel)

        let grid = NSGridView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.rowSpacing = 8
        grid.columnSpacing = 8

        var currentRow: [NSView] = []
        for (bangla, key) in items {
            let cell = makeGridCell(bangla: bangla, key: key)
            currentRow.append(cell)
            if currentRow.count == columns {
                grid.addRow(with: currentRow)
                currentRow.removeAll()
            }
        }
        if !currentRow.isEmpty {
            while currentRow.count < columns {
                let empty = NSView()
                currentRow.append(empty)
            }
            grid.addRow(with: currentRow)
        }

        let card = AppleGroupCard(content: grid, padding: 12)
        contentStack.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
        allCards.append(card)
    }

    private func makeGridCell(bangla: String, key: String) -> NSView {
        let cell = NSView()
        cell.wantsLayer = true
        cell.layer?.cornerRadius = 8
        cell.layer?.backgroundColor = NSColor.controlTextColor.withAlphaComponent(0.04).cgColor
        cell.translatesAutoresizingMaskIntoConstraints = false

        let bLabel = NSTextField(labelWithString: bangla)
        bLabel.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        bLabel.textColor = .labelColor
        bLabel.translatesAutoresizingMaskIntoConstraints = false

        let kLabel = NSTextField(labelWithString: key)
        kLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        kLabel.textColor = .controlAccentColor
        kLabel.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(bLabel)
        cell.addSubview(kLabel)

        NSLayoutConstraint.activate([
            cell.heightAnchor.constraint(equalToConstant: 38),
            bLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
            bLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            kLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
            kLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])

        return cell
    }

    @objc private func onSearchChanged() {
        // Simple search highlighting/filtering
    }
}

// MARK: - Tab 3: Native Settings View

class ModernSettingsView: NSView {
    private var modeCards: [AppleModeSelectCard] = []

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
        ])

        let title = NSTextField(labelWithString: "Typing Preferences")
        title.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        title.textColor = .labelColor
        stack.addArrangedSubview(title)

        let subtitle = NSTextField(wrappingLabelWithString: "Choose how Borno converts phonetic English input into Bengali words. Changes take effect immediately.")
        subtitle.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        stack.addArrangedSubview(subtitle)

        let currentMode = BornoInputController.TypingMode(
            rawValue: UserDefaults.standard.string(forKey: BornoInputController.typingModeKey) ?? ""
        ) ?? .smart

        let modes: [(BornoInputController.TypingMode, String, String, Bool)] = [
            (.smart, "Smart suggestions", "Dictionary, auto-correction, and emojis choose the best matching word on Space. Arrow keys or numbers pick alternatives.", true),
            (.phoneticFirst, "Phonetic-first", "Your exact phonetic spelling commits by default, with suggestion list instantly available for quick selection.", false),
            (.phoneticOnly, "Phonetic-only", "Pure direct transliteration without suggestion popup or autocorrect. Maximum speed for touch typists.", false),
        ]

        let cardStack = NSStackView()
        cardStack.orientation = .vertical
        cardStack.spacing = 10
        cardStack.alignment = .leading

        for (mode, mTitle, desc, isRec) in modes {
            let card = AppleModeSelectCard(mode: mode, title: mTitle, desc: desc, isRecommended: isRec)
            card.isSelected = (mode == currentMode)
            card.onSelect = { [weak self] selectedMode in
                self?.handleSelect(selectedMode)
            }
            modeCards.append(card)
            cardStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: cardStack.widthAnchor).isActive = true
        }

        let group = AppleGroupCard(content: cardStack, padding: 8)
        stack.addArrangedSubview(group)
        group.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    private func handleSelect(_ mode: BornoInputController.TypingMode) {
        for card in modeCards {
            card.isSelected = (card.mode == mode)
        }
        UserDefaults.standard.set(mode.rawValue, forKey: BornoInputController.typingModeKey)
        NotificationCenter.default.post(name: .bornoTypingModeChanged, object: nil)
    }
}

// MARK: - Apple Mode Select Card

class AppleModeSelectCard: NSView {
    let mode: BornoInputController.TypingMode
    var onSelect: ((BornoInputController.TypingMode) -> Void)?
    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    private let radioCircle = NSView()
    private let innerDot = NSView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let descLabel = NSTextField(wrappingLabelWithString: "")
    private var isHovered = false

    init(mode: BornoInputController.TypingMode, title: String, desc: String, isRecommended: Bool) {
        self.mode = mode
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false

        // Radio circle
        radioCircle.wantsLayer = true
        radioCircle.layer?.cornerRadius = 9
        radioCircle.layer?.borderWidth = 1.5
        radioCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radioCircle.widthAnchor.constraint(equalToConstant: 18),
            radioCircle.heightAnchor.constraint(equalToConstant: 18)
        ])

        innerDot.wantsLayer = true
        innerDot.layer?.cornerRadius = 4.5
        innerDot.layer?.backgroundColor = NSColor.white.cgColor
        innerDot.translatesAutoresizingMaskIntoConstraints = false
        radioCircle.addSubview(innerDot)
        NSLayoutConstraint.activate([
            innerDot.widthAnchor.constraint(equalToConstant: 9),
            innerDot.heightAnchor.constraint(equalToConstant: 9),
            innerDot.centerXAnchor.constraint(equalTo: radioCircle.centerXAnchor),
            innerDot.centerYAnchor.constraint(equalTo: radioCircle.centerYAnchor)
        ])

        // Title row
        let titleRow = NSStackView()
        titleRow.orientation = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .centerY

        titleLabel.stringValue = title
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleRow.addArrangedSubview(titleLabel)

        if isRecommended {
            let badge = makeBadge(text: "Recommended")
            titleRow.addArrangedSubview(badge)
        }

        descLabel.stringValue = desc
        descLabel.font = NSFont.systemFont(ofSize: 12.5, weight: .regular)
        descLabel.textColor = .secondaryLabelColor

        let textCol = NSStackView(views: [titleRow, descLabel])
        textCol.orientation = .vertical
        textCol.alignment = .leading
        textCol.spacing = 3

        let mainRow = NSStackView(views: [radioCircle, textCol])
        mainRow.orientation = .horizontal
        mainRow.spacing = 14
        mainRow.alignment = .top
        mainRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainRow)

        NSLayoutConstraint.activate([
            mainRow.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            mainRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            mainRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
        ])

        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))

        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAppearance()
    }

    override func mouseUp(with event: NSEvent) {
        onSelect?(mode)
    }

    private func makeBadge(text: String) -> NSView {
        let b = NSView()
        b.wantsLayer = true
        b.layer?.cornerRadius = 5
        b.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.15).cgColor
        b.translatesAutoresizingMaskIntoConstraints = false

        let l = NSTextField(labelWithString: text)
        l.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = .systemBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        b.addSubview(l)

        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: b.leadingAnchor, constant: 6),
            l.trailingAnchor.constraint(equalTo: b.trailingAnchor, constant: -6),
            l.topAnchor.constraint(equalTo: b.topAnchor, constant: 2),
            l.bottomAnchor.constraint(equalTo: b.bottomAnchor, constant: -2),
        ])
        return b
    }

    private func updateAppearance() {
        if isSelected {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.12).cgColor
            layer?.borderWidth = 1.5
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            radioCircle.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
            radioCircle.layer?.borderColor = NSColor.controlAccentColor.cgColor
            innerDot.isHidden = false
        } else if isHovered {
            layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.04).cgColor
            layer?.borderWidth = 1
            layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
            radioCircle.layer?.backgroundColor = NSColor.clear.cgColor
            radioCircle.layer?.borderColor = NSColor.secondaryLabelColor.cgColor
            innerDot.isHidden = true
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderWidth = 1
            layer?.borderColor = NSColor.clear.cgColor
            radioCircle.layer?.backgroundColor = NSColor.clear.cgColor
            radioCircle.layer?.borderColor = NSColor.tertiaryLabelColor.cgColor
            innerDot.isHidden = true
        }
    }
}

// MARK: - Tab 4: Native About & Updates View

class ModernAboutView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let centerStack = NSStackView()
        centerStack.orientation = .vertical
        centerStack.alignment = .centerX
        centerStack.spacing = 16
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerStack)

        NSLayoutConstraint.activate([
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerStack.widthAnchor.constraint(lessThanOrEqualToConstant: 460)
        ])

        // Large App Icon
        let iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 20
        iconView.layer?.masksToBounds = true
        if let logoPath = Bundle.main.path(forResource: "BornoGreenIcon", ofType: "png"),
           let img = NSImage(contentsOfFile: logoPath) {
            iconView.image = img
        } else {
            iconView.image = NSApp.applicationIconImage
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80)
        ])
        centerStack.addArrangedSubview(iconView)

        // Title
        let title = NSTextField(labelWithString: "Borno (বর্ণ)")
        title.font = NSFont.systemFont(ofSize: 26, weight: .bold)
        title.textColor = .labelColor
        centerStack.addArrangedSubview(title)

        let desc = NSTextField(wrappingLabelWithString: "Fast, minimal, native Avro Phonetic Bengali input method built exclusively for macOS and Windows.")
        desc.alignment = .center
        desc.font = NSFont.systemFont(ofSize: 13.5, weight: .regular)
        desc.textColor = .secondaryLabelColor
        centerStack.addArrangedSubview(desc)

        // Version Info Card
        let infoCard = AppleGroupCard(content: makeInfoRows(), padding: 14)
        centerStack.addArrangedSubview(infoCard)
        infoCard.widthAnchor.constraint(equalTo: centerStack.widthAnchor).isActive = true

        // Action Buttons
        let btnStack = NSStackView()
        btnStack.orientation = .horizontal
        btnStack.spacing = 12

        let updateBtn = NSButton(title: "Check for Updates", target: self, action: #selector(checkForUpdates))
        updateBtn.bezelStyle = .rounded
        updateBtn.controlSize = .large
        updateBtn.keyEquivalent = "\r"

        let gitBtn = NSButton(title: "GitHub Repository", target: self, action: #selector(openGitHub))
        gitBtn.bezelStyle = .rounded
        gitBtn.controlSize = .large

        btnStack.addArrangedSubview(updateBtn)
        btnStack.addArrangedSubview(gitBtn)
        centerStack.addArrangedSubview(btnStack)
    }

    private func makeInfoRows() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        let rows = [
            ("Version", "0.2.5 (Universal Binary)"),
            ("Architecture", "Apple Silicon (ARM64) + Intel (x86_64)"),
            ("Developer", "Yahia Bin Zaman"),
            ("License", "Open Source (MIT License)")
        ]

        for (k, v) in rows {
            let row = NSStackView()
            row.orientation = .horizontal
            row.distribution = .fill

            let kl = NSTextField(labelWithString: k)
            kl.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            kl.textColor = .secondaryLabelColor

            let vl = NSTextField(labelWithString: v)
            vl.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
            vl.textColor = .labelColor
            vl.alignment = .right

            row.addArrangedSubview(kl)
            row.addArrangedSubview(vl)

            stack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        return stack
    }

    @objc private func checkForUpdates() {
        if let url = URL(string: "https://github.com/yahiabinzaman/borno-keyboard/releases") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/yahiabinzaman/borno-keyboard") {
            NSWorkspace.shared.open(url)
        }
    }
}
