class MuteService extends Service {
  static {
    Service.register(
      this,
      {
        "muted-changed": ["boolean"],
      },
      {
        "muted-value": ["boolean", "rw"],
      },
    );
  }

  private getIsMuted = () => {
    const stdout = Utils.exec(["bash", "-c", "amixer get Master"].join(" "));
    const isMutedLeft = /Front Left:.*\[on\]/.test(stdout);
    const isMutedRight = /Front Right:.*\[on\]/.test(stdout);

    return !(isMutedRight && isMutedLeft);
  };

  #mutedValue = this.getIsMuted();

  get muted_value() {
    return this.#mutedValue;
  }

  set muted_value(isMuted: boolean) {
    this.#mutedValue = isMuted;
  }

  constructor() {
    super();
    console.log("muted value:", this.#mutedValue);
    this.#onChange();
  }

  async #onChange() {
    this.#mutedValue = this.getIsMuted();
    this.emit("changed");
    this.notify("muted-value");
    this.emit("muted-changed", this.#mutedValue);
  }
}

export default new MuteService();
