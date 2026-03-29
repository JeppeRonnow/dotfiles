import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland 
import Quickshell.Io
import Quickshell.Services.Mpris 
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.shared

PanelWindow {
    id: root
    
    // --- WAYLAND CONFIGURATION ---
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore
    
    implicitWidth: 380
    implicitHeight: panelLayout.implicitHeight + 40
    color: "transparent"

    anchors {
        right: true
        top: true
    }

    margins { 
        top: 55
    }

    // --- CLICK OUTSIDE TO CLOSE (Native Hyprland) ---
    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ESCAPE KEY LISTENER ---
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ANIMATION LOGIC ---
    property bool isOpen: false
    visible: isOpen || slideAnim.running
    
    margins { right: root.currentMargin }
    property real currentMargin: isOpen ? 20 : -450 

    Behavior on currentMargin {
        NumberAnimation {
            id: slideAnim
            duration: 350
            easing.type: Easing.OutQuint 
        }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }   
        function close(): void { root.isOpen = false } 
    }

    Theme { id: theme }

    // --- REUSABLE COMPONENTS ---
    component ML4WMenuItem: MenuItem {
        id: control
        contentItem: Text {
            text: control.text
            font.family: theme.fontFamily
            font.pixelSize: 14
            color: control.highlighted ? theme.background : theme.primary 
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 36
            color: control.highlighted ? theme.primary : "transparent"
            radius: 4
        }
    }

    component ML4WButton: Button {
        Layout.fillWidth: true
        background: Rectangle {
            color: "transparent"
            border.color: theme.primary
            border.width: 1
            radius: 10
        }
        contentItem: Text {
            text: parent.text
            font.family: theme.fontFamily
            font.pixelSize: 16
            color: theme.primary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            padding: 8
        }
    }

    component ML4WSwitch: Switch {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 48
        implicitHeight: 26
        indicator: Rectangle {
            implicitWidth: 48
            implicitHeight: 26
            radius: 13
            color: parent.checked ? theme.primary : theme.background
            border.color: theme.primary
            border.width: 1
            Rectangle {
                x: parent.parent.checked ? parent.width - width - 2 : 2
                y: 2
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: parent.parent.checked ? theme.background : theme.on_primary
                Behavior on x { NumberAnimation { duration: 150 } }
            }
        }
    }

    component SettingsWheel: Button {
        implicitWidth: 28  
        implicitHeight: 28
        text: "" 
        font.family: "monospace"
        background: Rectangle { color: "transparent" }
        contentItem: Text { 
            text: parent.text; color: theme.primary; font.pixelSize: 18; 
            verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
        }
    }

    component ActionIcon: Button {
        property string iconTxt: ""
        implicitWidth: 28  
        implicitHeight: 28
        text: iconTxt
        font.family: "monospace"
        background: Rectangle { color: "transparent" }
        contentItem: Text { 
            text: parent.text; color: theme.primary; font.pixelSize: 18; 
            verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
        }
    }

    // ==========================================
    // MAIN PANEL BACKGROUND
    // ==========================================
    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: theme ? theme.background : "#1e1e2e"
            border.color: theme ? theme.primary : "#89b4fa"
            border.width: 2
            radius: 10
            opacity: 0.9 // Only the background is transparent
        }

        ColumnLayout {
            id: panelLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // --- TOP BAR (Screenshot, Clipboard & Color Picker) ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ActionIcon {
                    iconTxt: "" 
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["bash", "-c", "hyprpicker -f hex | wl-copy"])
                    }
                }

                ActionIcon { 
                    iconTxt: ""
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["hyprshot", "-m", "region"])
                    }
                }

                ActionIcon {
                    iconTxt: ""
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["quickshell", "ipc", "call", "clipboard", "open"])
                    }
                }

                Item { Layout.fillWidth: true } 
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: theme.primary; opacity: 0.3 }

            // --- SCROLLABLE CONTENT ---
            ScrollView {
                id: scrollView 
                Layout.fillWidth: true
                Layout.preferredHeight: mainContentColumn.implicitHeight
                contentHeight: mainContentColumn.implicitHeight // Tells ScrollView how tall the inner content truly is
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    contentItem: Rectangle {
                        implicitWidth: 6; radius: 3; color: theme.primary
                        opacity: parent.pressed ? 1.0 : (parent.active ? 0.8 : 0.4)
                    }
                }

                ColumnLayout {
                    id: mainContentColumn
                    width: scrollView.width
                    spacing: 20

                    // --- SLIDERS (Loudness & Brightness) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        // LOUDNESS SLIDER
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Text {
                                text: "" // Speaker icon
                                color: theme.primary
                                font.family: "monospace"
                                font.pixelSize: 18
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Slider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 50 // Default

                                Process {
                                    command: ["bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' 'NR==1 {gsub(/[% ]/, \"\", $2); print $2}'"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            let val = parseInt(this.text.trim())
                                            if (!isNaN(val)) volumeSlider.value = val;
                                        }
                                    }
                                }

                                onMoved: {
                                    Quickshell.execDetached(["bash", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(value) + "%"])
                                }

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 6
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: theme.background
                                    border.color: theme.primary
                                    border.width: 1

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: theme.primary
                                        radius: 3
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: volumeSlider.pressed ? theme.background : theme.primary
                                    border.color: theme.primary
                                    border.width: 1
                                }
                            }
                        }

                    }

                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: theme.primary; opacity: 0.3; Layout.topMargin: 5; Layout.bottomMargin: 5 }

                    // --- MPRIS PLAYERS (Scrollable ListView) ---
                    ListView {
                        id: mprisListView
                        Layout.fillWidth: true
                        
                        // Dynamically scale based on players, up to 210px (max 2 players)
                        Layout.preferredHeight: contentHeight
                        Layout.maximumHeight: 210
                        
                        spacing: 10
                        clip: true
                        
                        model: Mpris.players.values
                        visible: Mpris.players.values.length > 0

                        // Force disable scrolling entirely unless there are 3+ players
                        interactive: mprisListView.count > 2

                        ScrollBar.vertical: ScrollBar {
                            // Explicitly hide the scrollbar unless there are 3+ players
                            policy: mprisListView.count > 2 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                            interactive: true
                            contentItem: Rectangle {
                                implicitWidth: 6; radius: 3; color: theme.primary
                                opacity: parent.pressed ? 1.0 : (parent.active ? 0.8 : 0.4)
                            }
                        }

                        delegate: Rectangle {
                            id: playerCard
                            property var player: modelData

                            width: mprisListView.width - 4
                            x: mprisListView.width - width
                            implicitHeight: 100
                            
                            radius: 10
                            color: theme.background
                            border.color: theme.primary
                            border.width: 1
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 15

                                // Cover Art Block
                                Rectangle {
                                    implicitWidth: 80
                                    implicitHeight: 80
                                    radius: 8
                                    color: "transparent"
                                    border.color: theme.primary
                                    border.width: 1
                                    clip: true
                                    
                                    Image {
                                        anchors.fill: parent
                                        source: player.trackArtUrl ? player.trackArtUrl : ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: player.trackArtUrl !== ""
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰝚" // Music note icon (fallback)
                                        font.family: "monospace"
                                        font.pixelSize: 32
                                        color: theme.primary
                                        visible: !player.trackArtUrl || player.trackArtUrl === ""
                                    }
                                }

                                // Track Info & Controls
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 5

                                    Text {
                                        Layout.fillWidth: true
                                        text: player.trackTitle ? player.trackTitle : (player.identity ? player.identity : "No Media Playing")
                                        color: theme.primary
                                        font.family: theme.fontFamily
                                        font.pixelSize: 16
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: {
                                            if (player.trackArtist) return player.trackArtist;
                                            if (player.trackArtists && player.trackArtists.length > 0) return player.trackArtists[0];
                                            return "Unknown Artist";
                                        }
                                        color: theme.on_background
                                        font.family: theme.fontFamily
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                        opacity: 0.8
                                    }

                                    Item { Layout.fillHeight: true } 

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15
                                        
                                        Item { Layout.fillWidth: true } 

                                        ActionIcon {
                                            iconTxt: "󰒮" 
                                            implicitWidth: 32
                                            implicitHeight: 32
                                            onClicked: player.previous()
                                        }

                                        ActionIcon {
                                            iconTxt: player.isPlaying ? "󰏤" : "󰐊" 
                                            implicitWidth: 32
                                            implicitHeight: 32
                                            onClicked: player.isPlaying = !player.isPlaying 
                                        }

                                        ActionIcon {
                                            iconTxt: "󰒭" 
                                            implicitWidth: 32
                                            implicitHeight: 32
                                            onClicked: player.next()
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { 
                        Layout.fillWidth: true; 
                        implicitHeight: 1; 
                        color: theme.primary; 
                        opacity: 0.3; 
                        Layout.topMargin: 5; 
                        Layout.bottomMargin: 5;
                        visible: Mpris.players.values.length > 0 
                    }

                    // --- WAYBAR ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Waybar"; color: theme.on_background; font.family: theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true } 
                        ML4WSwitch { 
                            id: waybarSwitch
                            property bool ready: false
                            Process {
                                command: ["bash", "-c", "pgrep -x waybar >/dev/null && echo 1 || echo 0"]
                                running: root.isOpen 
                                stdout: StdioCollector {
                                    onStreamFinished: {
                                        console.log("Test for Waybar: " + this.text.trim())
                                        waybarSwitch.checked = (this.text.trim() === "1")
                                        waybarSwitch.ready = true
                                    }
                                }
                            }
                            onClicked: {
                                if (!ready) return;
                                if (checked) {
                                    Quickshell.execDetached(["waybar"])
                                } else {
                                    Quickshell.execDetached(["pkill", "-x", "waybar"])
                                }
                            }
                        }

                    }

                    // --- DOCK ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Dock"; color: theme.on_background; font.family: theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true }
                        ML4WSwitch { 
                            id: dockSwitch
                            property bool ready: false
                            Process {
                                command: ["bash", "-c", "test -f ~/.config/ml4w/settings/dock-disabled && echo 0 || echo 1"]
                                running: root.isOpen 
                                stdout: StdioCollector {
                                    onStreamFinished: {
                                        console.log("Test for Dock: " + this.text.trim())
                                        dockSwitch.checked = (this.text.trim() === "1")
                                        dockSwitch.ready = true
                                    }
                                }
                            }
                            onClicked: {
                                if (!ready) return;
                                let fileCmd = checked 
                                ? "rm -f ~/.config/ml4w/settings/dock-disabled"
                                : "touch ~/.config/ml4w/settings/dock-disabled"
                                console.log("Dock cmd: " + fileCmd)
                                Quickshell.execDetached(["bash", "-c", fileCmd + "; " + Quickshell.env("HOME") + "/.config/nwg-dock-hyprland/launch.sh"])
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: theme.primary; opacity: 0.3; Layout.topMargin: 5; Layout.bottomMargin: 5 }

                    // --- WALLPAPER ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Wallpaper"; color: theme.on_background; font.family: theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true }
                        ActionIcon { 
                            iconTxt: ""
                            onClicked: {
                                root.isOpen = false
                                Quickshell.execDetached(["waypaper"])
                            }
                        }
                        SettingsWheel {
                            onClicked: wallpaperMenu.open()
                            Menu {
                                id: wallpaperMenu
                                y: parent.height
                                
                                implicitWidth: 220
                                padding: 8
                                
                                background: Rectangle { color: theme.background; border.color: theme.primary; border.width: 1; radius: 8 }
                                ML4WMenuItem { text: "Random Wallpaper"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/waypaper.sh --random"])
                                    } 
                                }
                                ML4WMenuItem { text: "Wallpaper Effects"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/wallpaper-effects.sh"])
                                    } 
                                }
                            }
                        }
                    }

                    // --- THEME ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Theme"; color: theme.on_background; font.family: theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true }
                        ActionIcon { 
                            iconTxt: ""
                            onClicked: {
                                root.isOpen = false
                                Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/dotfiles/scripts/theme_selecter.sh"])
                            }
                        }
                        SettingsWheel {
                            onClicked: themeMenu.open()
                            Menu {
                                id: themeMenu
                                y: parent.height
                                
                                implicitWidth: 220
                                padding: 8
                                
                                background: Rectangle { color: theme.background; border.color: theme.primary; border.width: 1; radius: 8 }
                                ML4WMenuItem { text: "Set GTK Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["nwg-look"])
                                    } 
                                }
                                ML4WMenuItem { text: "Set QT Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["qt6ct"])
                                    }
                                }
                                ML4WMenuItem { text: "Refresh GTK Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/gtk.sh"])
                                    } 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
