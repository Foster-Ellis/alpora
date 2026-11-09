pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "theme" as PolyTheme
import "AppearanceCatalog.js" as Catalog

ColumnLayout {
 id: root
 property url wallpaper: ""
 readonly property var selected: Catalog.elements.find(e => e.id === AppearanceState.element) || Catalog.elements[2]
 // Narrow windows put the preview under the controls; the settings window then
 // scrolls the page when it is shorter than this height.
 readonly property bool stacked: width < 700
 readonly property real minimumPageHeight: elements.implicitHeight + Math.max(44, footer.implicitHeight) + 1 + spacing * 3
  + (stacked ? 300 + main.rowSpacing + side.implicitHeight : Math.max(300, side.implicitHeight))
 spacing: 12
 GridLayout {
  id: elements
  Layout.fillWidth: true; columns: root.width < 800 ? 3 : Catalog.elements.length; columnSpacing: 5; rowSpacing: 5
  Repeater {
   model: Catalog.elements
   AppearanceButton {
    required property var modelData
    Layout.fillWidth: true; Layout.minimumWidth: 0
    text: modelData.title; symbol: modelData.icon
    selected: AppearanceState.element === modelData.id
    leftPadding: 8; rightPadding: 8
    onClicked: AppearanceState.element = modelData.id
   }
  }
 }
 GridLayout {
  id: main
  Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 0
  columns: root.stacked ? 1 : 2; columnSpacing: 16; rowSpacing: 16
  // Stacked, the scrolling control list takes the spare height and the preview keeps its own.
  AppearancePage { Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: root.stacked ? 300 : 0; Layout.preferredHeight: root.stacked ? 300 : -1; Layout.minimumWidth: root.stacked ? 0 : 330 }
  ColumnLayout {
   id: side
   Layout.preferredWidth: root.stacked ? -1 : 320; Layout.fillWidth: root.stacked
   Layout.fillHeight: !root.stacked; Layout.minimumHeight: root.stacked ? side.implicitHeight : 0; spacing: 10
   Text { text: "ПРЕДПРОСМОТР"; color: Session.accent; font.family: Session.fontFamily; font.pixelSize: 11; font.letterSpacing: 1 }
   AppearancePreview { id: preview; wallpaper: root.wallpaper; element: AppearanceState.element; Layout.fillWidth: true; Layout.preferredHeight: 210 }
   RowLayout {
    Layout.fillWidth: true; spacing: 8
    AppearanceButton { Layout.fillWidth: true; text: "Светлый"; symbol: "sun"; selected: !preview.dark; onClicked: preview.dark = false }
    AppearanceButton { Layout.fillWidth: true; text: "Тёмный"; symbol: "moon"; selected: preview.dark; onClicked: preview.dark = true }
   }
   AppearanceSection {
    Layout.fillWidth: true; title: root.selected.title; symbol: root.selected.icon; description: root.selected.description
    Text { Layout.fillWidth: true; text: "Параметры сохраняются при смене темы. Work / Vibe выбираются независимо."; color: Session.muted; font.family: Session.fontFamily; font.pixelSize: 11; wrapMode: Text.Wrap }
   }
   Text { Layout.fillWidth: true; text: "На макете видны форма, фон, отступы и обводка. Размытие и движение проверяются после применения."; color: Session.muted; font.family: Session.fontFamily; font.pixelSize: 10; wrapMode: Text.Wrap }
   Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
   AppearanceButton { Layout.fillWidth: true; text: "Сбросить настройки элемента"; symbol: "refresh"; enabled: !AppearanceState.busy; onClicked: AppearanceState.resetElement() }
  }
 }
 Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Glass.tint(Session.accent, 0.2) }
 RowLayout {
  id: footer
  Layout.fillWidth: true; Layout.preferredHeight: 44; spacing: 10
  Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: AppearanceState.dirty ? PolyTheme.Theme.secondary : Session.accent }
  Text { Layout.fillWidth: true; text: AppearanceState.error || AppearanceState.message || (AppearanceState.dirty ? "Есть несохранённые изменения" : "Всё сохранено"); color: AppearanceState.error ? PolyTheme.Theme.secondary : Session.muted; font.family: Session.fontFamily; font.pixelSize: 11; wrapMode: Text.Wrap }
  AppearanceButton { text: "Отменить"; symbol: "close"; enabled: !AppearanceState.busy && (AppearanceState.dirty || !!AppearanceState.error); onClicked: AppearanceState.cancel() }
  AppearanceButton { text: AppearanceState.busy ? "Сохранение…" : "Применить"; symbol: "check"; primary: true; enabled: AppearanceState.dirty && !AppearanceState.busy; onClicked: AppearanceState.apply() }
 }
}
