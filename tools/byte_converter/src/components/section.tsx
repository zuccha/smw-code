import { ReactNode } from "preact/compat";
import "./section.css";

export type SectionProps = {
  children: ReactNode;
  label: string;
};

export default function Section({ children, label }: SectionProps) {
  return (
    <div class="section card">
      <div class="section-header">{label}</div>
      <div class="section-children">{children}</div>
    </div>
  );
}
