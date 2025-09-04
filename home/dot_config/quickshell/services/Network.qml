pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null

    reloadableId: "network"

    Process {
        running: true
        command: ["nu", "-c", `networkctl status | grep "Online state" | str contains online`]
        stdout: StdioCollector {
          onStreamFinished: getNetworks.running = this.text === "true"
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["sh", "-c", `networkctl --json=short`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text);
                    const interfaces = (json.Interfaces ?? []).filter(i => i.Type === "ether" || i.Type === "wlan");

                    const networks = interfaces.map(i => ({
                        active: (i.OnlineState === "online") || (i.OperationalState === "routable"),
                        strength: 0,
                        frequency: 0,
                        ssid: i.Name,
                        type: i.Type
                    }));

                    const rNetworks = root.networks;

                    const destroyed = rNetworks.filter(rn => !networks.find(n => n.ssid === rn.ssid));
                    for (const network of destroyed)
                        rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                    for (const network of networks) {
                        const match = rNetworks.find(n => n.ssid === network.ssid);
                        if (match) {
                            match.active = network.active;
                            match.strength = network.strength;
                            match.frequency = network.frequency;
                            match.ssid = network.ssid;
                            match.type = network.type;
                        } else {
                            rNetworks.push(apComp.createObject(root, network));
                        }
                    }
                } catch (e) {
                    // ignore parse errors
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property string ssid
        required property int strength
        required property int frequency
        required property bool active
        required property string type
    }

    Component {
        id: apComp

        AccessPoint {}
    }
}
