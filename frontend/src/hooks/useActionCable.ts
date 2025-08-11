import { useEffect, useRef } from 'react';
import { createConsumer } from '@rails/actioncable';
import { useAuthStore } from '@/store/auth';

const WS_URL =
  import.meta.env.VITE_WS_URL?.trim() ||
  `${window.location.protocol === 'https:' ? 'wss:' : 'ws:'}//${window.location.host}/cable`;

let consumer: ReturnType<typeof createConsumer> | null = null;

function getConsumer(token?: string | null) {
  if (consumer) return consumer;

  const url = token ? `${WS_URL}?token=${encodeURIComponent(token)}` : WS_URL;

  consumer = createConsumer(url);

  return consumer;
}

export function useChannel<T = unknown>(
  channel: { channel: string; [k: string]: unknown },
  onMessage: (msg: T) => void,
  deps: unknown[] = []
) {
  const sub = useRef<any>(null);
  const token = useAuthStore(s => s.accessToken);

  useEffect(() => {
    const c = getConsumer(token);

    sub.current = c.subscriptions.create(channel, {
      received(data: T) {
        onMessage(data);
      }
    });

    return () => {
      sub.current?.unsubscribe();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}