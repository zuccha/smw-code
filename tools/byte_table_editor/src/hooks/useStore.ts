import { useCallback, useLayoutEffect, useState } from "preact/hooks";
import Signal from "../store/signal";
import Store from "../store/store";
import { ValueEncoding, ValueUnit } from "../store/value";
import Selection from "../store/selection";
import Table from "../store/table";

type SignalState<T> = [T, (value: T) => void];

const store = new Store();

export default function useStore(): Store {
  return store;
}

function useSignal<T>(signal: Signal<T>): SignalState<T> {
  const [value, setValue] = useState(signal.get);
  useLayoutEffect(() => signal.subscribe(setValue), [signal]);
  return [
    value,
    useCallback((newValue: T) => (signal.set = newValue), [signal]),
  ];
}

export function useTable(): Table {
  return store.table;
}

export function useTableSize(): SignalState<{ height: number; width: number }> {
  return useSignal(store.table.size);
}

export function useTableEncoding(): SignalState<ValueEncoding> {
  return useSignal(store.table.encoding);
}

export function useTableUnit(): SignalState<ValueUnit> {
  return useSignal(store.table.unit);
}

export function useTableCellValue(x: number, y: number): number {
  const [value, setValue] = useState(store.table.get(x, y));

  useLayoutEffect(() => {
    return store.table.subscribe(x, y, setValue);
  }, [x, y]);

  return value;
}

export function useSelection(): Selection {
  return store.table.selection;
}

export function useTableCellIsSelected(x: number, y: number): boolean {
  const [size] = useTableSize();
  const [isSelected, setIsSelected] = useState(
    store.table.selection.isSelected(x, y)
  );

  useLayoutEffect(() => {
    return store.table.selection.subscribe(x, y, setIsSelected);
  }, [x, y, size]);

  return isSelected;
}

export function useColorOpacity(): SignalState<number> {
  return useSignal(store.colorOpacity);
}

export function useImage(): SignalState<string> {
  return useSignal(store.image);
}

export function useImageIsVisible(): SignalState<boolean> {
  return useSignal(store.imageIsVisible);
}
