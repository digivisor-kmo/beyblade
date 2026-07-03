// Themed laadscherm. Pure CSS-animatie (zie globals.css), fade't zichzelf uit.
// Geen client-JS nodig; verschijnt bij een volledige (her)load van de app.
export function Preloader() {
  return (
    <div className="preloader" aria-hidden>
      <div className="preloader__inner">
        <svg
          className="preloader__bey"
          width="112"
          height="112"
          viewBox="0 0 100 100"
          fill="none"
        >
          <defs>
            <linearGradient id="pl-g" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor="#3d7bff" />
              <stop offset="100%" stopColor="#ff5a3c" />
            </linearGradient>
          </defs>
          {/* buitenring */}
          <circle cx="50" cy="50" r="44" stroke="url(#pl-g)" strokeWidth="4" opacity="0.6" />
          {/* 3 blades */}
          <g fill="url(#pl-g)">
            <path d="M50 6 L62 30 L38 30 Z" />
            <path d="M50 6 L62 30 L38 30 Z" transform="rotate(120 50 50)" />
            <path d="M50 6 L62 30 L38 30 Z" transform="rotate(240 50 50)" />
          </g>
          {/* naaf */}
          <circle cx="50" cy="50" r="16" fill="#12172a" stroke="url(#pl-g)" strokeWidth="4" />
          <circle cx="50" cy="50" r="5" fill="#eef2fb" />
        </svg>
        <p className="preloader__title">BEYBLADE X</p>
        <div className="preloader__bar">
          <i />
        </div>
      </div>
    </div>
  );
}
