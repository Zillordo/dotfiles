import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell.Io
import QtQuick
import Quickshell.Widgets

WrapperMouseArea {
    StyledText {
        text: Icons.osIcon
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        color: Colours.palette.m3tertiary
    }

  // Process {
  //     id: omarchyMenuProc
  //     command: ["sh", "-c", "omarchy-menu"]
  // }

  // onClicked: () => {
  //   omarchyMenuProc.startDetached();
  // }
}
