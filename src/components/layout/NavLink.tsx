import React, { ReactNode } from 'react';

interface NavLinkProps {
  href: string;
  icon: ReactNode;
  children: ReactNode;
}

export function NavLink({ href, icon, children }: NavLinkProps) {
  return (
    <a
      href={href}
      className="flex items-center gap-3 text-gray-300 hover:text-white hover:bg-gray-800 rounded-lg p-2 transition-colors"
    >
      {icon}
      <span>{children}</span>
    </a>
  );
}