import { Link } from 'react-router-dom';

export function NotFoundPage() {
  return (
    <div className="max-w-md mx-auto px-4 py-24 text-center">
      <h1 className="text-6xl font-extrabold text-brand">404</h1>
      <p className="mt-2 text-white/70">This reel doesn't exist.</p>
      <Link to="/" className="btn-primary mt-6 inline-flex">Back to home</Link>
    </div>
  );
}
