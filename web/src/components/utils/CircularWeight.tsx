import React from 'react';
import { WeightGlyphIcon } from './icons';

interface CircularWeightProps {
  percent: number;
  className?: string;
}

const RADIUS = 46;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

const CircularWeight: React.FC<CircularWeightProps> = ({ percent, className }) => {
  const clamped = Number.isFinite(percent) ? Math.min(100, Math.max(0, percent)) : 0;

  return (
    <div className={`weight-ring ${className || ''}`}>
      <svg className="weight-ring-svg" viewBox="0 0 100 100">
        <circle className="weight-ring-trail" cx="50" cy="50" r={RADIUS} strokeWidth={8} fill="none" />
        <circle
          className="weight-ring-path"
          cx="50"
          cy="50"
          r={RADIUS}
          strokeWidth={8}
          fill="none"
          strokeLinecap="round"
          transform="rotate(-90 50 50)"
          strokeDasharray={CIRCUMFERENCE}
          strokeDashoffset={CIRCUMFERENCE - (clamped / 100) * CIRCUMFERENCE}
        />
      </svg>
      <span className="weight-ring-glyph">
        <WeightGlyphIcon />
      </span>
    </div>
  );
};

export default React.memo(CircularWeight);
