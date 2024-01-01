import Signal from "./signal";
import Table from "./table";

export default class Store {
  readonly table = new Table("table", 16, 16);
  readonly colorOpacity = new Signal("color-opacity", 0);
  readonly image = new Signal("image", "");
  readonly imageIsVisible = new Signal("image-is-visible", true);
}
