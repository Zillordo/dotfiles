import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Column {
    id: root

    spacing: Appearance.spacing.normal

    StyledText {
        text: qsTr("Connected to: %1").arg(Network.active?.ssid ?? "None")
    }

    StyledText {
      text: Network.active?.strength ? qsTr("Strength: %1/100").arg(Network.active?.strength ?? 0) : ""
    }
}
