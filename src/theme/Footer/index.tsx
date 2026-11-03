import React from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import DocsIcon from '../../components/DocsIcon';

interface FooterLink {
  label: string;
  to?: string;
  href?: string;
}

interface FooterGroup {
  title: string;
  items: FooterLink[];
}

interface FooterConfig {
  logo?: {src: string; alt: string};
  links?: FooterGroup[];
  copyright?: string;
}

function FooterNavLink({item}: {item: FooterLink}): React.JSX.Element | null {
  const href = item.to ?? item.href;
  if (!href) return null;

  const external = /^https?:\/\//.test(href);
  const email = href.startsWith('mailto:');

  return (
    <a
      className="kaori-docs-footer__link"
      href={href}
      rel={external ? 'noopener noreferrer' : undefined}
      target={external ? '_blank' : undefined}
    >
      {email && <DocsIcon name="mail" size={15} />}
      <span>{item.label}</span>
      {external && <DocsIcon name="arrow-up-right" size={14} />}
    </a>
  );
}

export default function Footer(): React.JSX.Element | null {
  const {siteConfig} = useDocusaurusContext();
  const footer = siteConfig.themeConfig.footer as FooterConfig | undefined;
  const logo = useBaseUrl(footer?.logo?.src ?? 'branding/kaori-logo.svg');

  if (!footer) return null;

  return (
    <footer className="footer kaori-docs-footer">
      <div className="container kaori-docs-footer__main">
        <div className="kaori-docs-footer__identity">
          <a className="kaori-docs-footer__brand" href="/">
            <img src={logo} alt="" width={36} height={36} />
            <strong>KAORI Documentation</strong>
          </a>
          <p className="kaori-docs-footer__tagline">
            Infrastructure operations, connected by evidence.
          </p>
          <p className="kaori-docs-footer__acronym">
            <strong>Knowledge</strong>
            <span>Automation</span>
            <strong>Operations</strong>
            <span>Resilience</span>
            <strong>Intelligence</strong>
          </p>
          <p className="kaori-docs-footer__attribution">
            An <strong>OXY7 ORBITAL</strong> project.
          </p>
        </div>

        <nav className="kaori-docs-footer__navigation" aria-label="Footer navigation">
          {footer.links?.map((group) => (
            <div className="kaori-docs-footer__group" key={group.title}>
              <h2>{group.title}</h2>
              {group.title === 'Contact' && (
                <span className="kaori-docs-footer__owner">Lethisa Putri</span>
              )}
              {group.items.map((item) => (
                <FooterNavLink item={item} key={item.label} />
              ))}
            </div>
          ))}
        </nav>
      </div>
      <div className="container kaori-docs-footer__bottom">
        <span>{footer.copyright}</span>
        <span>Documentation for connected operations.</span>
      </div>
    </footer>
  );
}
