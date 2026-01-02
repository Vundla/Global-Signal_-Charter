// WebSocket / Phoenix Channels Client
import { writable, derived, type Writable } from 'svelte/store';

export interface RealtimeEvent {
	type: string;
	payload: any;
	timestamp: Date;
}

export interface ConnectionState {
	status: 'connecting' | 'connected' | 'disconnected' | 'error';
	reconnectAttempts: number;
	lastConnected: Date | null;
}

class RealtimeClient {
	private socket: WebSocket | null = null;
	private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
	private reconnectAttempts = 0;
	private maxReconnectAttempts = 5;
	private reconnectDelay = 1000;

	public connectionState: Writable<ConnectionState> = writable({
		status: 'disconnected',
		reconnectAttempts: 0,
		lastConnected: null
	});

	public events: Writable<RealtimeEvent[]> = writable([]);

	constructor(private url: string) {}

	connect() {
		if (this.socket?.readyState === WebSocket.OPEN) {
			console.log('Already connected');
			return;
		}

		this.updateConnectionState('connecting');

		try {
			this.socket = new WebSocket(this.url);

			this.socket.onopen = () => {
				console.log('WebSocket connected');
				this.reconnectAttempts = 0;
				this.updateConnectionState('connected');
			};

			this.socket.onmessage = (event) => {
				this.handleMessage(event.data);
			};

			this.socket.onerror = (error) => {
				console.error('WebSocket error:', error);
				this.updateConnectionState('error');
			};

			this.socket.onclose = () => {
				console.log('WebSocket disconnected');
				this.updateConnectionState('disconnected');
				this.scheduleReconnect();
			};
		} catch (error) {
			console.error('Failed to create WebSocket:', error);
			this.updateConnectionState('error');
			this.scheduleReconnect();
		}
	}

	disconnect() {
		if (this.reconnectTimer) {
			clearTimeout(this.reconnectTimer);
			this.reconnectTimer = null;
		}

		if (this.socket) {
			this.socket.close();
			this.socket = null;
		}

		this.updateConnectionState('disconnected');
	}

	send(type: string, payload: any) {
		if (this.socket?.readyState === WebSocket.OPEN) {
			const message = JSON.stringify({ type, payload, timestamp: new Date().toISOString() });
			this.socket.send(message);
		} else {
			console.warn('Cannot send message: WebSocket not connected');
		}
	}

	subscribe(topic: string) {
		this.send('subscribe', { topic });
	}

	unsubscribe(topic: string) {
		this.send('unsubscribe', { topic });
	}

	private handleMessage(data: string) {
		try {
			const message = JSON.parse(data);
			const event: RealtimeEvent = {
				type: message.type || 'unknown',
				payload: message.payload || {},
				timestamp: message.timestamp ? new Date(message.timestamp) : new Date()
			};

			this.events.update((events) => [...events, event]);
		} catch (error) {
			console.error('Failed to parse message:', error);
		}
	}

	private updateConnectionState(status: ConnectionState['status']) {
		this.connectionState.update((state) => ({
			...state,
			status,
			reconnectAttempts: this.reconnectAttempts,
			lastConnected: status === 'connected' ? new Date() : state.lastConnected
		}));
	}

	private scheduleReconnect() {
		if (this.reconnectAttempts >= this.maxReconnectAttempts) {
			console.log('Max reconnect attempts reached');
			return;
		}

		const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts);
		this.reconnectAttempts++;

		console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);

		this.reconnectTimer = setTimeout(() => {
			this.connect();
		}, delay);
	}
}

// Create singleton instance
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:4000/socket/websocket';
export const realtimeClient = new RealtimeClient(WS_URL);

// Derived stores for convenience
export const connectionStatus = derived(
	realtimeClient.connectionState,
	($state) => $state.status
);

export const isConnected = derived(connectionStatus, ($status) => $status === 'connected');

// Auto-connect when browser is online
if (typeof window !== 'undefined') {
	window.addEventListener('online', () => {
		realtimeClient.connect();
	});

	window.addEventListener('offline', () => {
		realtimeClient.disconnect();
	});
}
