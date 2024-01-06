import { ReactNode } from "preact/compat";
import { classNames } from "../utils";
import "./section.css";

export type SectionProps = {
  children: ReactNode;
  className?: string;
  header: ReactNode;
};

export default function Section({
  children,
  className = "",
  header,
}: SectionProps) {
  const _className = classNames([
    ["section", true],
    [className, Boolean(className)],
  ]);

  return (
    <div class={_className}>
      {header}
      <div class="section-children">{children}</div>
    </div>
  );
}
