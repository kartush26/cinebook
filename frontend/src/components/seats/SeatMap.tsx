import { useMemo } from 'react';
import clsx from 'clsx';
import { Seat } from '@/api/endpoints';

type Props = {
  seats: Seat[];
  selected: Set<string>;
  onToggle: (seatId: string) => void;
};

export function SeatMap({ seats, selected, onToggle }: Props) {
  const rows = useMemo(() => {
    const map = new Map<string, Seat[]>();
    seats.forEach(s => {
      if (!map.has(s.row_label)) map.set(s.row_label, []);
      map.get(s.row_label)!.push(s);
    });
    map.forEach(arr => arr.sort((a, b) => a.column_index - b.column_index));
    return Array.from(map.entries()).sort(([a], [b]) => a.localeCompare(b));
  }, [seats]);

  return (
    <div className="overflow-x-auto pb-4">
      <div className="text-center mb-6">
        <div className="mx-auto h-1.5 w-3/4 bg-gradient-to-r from-transparent via-brand to-transparent rounded-full mb-1" />
        <p className="text-xs uppercase tracking-widest text-slate-400">Screen this way</p>
      </div>

      <div className="flex flex-col items-center gap-1">
        {rows.map(([row, rowSeats]) => (
          <div key={row} className="flex items-center gap-1">
            <div className="w-6 text-xs text-slate-400 text-right pr-2">{row}</div>
            {rowSeats.map(s => {
              const isSelected = selected.has(s.id);
              const state: 'available' | 'selected' | 'locked' | 'booked' =
                s.state === 'booked' ? 'booked' :
                s.state === 'locked' ? 'locked' :
                isSelected ? 'selected' : 'available';
              return (
                <button
                  key={s.id}
                  title={`${s.label} · $${s.price}`}
                  disabled={state === 'booked' || state === 'locked'}
                  onClick={() => onToggle(s.id)}
                  className={clsx('seat', state)}
                >
                  {s.column_index}
                </button>
              );
            })}
            <div className="w-6 text-xs text-slate-400 pl-2">{row}</div>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-4 mt-6 text-xs text-slate-500 justify-center">
        <Legend className="available" label="Available" />
        <Legend className="selected"  label="Selected" />
        <Legend className="locked"    label="Locked by others" />
        <Legend className="booked"    label="Booked" />
      </div>
    </div>
  );
}

function Legend({ className, label }: { className: string; label: string }) {
  return <span className="inline-flex items-center gap-2"><span className={`seat ${className}`} style={{ width: 16, height: 16 }} />{label}</span>;
}
