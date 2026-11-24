// Native Docusaurus route lifecycle, including back/forward navigation.
export function onRouteDidUpdate(): void {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new Event('kaori:analytics-route'));
  }
}
