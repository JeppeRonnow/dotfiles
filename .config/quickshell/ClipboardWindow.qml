import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.shared

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property bool isOpen: false
    property int maxItems: 100
    property var entries: []
    property int selectedIndex: -1
    property int hoveredIndex: -1
    property int previewEntryId: -1
    property bool previewIsImage: false
    property string previewText: ""
    property string previewImagePath: ""

    visible: isOpen

    Theme { id: theme }

    function entryIsImage(preview: string): bool {
        return /^\[\[.*binary data.*\d+x\d+.*\]\]$/.test(preview)
    }

    function refresh(): void {
        cliphistListProcess.command = ["cliphist", "list"]
        cliphistListProcess.running = true
    }

    function filterScore(haystack: string, needle: string): real {
        if (needle.length === 0) {
            return 1
        }

        if (haystack === needle) {
            return 10000
        }

        const directIndex = haystack.indexOf(needle)
        if (directIndex >= 0) {
            return 5000 - directIndex
        }

        let score = 0
        let cursor = 0
        for (let i = 0; i < needle.length; i += 1) {
            const ch = needle[i]
            const found = haystack.indexOf(ch, cursor)
            if (found < 0) {
                return -1
            }
            score += 25 - (found - cursor)
            cursor = found + 1
        }

        return score
    }

    function rebuildFilteredModel(): void {
        const q = searchField.text.trim().toLowerCase()
        const scored = []

        for (const entry of entries) {
            const text = entry.preview.toLowerCase()
            const score = filterScore(text, q)
            if (score >= 0) {
                scored.push({
                    score: score,
                    entryId: entry.entryId,
                    preview: entry.preview,
                    isImage: entry.isImage
                })
            }
        }

        scored.sort((a, b) => b.score - a.score)

        filteredModel.clear()
        for (const item of scored) {
            filteredModel.append({
                entryId: item.entryId,
                preview: item.preview,
                isImage: item.isImage
            })
        }

        selectedIndex = filteredModel.count > 0 ? 0 : -1
        if (selectedIndex >= 0) {
            resultsView.positionViewAtIndex(selectedIndex, ListView.Beginning)
        }
        updatePreviewForActiveIndex()
    }

    function moveSelection(step: int): void {
        if (filteredModel.count === 0) {
            return
        }

        let next = selectedIndex
        if (next < 0) {
            next = 0
        } else {
            next += step
        }

        if (next < 0) {
            next = 0
        }
        if (next >= filteredModel.count) {
            next = filteredModel.count - 1
        }

        selectedIndex = next
        resultsView.positionViewAtIndex(next, ListView.Contain)

        if (hoveredIndex < 0) {
            updatePreviewForActiveIndex()
        }
    }

    function copyCurrent(): void {
        if (selectedIndex < 0 || selectedIndex >= filteredModel.count) {
            return
        }

        const selected = filteredModel.get(selectedIndex)
        Quickshell.execDetached(["bash", "-c", "cliphist decode " + selected.entryId + " | wl-copy"])
        isOpen = false
    }

    function updatePreviewForActiveIndex(): void {
        const index = hoveredIndex >= 0 ? hoveredIndex : selectedIndex
        if (index < 0 || index >= filteredModel.count) {
            previewEntryId = -1
            previewIsImage = false
            previewText = "No preview"
            previewImagePath = ""
            return
        }

        const item = filteredModel.get(index)
        previewEntryId = item.entryId
        previewIsImage = item.isImage
        previewImagePath = ""

        if (item.isImage) {
            previewText = "Image preview"
            imagePreviewProcess.entryId = item.entryId
            imagePreviewProcess.command = [
                "bash",
                "-c",
                "mkdir -p \"$HOME/.cache/quickshell/cliphist\"; mime=$(cliphist decode " + item.entryId + " | file --mime-type --brief -); ext=${mime#image/}; ext=${ext%%+*}; [ -z \"$ext\" ] && ext=img; out=\"$HOME/.cache/quickshell/cliphist/" + item.entryId + ".$ext\"; cliphist decode " + item.entryId + " > \"$out\"; printf '%s' \"$out\""
            ]
            imagePreviewProcess.running = true
            return
        }

        previewText = "Loading text..."
        textPreviewProcess.entryId = item.entryId
        textPreviewProcess.command = ["bash", "-c", "cliphist decode " + item.entryId]
        textPreviewProcess.running = true
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
    }

    onIsOpenChanged: {
        if (isOpen) {
            searchField.text = ""
            hoveredIndex = -1
            refresh()
            focusTimer.restart()
        } else {
            hoveredIndex = -1
        }
    }

    Timer {
        id: focusTimer
        interval: 10
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    Process {
        id: cliphistListProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const nextEntries = []
                const lines = this.text.split("\n")
                let added = 0

                for (const line of lines) {
                    if (!line || added >= root.maxItems) {
                        continue
                    }

                    const tabIndex = line.indexOf("\t")
                    if (tabIndex < 1) {
                        continue
                    }

                    const idPart = line.slice(0, tabIndex).trim()
                    const entryId = parseInt(idPart)
                    if (isNaN(entryId)) {
                        continue
                    }

                    const preview = line.slice(tabIndex + 1)
                    nextEntries.push({
                        entryId: entryId,
                        preview: preview,
                        isImage: entryIsImage(preview)
                    })
                    added += 1
                }

                root.entries = nextEntries
                rebuildFilteredModel()
            }
        }
    }

    Process {
        id: textPreviewProcess
        running: false
        property int entryId: -1
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.previewEntryId !== textPreviewProcess.entryId || root.previewIsImage) {
                    return
                }

                root.previewText = this.text.length > 0 ? this.text : "(empty)"
            }
        }
    }

    Process {
        id: imagePreviewProcess
        running: false
        property int entryId: -1
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.previewEntryId !== imagePreviewProcess.entryId || !root.previewIsImage) {
                    return
                }

                const path = this.text.trim()
                root.previewImagePath = path.length > 0 ? ("file://" + path) : ""
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.isOpen
        context: Qt.ApplicationShortcut
        onActivated: root.isOpen = false
    }

    Shortcut {
        sequence: "Up"
        enabled: root.isOpen
        context: Qt.ApplicationShortcut
        onActivated: moveSelection(-1)
    }

    Shortcut {
        sequence: "Down"
        enabled: root.isOpen
        context: Qt.ApplicationShortcut
        onActivated: moveSelection(1)
    }

    Shortcut {
        sequence: "Return"
        enabled: root.isOpen
        context: Qt.ApplicationShortcut
        onActivated: copyCurrent()
    }

    Shortcut {
        sequence: "Enter"
        enabled: root.isOpen
        context: Qt.ApplicationShortcut
        onActivated: copyCurrent()
    }

    Rectangle {
        anchors.fill: parent
        color: "#70000000"

        MouseArea {
            anchors.fill: parent
            onClicked: root.isOpen = false
        }
    }

    Rectangle {
        id: card
        width: Math.min(760, root.width - 40)
        height: Math.min(560, root.height - 60)
        anchors.centerIn: parent
        radius: 14
        color: theme.background
        border.color: theme.primary
        border.width: 2

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Clipboard History"
                color: theme.primary
                font.family: theme.fontFamily
                font.pixelSize: 20
                font.bold: true
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search clipboard..."
                color: theme.on_background
                font.family: theme.fontFamily
                font.pixelSize: 14
                selectByMouse: true
                onTextChanged: rebuildFilteredModel()
                Keys.onUpPressed: event => {
                    moveSelection(-1)
                    event.accepted = true
                }
                Keys.onDownPressed: event => {
                    moveSelection(1)
                    event.accepted = true
                }
                Keys.onReturnPressed: event => {
                    copyCurrent()
                    event.accepted = true
                }
                Keys.onEnterPressed: event => {
                    copyCurrent()
                    event.accepted = true
                }
                Keys.onEscapePressed: event => {
                    root.isOpen = false
                    event.accepted = true
                }

                background: Rectangle {
                    radius: 10
                    color: theme.surface_container
                    border.color: searchField.activeFocus ? theme.primary : theme.outline
                    border.width: 1
                }
            }

            Text {
                Layout.fillWidth: true
                text: filteredModel.count > 0
                    ? "Arrows to navigate, Enter to copy, Esc to close"
                    : "No clipboard entries"
                color: theme.on_surface_variant
                font.family: theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            ListView {
                id: resultsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredModel
                clip: true
                spacing: 6

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    contentItem: Rectangle {
                        implicitWidth: 7
                        radius: 3
                        color: theme.primary
                        opacity: parent.pressed ? 1 : (parent.active ? 0.8 : 0.4)
                    }
                }

                delegate: Rectangle {
                    required property int index
                    required property int entryId
                    required property string preview
                    required property bool isImage

                    width: resultsView.width - 12
                    implicitHeight: 54
                    radius: 10
                    color: root.selectedIndex === index ? theme.primary : theme.surface_container
                    border.color: theme.primary
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            root.hoveredIndex = index
                            root.updatePreviewForActiveIndex()
                        }
                        onExited: {
                            if (root.hoveredIndex === index) {
                                root.hoveredIndex = -1
                                root.updatePreviewForActiveIndex()
                            }
                        }
                        onClicked: {
                            root.selectedIndex = index
                            root.updatePreviewForActiveIndex()
                        }
                        onDoubleClicked: {
                            root.selectedIndex = index
                            root.updatePreviewForActiveIndex()
                            copyCurrent()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: isImage ? "" : ""
                            font.family: "monospace"
                            font.pixelSize: 16
                            color: root.selectedIndex === index ? theme.background : theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: preview.length > 0 ? preview : "(empty)"
                            color: root.selectedIndex === index ? theme.background : theme.on_background
                            font.family: theme.fontFamily
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.NoWrap
                        }

                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 10
                color: theme.surface_container
                border.color: theme.primary
                border.width: 1
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        interactive: true
                    }

                    Item {
                        width: parent.width
                        implicitHeight: previewIsImage ? 220 : previewTextBlock.implicitHeight

                        Image {
                            anchors.centerIn: parent
                            width: Math.max(1, parent.width - 12)
                            height: 200
                            visible: previewIsImage && previewImagePath !== ""
                            source: previewImagePath
                            fillMode: Image.PreserveAspectFit
                            cache: false
                        }

                        Text {
                            id: imagePlaceholder
                            anchors.centerIn: parent
                            visible: previewIsImage && previewImagePath === ""
                            text: "Loading image preview..."
                            color: theme.on_surface_variant
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                        }

                        Text {
                            id: previewTextBlock
                            width: parent.width
                            visible: !previewIsImage
                            text: previewText
                            color: theme.on_background
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: filteredModel
    }
}
