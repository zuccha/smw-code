import { ReactNode } from "preact/compat";

type AppSetting = {
  children: ReactNode;
  label: string;
};

export default function AppSetting({ children, label }: AppSetting) {
  return (
    <>
      <span class="app-setting-label">{label}</span>
      <div class="app-setting-input">{children}</div>
    </>
  );
}
