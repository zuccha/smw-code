import { ReactNode } from "preact/compat";

type AppSetting = {
  children: ReactNode;
  hotkey?: string;
  label: string;
};

export default function AppSetting({ children, hotkey, label }: AppSetting) {
  return (
    <div class="app-setting">
      <span class="app-setting-label">
        {hotkey ? `${label} (${hotkey})` : label}
      </span>
      <div class="app-setting-input">{children}</div>
    </div>
  );
}
