import { sh } from "lib/utils";

type Profile = "bat" | "ac";
type Mode = "Hybrid" | "Integrated";

class Asusctl extends Service {
  static {
    Service.register(
      this,
      {},
      {
        profile: ["string", "r"],
        mode: ["string", "r"],
      },
    );
  }

  available = !!Utils.exec("tlp -s");
  #profile: Profile = "bat";
  #mode: Mode = "Hybrid";

  async nextProfile() {
    await sh("asusctl profile -n");
    const profile = await sh("asusctl profile -p");
    const p = profile.split(" ")[3] as Profile;
    this.#profile = p;
    this.changed("profile");
  }

  async setProfile(prof: Profile) {
    await sh(`sudo tlp ${prof}`);
    this.#profile = prof;
    this.changed("profile");
  }

  async nextMode() {
    await sh(
      `supergfxctl -m ${this.#mode === "Hybrid" ? "Integrated" : "Hybrid"}`,
    );
    this.#mode = (await sh("supergfxctl -g")) as Mode;
    this.changed("profile");
  }

  constructor() {
    super();

    if (this.available) {
      sh("tlp-stat -s").then((p: string) => {
        const lines = p.trim().split("/n");
        for (const line of lines) {
          if (line.startsWith("Mode")) {
            const value = line.split("=")[1];
            this.#profile = value as Profile;
          }
        }
      });
    }
  }

  get profiles(): Profile[] {
    return ["bat", "ac"];
  }

  get profile() {
    return this.#profile;
  }

  get mode() {
    return this.#mode;
  }
}

export default new Asusctl();
