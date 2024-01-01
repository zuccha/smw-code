import Storage from "./storage";

export type Callback<T> = (t: T) => void;

export default class Signal<T> {
  private _id: string;
  private _t: T;
  private _subscribers: Set<Callback<T>> = new Set();

  constructor(id: string, t: T) {
    this._id = id;
    this._t = id ? Storage.load(id, t) : t;
  }

  get get(): T {
    return this._t;
  }

  set set(t: T) {
    if (t !== this._t) {
      this._t = t;
      if (this._id) Storage.save(this._id, t);
      this._notify();
    }
  }

  subscribe(callback: Callback<T>): () => void {
    this._subscribers.add(callback);
    return () => this._subscribers.delete(callback);
  }

  private _notify() {
    for (let subscriber of this._subscribers) subscriber(this._t);
  }
}
